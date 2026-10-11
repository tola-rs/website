// Run the Pagefind search dialog rendered by components/partials/search.typ.
// Results are single links; "details" only reveals a static, inert excerpt.

import { loadSearchPreview } from "./shared/search-preview.ts";
import { searchHighlights } from "./shared/search-highlight.ts";

(() => {
  const popup = document.getElementById("site-search") as HTMLDialogElement | null;
  if (!popup || !popup.showModal) return;
  const dialog = popup;
  const input = document.getElementById("search-input") as HTMLInputElement;
  const status = document.getElementById("search-status") as HTMLElement;
  const results = document.getElementById("search-results") as HTMLOListElement;
  const region = document.getElementById("search-results-region") as HTMLElement;
  const clear = document.getElementById("search-clear") as HTMLButtonElement;
  const details = document.getElementById("search-details") as HTMLButtonElement;
  const engineUrl = dialog.dataset.index ?? "";
  const baseUrl = dialog.dataset.baseUrl ?? "";
  type SearchState = "empty" | "searching" | "count" | "none" | "error";
  const message = (key: SearchState) => dialog.dataset[key] ?? "";
  const setStatus = (state: SearchState, count = 0) => {
    status.dataset.state = state;
    const text = message(state).replace("{count}", String(count));
    if (status.textContent !== text) status.textContent = text;
    results.setAttribute("aria-busy", String(state === "searching"));
  };

  type SubResult = { url: string; title: string; excerpt?: string };
  type SearchFragment = {
    url: string;
    excerpt?: string;
    meta?: { title?: string; breadcrumb?: string; preview?: string };
    sub_results?: SubResult[];
  };
  type SearchHit = { data: () => Promise<SearchFragment> };
  type Pagefind = {
    options: (options: { baseUrl: string }) => Promise<void>;
    init: () => Promise<void>;
    search: (term: string) => Promise<{ results: SearchHit[] }>;
  };

  let opener: Element | null = null;
  let engine: Promise<Pagefind> | undefined;
  // A newer query invalidates in-flight results without waiting for them.
  let generation = 0;
  let timer: number | undefined;
  let hits: SearchHit[] = [];
  let shown = 0;
  let loading = false;
  let query = "";
  let active: HTMLAnchorElement | null = null;
  let composing = false;
  let pointer: { x: number; y: number } | undefined;
  const rendered = new Set<string>();

  const detailsOn = () => details.getAttribute("aria-pressed") === "true";
  const setDetails = (on: boolean) => {
    details.setAttribute("aria-pressed", String(on));
    for (const excerpt of results.querySelectorAll<HTMLElement>(".search-result-excerpt")) {
      excerpt.hidden = !on;
    }
    try { localStorage.setItem("tola:search-details", String(on)); } catch { /* storage can be unavailable */ }
  };

  const activate = (link: HTMLAnchorElement | null) => {
    if (link === active) return;
    active?.closest(".search-result")?.removeAttribute("data-active");
    active = link;
    active?.closest(".search-result")?.setAttribute("data-active", "");
  };

  const loadEngine = () => {
    if (!engine) engine = import(engineUrl).then(async (module: Pagefind) => {
      await module.options({ baseUrl });
      await module.init();
      return module;
    }).catch(error => {
      engine = undefined;
      throw error;
    });
    return engine;
  };

  function renderTrail(target: HTMLElement, parts: string[], term: string) {
    target.replaceChildren(searchHighlights(parts.filter(Boolean).join(" › "), term));
    target.hidden = !target.textContent;
  }

  function excerptFragment(html: string): DocumentFragment {
    const doc = new DOMParser().parseFromString(html, "text/html");
    const fragment = document.createDocumentFragment();
    function copy(node: Node, target: ParentNode) {
      if (node.nodeType === Node.TEXT_NODE) target.append(document.createTextNode(node.textContent ?? ""));
      else if (node instanceof Element) {
        if (["SCRIPT", "STYLE"].includes(node.tagName)) return;
        const parent = node.tagName === "MARK" ? document.createElement("mark") : target;
        for (const child of node.childNodes) copy(child, parent);
        if (parent !== target) target.append(parent);
      }
    }
    for (const child of doc.body.childNodes) copy(child, fragment);
    return fragment;
  }

  // Arrow navigation scrolls only the result pane, never the page or input row.
  function focusSearchElement(target: HTMLElement) {
    target.focus({ preventScroll: true });
    if (!region.contains(target)) return;
    const pane = region.getBoundingClientRect();
    const box = target.getBoundingClientRect();
    const top = pane.top + region.clientTop;
    const bottom = top + region.clientHeight;
    if (box.top < top) region.scrollTop += box.top - top;
    else if (box.bottom > bottom) region.scrollTop += box.bottom - bottom;
  }

  function appendSection(row: SearchFragment, section: SubResult, token: number) {
    let href: URL;
    try { href = new URL(section.url, location.href); } catch { return; }
    if (href.origin !== location.origin || !["http:", "https:"].includes(href.protocol) || rendered.has(href.href)) return;
    rendered.add(href.href);

    const item = document.createElement("li");
    item.className = "search-result";
    const link = document.createElement("a");
    link.className = "search-result-link";
    link.href = href.href;

    const breadcrumb = [row.meta?.breadcrumb ?? ""];
    if (href.hash && section.title !== row.meta?.title) breadcrumb.push(row.meta?.title ?? "");
    const heading = document.createElement("span");
    heading.className = "search-result-heading";
    const trail = document.createElement("span");
    trail.className = "search-result-trail";
    renderTrail(trail, breadcrumb, query);
    const title = document.createElement("span");
    title.className = "search-result-title";
    title.append(searchHighlights(section.title || row.meta?.title || row.url, query));
    heading.append(trail, title);

    const excerpt = document.createElement("div");
    excerpt.className = "search-result-excerpt prose prose-excerpt";
    excerpt.setAttribute("inert", "");
    excerpt.hidden = !detailsOn();
    excerpt.append(excerptFragment(section.excerpt || row.excerpt || ""));
    if (row.meta?.preview) {
      void loadSearchPreview(row.meta.preview, href.hash.slice(1), query).then(loaded => {
        if (!loaded || token !== generation || !excerpt.isConnected) return;
        // The excerpt lives inside the result link; flatten interactive nodes
        // so the whole result keeps a single anchor and no nested controls.
        for (const anchor of loaded.content.querySelectorAll("a")) {
          const span = document.createElement("span");
          span.className = "excerpt-link";
          span.append(...anchor.childNodes);
          anchor.replaceWith(span);
        }
        for (const control of loaded.content.querySelectorAll("button, input, select, textarea")) control.remove();
        excerpt.replaceChildren(loaded.content);
      }).catch(() => { /* Pagefind's text excerpt remains as the fallback. */ });
    }

    link.append(heading, excerpt);
    item.append(link);
    results.append(item);
  }

  const appendResults = async (token: number) => {
    if (loading || shown >= hits.length) return;
    loading = true;
    let completed = false;
    const batch = hits.slice(shown, shown + 10);
    try {
      const rows = await Promise.all(batch.map(hit => hit.data()));
      if (token !== generation) return;
      for (const row of rows) {
        const sections = row.sub_results?.length
          ? row.sub_results
          : [{ url: row.url, title: row.meta?.title || row.url, excerpt: row.excerpt }];
        for (const section of sections) appendSection(row, section, token);
      }
      shown += batch.length;
      completed = true;
      setStatus(rendered.size || shown < hits.length ? "count" : "none", hits.length);
    } catch (error) {
      console.warn("Could not load Pagefind results", error);
      if (token === generation) setStatus("error");
    } finally {
      if (token === generation) {
        loading = false;
        if (completed) loadNearEnd();
      }
    }
  };

  function loadNearEnd() {
    if (status.dataset.state === "searching" || status.dataset.state === "empty") return;
    if (dialog.open && region.scrollHeight - region.scrollTop - region.clientHeight < 200) {
      void appendResults(generation);
    }
  }

  async function search(term: string, token: number) {
    try {
      const pagefind = await loadEngine();
      if (token !== generation) return;
      const found = await pagefind.search(term);
      if (token !== generation) return;
      hits = found.results;
      shown = 0;
      loading = false;
      rendered.clear();
      activate(null);
      results.replaceChildren();
      region.scrollTop = 0;
      setStatus(hits.length ? "count" : "none", hits.length);
      await appendResults(token);
    } catch (error) {
      console.warn("Pagefind search failed", error);
      if (token === generation) setStatus("error");
    }
  }

  const openSearch = () => {
    if (!dialog.open) {
      opener = document.activeElement;
      dialog.showModal();
    }
    input.focus({ preventScroll: true });
    clear.disabled = input.value.length === 0;
    loadNearEnd();
    const token = generation;
    loadEngine().catch(error => {
      console.warn("Could not initialize Pagefind", error);
      if (token === generation && dialog.open) setStatus("error");
    });
  };

  for (const trigger of document.querySelectorAll<HTMLButtonElement>("[data-open-search]")) {
    trigger.addEventListener("click", openSearch);
    trigger.disabled = false;
  }
  dialog.querySelector<HTMLElement>("[data-close-search]")?.addEventListener("click", () => dialog.close());
  dialog.addEventListener("close", () => { if (opener instanceof HTMLElement) opener.focus(); });
  dialog.addEventListener("click", event => {
    if (event.target !== dialog) return;
    const box = dialog.getBoundingClientRect();
    if (event.clientX < box.left || event.clientX > box.right || event.clientY < box.top || event.clientY > box.bottom) {
      dialog.close();
    }
  });
  document.addEventListener("keydown", event => {
    if ((event.ctrlKey || event.metaKey) && !event.altKey && event.key.toLowerCase() === "k") {
      event.preventDefault();
      openSearch();
    }
  });

  const updateSearch = () => {
    clearTimeout(timer);
    const token = ++generation;
    const term = input.value.trim();
    query = term;
    clear.disabled = input.value.length === 0;
    if (!term) {
      activate(null);
      results.replaceChildren();
      rendered.clear();
      region.scrollTop = 0;
      hits = [];
      shown = 0;
      loading = false;
      setStatus("empty");
      return;
    }
    // Keep the current rows visible while the next query runs; blanking on
    // every keystroke is what makes the pane flash.
    setStatus("searching");
    if (!composing) timer = window.setTimeout(() => search(term, token), 250);
  };

  input.addEventListener("compositionstart", () => {
    composing = true;
    clearTimeout(timer);
    ++generation;
  });
  input.addEventListener("compositionend", () => {
    composing = false;
    updateSearch();
  });
  input.addEventListener("input", updateSearch);
  clear.addEventListener("click", () => {
    input.value = "";
    updateSearch();
    input.focus({ preventScroll: true });
  });
  details.addEventListener("click", () => setDetails(!detailsOn()));

  region.addEventListener("scroll", () => { loadNearEnd(); }, { passive: true });
  addEventListener("resize", () => { loadNearEnd(); });
  dialog.addEventListener("pointermove", event => {
    const moved = !pointer || pointer.x !== event.clientX || pointer.y !== event.clientY;
    pointer = { x: event.clientX, y: event.clientY };
    // Layout/scroll can put a new row under a stationary pointer; it must not steal keyboard selection.
    if (!moved || !(event.target instanceof Element)) return;
    const row = event.target.closest(".search-result");
    if (row && results.contains(row)) activate(row.querySelector<HTMLAnchorElement>(".search-result-link"));
  });
  results.addEventListener("focusin", event => {
    if (!(event.target instanceof Element)) return;
    activate(event.target.closest(".search-result")?.querySelector<HTMLAnchorElement>(".search-result-link") ?? null);
  });
  results.addEventListener("click", event => {
    if (event.target instanceof Element && event.target.closest("a[href]")) {
      opener = null;
      dialog.close();
    }
  });

  dialog.addEventListener("keydown", event => {
    if (event.isComposing) return;
    if (event.key === "Escape") {
      event.preventDefault();
      dialog.close();
      return;
    }
    if (event.key !== "Enter" && event.key !== "ArrowDown" && event.key !== "ArrowUp") return;
    const links = [...results.querySelectorAll<HTMLAnchorElement>(".search-result-link")];
    const focused = document.activeElement;
    const onPrimary = focused instanceof HTMLAnchorElement && links.includes(focused);
    if (event.key === "Enter" && (focused === input || onPrimary) && links.length) {
      event.preventDefault();
      (active ?? links[0]).click();
      return;
    }
    if (!["ArrowDown", "ArrowUp"].includes(event.key)) return;
    if (!links.length || (focused !== input && !onPrimary)) return;
    event.preventDefault();
    const current = active ? links.indexOf(active) : -1;
    const next = current < 0 ? (event.key === "ArrowDown" ? 0 : links.length - 1)
      : current + (event.key === "ArrowDown" ? 1 : -1);
    if (next < 0) {
      activate(null);
      input.focus({ preventScroll: true });
    } else {
      const link = links[Math.min(next, links.length - 1)];
      activate(link);
      focusSearchElement(link);
    }
  });

  let persisted = false;
  try { persisted = localStorage.getItem("tola:search-details") === "true"; } catch { /* storage can be unavailable */ }
  setDetails(persisted);
})();
