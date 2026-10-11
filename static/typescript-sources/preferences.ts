// Set platform and theme state once, before the first paint.
// components/head.typ embeds this script before loading stylesheets.

import { themeKey } from "./shared/preference-keys.ts";

(() => {
  const root = document.documentElement;
  root.classList.toggle("mac", /Mac|iPhone|iPad/.test(navigator.platform));

  const restoreTheme = () => {
    try {
      const theme = localStorage.getItem(themeKey);
      if (theme === "light" || theme === "dark") root.dataset.theme = theme;
      else delete root.dataset.theme;
    } catch { /* Browser storage is optional. Keep the current/system theme. */ }
  };
  restoreTheme();
  // History may restore a document older than a choice made on another page.
  // Ordinary pageshow does not repeat the parser-time initialization.
  addEventListener("pageshow", event => { if (event.persisted) restoreTheme(); });
})();
