// Add persistence, dismissal and focus handling to the native page controls.
// The theme follows the system until the reader saves an explicit light/dark choice.
// Sidebar contract: data-navigation-base is the deployed site-root URL;
// data-navigation-group contains language-free node keys.

import { themeKey } from "./shared/preference-keys.ts";
import { navigationGroupKey, restoreGroups } from "./shared/navigation-state.ts";

(() => {
  const root = document.documentElement;
  const save = (key: string, value: string) => {
    try { localStorage.setItem(key, value); } catch { /* Preferences also work without storage. */ }
  };
  for (const button of document.querySelectorAll<HTMLButtonElement>("[data-theme-toggle]")) {
    // Native button activation includes Enter and Space; no extra keyboard handler.
    button.addEventListener("click", () => {
      const dark = root.dataset.theme === "dark"
        || !root.dataset.theme && matchMedia("(prefers-color-scheme: dark)").matches;
      const theme = dark ? "light" : "dark";
      root.dataset.theme = theme;
      save(themeKey, theme);
    });
    button.disabled = false;
  }

  for (const navigation of document.querySelectorAll<HTMLElement>("[data-navigation-base]")) {
    // Attribute observations run before the next task. The queued/coalesced toggle event
    // can arrive after restoration or navigation, so it cannot identify a reader's change.
    const observer = new MutationObserver(records => {
      for (const record of records) {
        const disclosure = record.target as HTMLDetailsElement;
        if (disclosure.dataset.navigationGroup) {
          save(navigationGroupKey(navigation, disclosure.dataset.navigationGroup), String(disclosure.open));
        }
      }
    });
    const restoreNavigation = () => {
      // A cached history page can contain older DOM state; discard its pending records
      // before reading current choices, without saving that snapshot over newer choices.
      observer.disconnect();
      restoreGroups(navigation);
      // Restoring a group must never become a saved reader choice.
      observer.observe(navigation, { subtree: true, attributeFilter: ["open"] });
    };
    restoreNavigation();
    addEventListener("pageshow", event => { if (event.persisted) restoreNavigation(); });
  }

  // Native summary activation includes mouse, touch, Enter and Space. Only these
  // reader actions opt into animation; restoration and responsive changes do not.
  document.addEventListener("click", event => {
    const summary = event.target instanceof Element ? event.target.closest("summary") : null;
    const disclosure = summary?.parentElement;
    if (disclosure instanceof HTMLDetailsElement) disclosure.dataset.disclosureAnimate = "";
  });

  // Enhance language menu dismissal; HTML owns the disclosure state.
  const menus = [...document.querySelectorAll<HTMLDetailsElement>("[data-header-menu]")];
  const dismissOutside = (event: Event) => {
    menus.forEach(menu => { if (!menu.contains(event.target as Node | null)) menu.open = false; });
  };
  document.addEventListener("pointerdown", dismissOutside);
  document.addEventListener("focusin", dismissOutside);
  document.addEventListener("keydown", event => {
    if (event.key !== "Escape") return;
    const menu = menus.find(menu => menu.open);
    if (menu) {
      event.preventDefault();
      menu.open = false;
      menu.querySelector("summary")?.focus();
    }
  });

  // VitePress's language flyout opens immediately on mouse entry and absorbs
  // the click that follows, so hovering then clicking does not close it.
  const canHover = matchMedia("(hover: hover) and (pointer: fine)");
  for (const menu of menus.filter(menu => menu.hasAttribute("data-hover-menu"))) {
    const summary = menu.querySelector("summary");
    let closeTimer = 0;
    let openedByHover = false;
    const close = () => {
      menu.open = false;
      openedByHover = false;
    };
    summary?.addEventListener("pointerenter", event => {
      if (!canHover.matches || event.pointerType !== "mouse" || menu.open) return;
      clearTimeout(closeTimer);
      menu.open = true;
      menu.dataset.disclosureAnimate = "";
      openedByHover = true;
    });
    summary?.addEventListener("click", event => {
      if (!openedByHover) return;
      event.preventDefault();
      openedByHover = false;
    });
    menu.addEventListener("pointerenter", event => {
      if (event.pointerType === "mouse") clearTimeout(closeTimer);
    });
    menu.addEventListener("pointerleave", event => {
      if (!canHover.matches || event.pointerType !== "mouse") return;
      clearTimeout(closeTimer);
      if (menu.contains(event.relatedTarget as Node | null)) return;
      // The panel is 8px below the trigger; keep the menu open while crossing it.
      closeTimer = window.setTimeout(close, 60);
    });
    menu.addEventListener("toggle", () => { if (!menu.open) openedByHover = false; });
  }
})();
