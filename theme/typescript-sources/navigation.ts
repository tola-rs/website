// Resize the outer panels. controls.ts saves the inner disclosure choices.
import { panelIsExpanded, restorePanel, restoreSidebarScroll, saveSidebarScroll } from "./shared/navigation-state.ts";

(() => {
  for (const panel of document.querySelectorAll<HTMLDetailsElement>("[data-navigation-panel]")) {
    const summary = panel.querySelector<HTMLElement>(":scope > summary");
    if (!summary) continue;
    const sidebar = panel.closest<HTMLElement>("[data-navigation-base]");
    const sidebarColumn = sidebar?.closest<HTMLElement>(".docs-sidebar-column");
    let desktop = panelIsExpanded(panel);
    let sidebarScroll = desktop ? sidebar?.scrollTop : undefined;
    const fitSidebar = () => {
      if (!desktop || !sidebarColumn) return;
      // Keep the scroller visible when the footer pushes the sticky column up.
      const { top, height } = sidebarColumn.getBoundingClientRect();
      const stickyTop = Number.parseFloat(getComputedStyle(sidebarColumn).top);
      const inset = `${Math.min(height, Math.max(0, stickyTop - top))}px`;
      if (sidebarColumn.style.getPropertyValue("--docs-sidebar-inset") !== inset) {
        sidebarColumn.style.setProperty("--docs-sidebar-inset", inset);
      }
    };
    const moveToSummary = () => {
      if (panel.contains(document.activeElement)) summary.focus({ preventScroll: true });
    };
    const setViewportState = (restore = false) => {
      const expanded = panelIsExpanded(panel);
      const enteringDesktop = expanded && !desktop;
      if (!restore && desktop === expanded) {
        fitSidebar();
        return;
      }
      desktop = expanded;
      restorePanel(panel, expanded);
      fitSidebar();
      if (sidebar && enteringDesktop) {
        if (sidebarScroll === undefined) restoreSidebarScroll(sidebar);
        else sidebar.scrollTop = sidebarScroll;
      }
    };
    if (!panel.hasAttribute("data-navigation-initialized")) restorePanel(panel, desktop);
    addEventListener("resize", () => setViewportState());
    // A restored history document can retain a panel state from another width.
    addEventListener("pageshow", event => {
      if (event.persisted) setViewportState(true);
      else fitSidebar();
    });
    if (sidebarColumn?.parentElement) {
      const observer = new ResizeObserver(fitSidebar);
      observer.observe(sidebarColumn.parentElement);
      addEventListener("scroll", fitSidebar, { passive: true });
      fitSidebar();
    }
    if (sidebar) {
      // The sidebar loses its scroll box on narrow screens. Keep the last desktop offset.
      sidebar.addEventListener("scroll", () => { if (desktop) sidebarScroll = sidebar.scrollTop; });
      addEventListener("pagehide", () => {
        if (desktop) sidebarScroll = sidebar.scrollTop;
        if (sidebarScroll !== undefined) saveSidebarScroll(sidebar, sidebarScroll);
      });
    }

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
      // Close before the fragment jump, then continue tabbing from the heading.
      panel.open = false;
      if (!heading.hasAttribute("tabindex")) {
        heading.setAttribute("tabindex", "-1");
        heading.addEventListener("blur", () => heading.removeAttribute("tabindex"), { once: true });
      }
      heading.focus({ preventScroll: true });
    });
  }
})();
