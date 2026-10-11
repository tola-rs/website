// Native disclosures provide the mobile navigation; desktop panels stay expanded.
// Only the outer panels follow viewport changes. Inner group preferences belong
// to controls.ts and are never changed here.

import { panelIsExpanded, restorePanel } from "./shared/navigation-state.ts";

(() => {
  for (const panel of document.querySelectorAll<HTMLDetailsElement>("[data-navigation-panel]")) {
    const summary = panel.querySelector<HTMLElement>(":scope > summary");
    if (!summary) continue;
    let desktop = panelIsExpanded(panel);
    const moveToSummary = () => {
      if (panel.contains(document.activeElement)) summary.focus({ preventScroll: true });
    };
    const setViewportState = (restore = false) => {
      const expanded = panelIsExpanded(panel);
      if (!restore && desktop === expanded) return;
      desktop = expanded;
      restorePanel(panel);
    };
    if (!panel.hasAttribute("data-navigation-initialized")) restorePanel(panel);
    addEventListener("resize", () => setViewportState());
    // A restored history document can retain a panel state from another width.
    addEventListener("pageshow", event => { if (event.persisted) setViewportState(true); });

    panel.addEventListener("keydown", event => {
      if (event.key !== "Escape" || desktop || !panel.open) return;
      event.preventDefault();
      event.stopPropagation();
      moveToSummary();
      panel.open = false;
    });
    panel.addEventListener("click", event => {
      if (desktop || panel.dataset.navigationPanel !== "toc" || event.defaultPrevented
        || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      const link = event.target instanceof Element
        ? event.target.closest<HTMLAnchorElement>('a[href^="#"]') : null;
      if (!link) return;
      let id: string;
      try { id = decodeURIComponent(link.hash.slice(1)); } catch { return; }
      const heading = document.getElementById(id);
      if (!heading) return;
      // Collapse before native fragment scrolling measures the destination. Move
      // keyboard focus to it so the next Tab continues from the selected section.
      panel.open = false;
      if (!heading.hasAttribute("tabindex")) {
        heading.setAttribute("tabindex", "-1");
        heading.addEventListener("blur", () => heading.removeAttribute("tabindex"), { once: true });
      }
      heading.focus({ preventScroll: true });
    });
  }
})();
