// Track the active heading in the outline rendered by components/toc.typ.
// Native fragment links still navigate; this script adds highlighting and local scrolling.

(() => {
  // Scroll spy for the page outline, following VitePress's approach:
  // a click pins its own entry and the jump's own scroll update is ignored;
  // scrolling otherwise highlights the last heading past its scroll margin;
  // the end of the page highlights the last entry. Pure enhancement; without
  // scripts the TOC stays unchanged.
  const toc = document.querySelector<HTMLElement>(".page-toc");
  if (!toc) return;
  // Address-bar fragments can contain invalid percent escapes.
  const decodeHash = (hash: string): string | null => {
    try { return decodeURIComponent(hash.slice(1)); } catch { return null; }
  };
  type Entry = { link: HTMLAnchorElement; heading: HTMLElement; activationOffset: number };
  const entries: Entry[] = [...toc.querySelectorAll<HTMLAnchorElement>('a[href^="#"]')].flatMap((link) => {
    const id = decodeHash(link.hash);
    const heading = id === null ? null : document.getElementById(id);
    return heading ? [{ link, heading, activationOffset: 0 }] : [];
  });
  if (!entries.length) return;
  let isSticky = false;
  const measure = () => {
    isSticky = getComputedStyle(toc).position === "sticky";
    for (const entry of entries) {
      // A jump lands the heading on its scroll margin; count it from there.
      entry.activationOffset = (Number.parseFloat(getComputedStyle(entry.heading).scrollMarginTop) || 0) + 4;
    }
  };
  let active: Entry | undefined;
  let pinnedUntil = 0;
  const activate = (entry: Entry) => {
    if (entry === active) return;
    active?.link.removeAttribute("aria-current");
    entry.link.setAttribute("aria-current", "true");
    active = entry;
    // Keep the entry visible inside the sticky outline, never the page.
    if (isSticky) {
      const box = toc.getBoundingClientRect();
      const link = entry.link.getBoundingClientRect();
      const top = box.top + toc.clientTop;
      const bottom = top + toc.clientHeight;
      if (link.top < top) toc.scrollTop += link.top - top;
      else if (link.bottom > bottom) toc.scrollTop += link.bottom - bottom;
    }
  };
  // Clicking a link (or any hash change) pins that entry; the scroll updates
  // produced by the jump are ignored, so sections that are too short to reach
  // the line still highlight when they are requested.
  const pin = (hash: string) => {
    const id = decodeHash(hash);
    if (id === null) return;
    const entry = entries.find(({ heading }) => heading.id === id);
    if (!entry) return;
    pinnedUntil = performance.now() + 200;
    activate(entry);
  };
  const update = () => {
    if (performance.now() < pinnedUntil) return;
    const page = document.scrollingElement ?? document.documentElement;
    const gap = page.scrollHeight - page.scrollTop - page.clientHeight;
    let next = entries[0];
    if (page.scrollHeight - page.clientHeight > 4 && gap < 2) {
      // Bottom of the page: the last entry is the current one even if its
      // heading never reached the line.
      next = entries[entries.length - 1];
    } else {
      for (const entry of entries) {
        if (entry.heading.getBoundingClientRect().top <= entry.activationOffset) next = entry;
        else break;
      }
    }
    activate(next);
  };
  toc.addEventListener("click", (event) => {
    // Modified clicks open another browsing context rather than moving this page.
    if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    const link = event.target instanceof Element ? event.target.closest<HTMLAnchorElement>('a[href^="#"]') : null;
    if (link) pin(link.hash);
  });
  addEventListener("hashchange", () => pin(location.hash));
  addEventListener("scroll", update, { passive: true });
  addEventListener("resize", () => { measure(); update(); });
  measure();
  if (location.hash) pin(location.hash);
  update();
})();
