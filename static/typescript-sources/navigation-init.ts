// Embedded at the end of each navigation aside. Run while HTML is parsed so
// the first rendered sidebar already has its remembered groups and desktop mode.
import { restoreGroups, restorePanel } from "./shared/navigation-state.ts";

const navigation = document.currentScript?.closest<HTMLElement>("aside");
if (navigation) {
  if (navigation.hasAttribute("data-navigation-base")) restoreGroups(navigation);
  const panel = navigation.querySelector<HTMLDetailsElement>("[data-navigation-panel]");
  if (panel) restorePanel(panel);
}
