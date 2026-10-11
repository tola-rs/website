// State restoration is shared by the parser-time bootstrap and deferred controls.
// Storage is origin-scoped; the deployment root separates sites on that origin,
// and logical group keys remain the same across translated documentation trees.

const navigationKey = (navigation: HTMLElement, state: string, logical: string) => {
  const base = new URL(navigation.dataset.navigationBase!, location.href).pathname;
  return `tola.navigation:${JSON.stringify([base, state, logical])}`;
};

export const navigationGroupKey = (navigation: HTMLElement, logical: string) =>
  navigationKey(navigation, "group", logical);

const sidebarScrollKey = (sidebar: HTMLElement) =>
  navigationKey(sidebar, "scroll", document.documentElement.lang);

export const restoreSidebarScroll = (sidebar: HTMLElement) => {
  try {
    const saved = sessionStorage.getItem(sidebarScrollKey(sidebar));
    if (saved !== null) sidebar.scrollTop = Number(saved);
  } catch { /* Scroll restoration is optional when storage is unavailable. */ }
};

export const saveSidebarScroll = (sidebar: HTMLElement, top: number) => {
  try { sessionStorage.setItem(sidebarScrollKey(sidebar), String(top)); }
  catch { /* Scroll restoration is optional when storage is unavailable. */ }
};

export const restoreGroups = (navigation: HTMLElement) => {
  for (const group of navigation.querySelectorAll<HTMLDetailsElement>("[data-navigation-group]")) {
    delete group.dataset.disclosureAnimate;
    try {
      const saved = localStorage.getItem(navigationGroupKey(navigation, group.dataset.navigationGroup!));
      if (saved !== "true" && saved !== "false") continue;
      if (saved === "false" && group.open && group.contains(document.activeElement)) {
        group.querySelector("summary")?.focus({ preventScroll: true });
      }
      group.open = saved === "true";
    } catch { /* Native disclosures also work without storage. */ }
  }
};

// CSS owns responsive breakpoints, including the different documentation TOC width.
export const panelIsExpanded = (panel: HTMLDetailsElement) =>
  getComputedStyle(panel).getPropertyValue("--navigation-expanded").trim() === "1";

export const restorePanel = (panel: HTMLDetailsElement, expanded = panelIsExpanded(panel)) => {
  const summary = panel.querySelector<HTMLElement>(":scope > summary");
  if (!summary) return;
  delete panel.dataset.disclosureAnimate;
  if (expanded) {
    panel.open = true;
    // A remembered-closed first group can hide its links, but its summary is visible.
    if (document.activeElement === summary) {
      panel.querySelector<HTMLElement>("nav a, nav summary")?.focus({ preventScroll: true });
    }
    panel.dataset.navigationExpanded = "";
  } else {
    delete panel.dataset.navigationExpanded;
    if (panel.contains(document.activeElement)) summary.focus({ preventScroll: true });
    panel.open = false;
  }
  panel.dataset.navigationInitialized = "";
};
