// Warm nearby document responses after load; explicit intent takes queue priority.
// Native navigation remains unchanged, and prefetch never executes the fetched HTML.
(() => {
  const prefetched = new Set<string>();
  const pending: string[] = [];
  let active = 0;
  const connection = (navigator as Navigator & {
    connection?: { saveData?: boolean; effectiveType?: string };
  }).connection;
  const canPrefetch = () => navigator.onLine && !connection?.saveData
    && !/2g/.test(connection?.effectiveType ?? "");

  const pageURL = (anchor: HTMLAnchorElement): string | undefined => {
    if (!anchor.isConnected || anchor.hasAttribute("download") || anchor.dataset.prefetch === "false"
      || (anchor.target && anchor.target !== "_self") || anchor.relList.contains("external")) return;
    let url: URL;
    try { url = new URL(anchor.href); } catch { return; }
    if (!/^https?:$/.test(url.protocol) || url.origin !== location.origin) return;
    if (url.pathname === location.pathname && url.search === location.search) return;
    // Directory/extensionless routes and HTML files are documents; assets and feeds are not.
    const filename = url.pathname.slice(url.pathname.lastIndexOf("/") + 1);
    if (filename.includes(".") && !/\.html?$/i.test(filename)) return;
    url.hash = "";
    return url.href;
  };

  const drain = () => {
    while (active < 3 && pending.length && canPrefetch()) {
      const url = pending.shift()!;
      prefetched.add(url);
      active++;
      fetch(url, { priority: "low" }).then(async response => {
        // Hold the slot until the body finishes, not just until headers arrive.
        await response.arrayBuffer();
        if (!response.ok) prefetched.delete(url);
      }).catch(() => { prefetched.delete(url); }).finally(() => {
        active--;
        drain();
      });
    }
  };

  const prefetch = (anchor: HTMLAnchorElement, priority = false) => {
    if (!canPrefetch()) return;
    const url = pageURL(anchor);
    if (!url || prefetched.has(url)) return;
    const queued = pending.indexOf(url);
    if (queued !== -1) {
      if (!priority) return;
      pending.splice(queued, 1);
    }
    if (priority) pending.unshift(url);
    else pending.push(url);
    drain();
  };

  const onIntent = (event: PointerEvent | FocusEvent) => {
    if (event instanceof PointerEvent) {
      if (event.type === "pointerover" && event.pointerType === "touch") return;
      if (event.type === "pointerdown" && (!event.isPrimary || event.button !== 0)) return;
    }
    const anchor = event.target instanceof Element
      ? event.target.closest<HTMLAnchorElement>("a[href]") : null;
    if (!anchor || (event.relatedTarget instanceof Node && anchor.contains(event.relatedTarget))) return;
    prefetch(anchor, true);
  };

  for (const event of ["pointerover", "focusin", "pointerdown"] as const) {
    document.addEventListener(event, onIntent, { passive: true });
  }

  const watchNearbyLinks = () => {
    const observer = new IntersectionObserver(entries => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        prefetch(entry.target as HTMLAnchorElement);
        observer.unobserve(entry.target);
      }
    }, { rootMargin: "200px 0px" });
    const observe = (anchor: HTMLAnchorElement) => {
      const url = pageURL(anchor);
      if (url && !prefetched.has(url)) observer.observe(anchor);
    };
    const observeWithin = (root: Element | Document) => {
      if (root instanceof HTMLAnchorElement) observe(root);
      for (const anchor of root.querySelectorAll<HTMLAnchorElement>("a[href]")) observe(anchor);
    };
    observeWithin(document);
    // Search adds new links after load; inspect only added subtrees.
    new MutationObserver(records => {
      for (const record of records) {
        for (const node of record.addedNodes) {
          if (node instanceof Element) observeWithin(node);
        }
      }
    }).observe(document.body, { childList: true, subtree: true });
  };
  if (document.readyState === "complete") watchNearbyLinks();
  else addEventListener("load", watchNearbyLinks, { once: true });
})();
