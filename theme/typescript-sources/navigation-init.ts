// Embedded at the end of each navigation aside. Run while HTML is parsed so
// the first rendered sidebar already has its remembered groups, mode and scroll position.
import { restoreGroups, restorePanel, restoreSidebarScroll } from "./shared/navigation-state.ts";

const navigation = document.currentScript?.closest<HTMLElement>("aside");
if (navigation) {
  const sidebar = navigation.hasAttribute("data-navigation-base");
  if (sidebar) restoreGroups(navigation);
  const panel = navigation.querySelector<HTMLDetailsElement>("[data-navigation-panel]");
  if (panel) {
    restorePanel(panel);
    if (sidebar && panel.hasAttribute("data-navigation-expanded")) restoreSidebarScroll(navigation);
  }
}
