import { themeKey } from "./shared/preference-keys.ts";
import { navigationGroupKey, restoreGroups } from "./shared/navigation-state.ts";

(() => {
  const root = document.documentElement;
  // Scroll can leave a stationary pointer over a preview as its anchor moves.
  document.addEventListener("scroll", () => {
    root.toggleAttribute("data-link-preview-scrolled", true);
  }, { capture: true, passive: true });
  document.addEventListener("pointermove", () => {
    root.removeAttribute("data-link-preview-scrolled");
  }, { passive: true });

  const save = (key: string, value: string) => {
    try { localStorage.setItem(key, value); } catch { /* Preferences also work without storage. */ }
  };
  for (const button of document.querySelectorAll<HTMLButtonElement>("[data-theme-toggle]")) {
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
    // A queued toggle event can arrive after the browser restores a page.
    const observer = new MutationObserver(records => {
      for (const record of records) {
        const disclosure = record.target as HTMLDetailsElement;
        if (disclosure.dataset.navigationGroup) {
          save(navigationGroupKey(navigation, disclosure.dataset.navigationGroup), String(disclosure.open));
        }
      }
    });
    const restoreNavigation = () => {
      // Drop pending mutations from the history snapshot before restoring saved choices.
      observer.disconnect();
      restoreGroups(navigation);
      observer.observe(navigation, { subtree: true, attributeFilter: ["open"] });
    };
    restoreNavigation();
    addEventListener("pageshow", event => { if (event.persisted) restoreNavigation(); });
  }

  // Animate reader actions on summaries, including keyboard activation.
  document.addEventListener("click", event => {
    const summary = event.target instanceof Element ? event.target.closest("summary") : null;
    const disclosure = summary?.parentElement;
    if (disclosure instanceof HTMLDetailsElement) disclosure.dataset.disclosureAnimate = "";
  });

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

  // Consume the first click after hover opens the menu.
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
      // Give the pointer time to cross the gap below the trigger.
      closeTimer = window.setTimeout(close, 60);
    });
    menu.addEventListener("toggle", () => { if (!menu.open) openedByHover = false; });
  }
})();
