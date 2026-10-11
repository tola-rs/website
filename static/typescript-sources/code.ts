// Code and icons stay static; enable keyboard scrolling only when a block overflows.
if (typeof ResizeObserver !== "undefined") {
  const scrollRegions = new WeakMap<Element, HTMLElement>();
  const updateScrollRegion = (pre: HTMLElement) => {
    if (pre.scrollWidth > pre.clientWidth) {
      pre.setAttribute("tabindex", "0");
      pre.setAttribute("role", "region");
      pre.setAttribute("aria-label", pre.dataset.codeLabel ?? "");
    } else {
      pre.removeAttribute("tabindex");
      pre.removeAttribute("role");
      pre.removeAttribute("aria-label");
    }
  };
  const observer = new ResizeObserver((entries) => {
    const changed = new Set<HTMLElement>();
    for (const entry of entries) {
      const pre = scrollRegions.get(entry.target);
      if (pre) changed.add(pre);
    }
    for (const pre of changed) updateScrollRegion(pre);
  });
  for (const pre of document.querySelectorAll<HTMLElement>("pre[data-code-label]")) {
    scrollRegions.set(pre, pre);
    observer.observe(pre);
    // The inner code width can change when fonts load without resizing the viewport.
    const code = pre.querySelector("code");
    if (code) {
      scrollRegions.set(code, pre);
      observer.observe(code);
    }
  }
}

// Clipboard availability is independent of keyboard scrolling.
for (const button of document.querySelectorAll<HTMLButtonElement>("[data-copy-code]")) {
  const block = button.closest(".code-block");
  const code = block?.querySelector<HTMLElement>("pre > code");
  const status = block?.querySelector<HTMLElement>("[data-copy-status]");
  if (!code || !status || !navigator.clipboard?.writeText) continue;
  button.hidden = false;
  let reset: number | undefined;
  button.addEventListener("click", async () => {
    clearTimeout(reset);
    button.disabled = true;
    delete button.dataset.state;
    try {
      await navigator.clipboard.writeText(code.textContent ?? "");
      button.dataset.state = "copied";
      status.textContent = button.dataset.copiedLabel ?? "";
    } catch {
      button.dataset.state = "error";
      status.textContent = button.dataset.copyError ?? "";
    } finally {
      button.disabled = false;
      button.title = status.textContent ?? "";
      button.setAttribute("aria-label", button.title);
      reset = window.setTimeout(() => {
        delete button.dataset.state;
        button.title = button.dataset.copyLabel ?? "";
        button.setAttribute("aria-label", button.title);
        status.textContent = "";
      }, 2000);
    }
  });
}
