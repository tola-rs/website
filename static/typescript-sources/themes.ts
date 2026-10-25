const input = document.querySelector<HTMLInputElement>("[data-theme-search]");
const cards = Array.from(document.querySelectorAll<HTMLElement>("[data-theme-card]"));
const count = document.querySelector<HTMLElement>("[data-theme-count]");
const empty = document.querySelector<HTMLElement>("[data-theme-empty]");

function applyFilter(): void {
  if (!input) return;

  const query = input.value.trim().toLowerCase();
  let visible = 0;

  for (const card of cards) {
    const match = query === "" || (card.dataset.search ?? "").toLowerCase().includes(query);
    card.hidden = !match;
    if (match) visible += 1;
  }

  if (count) {
    const template = count.dataset.template ?? "{count}";
    count.textContent = template.replace("{count}", String(visible));
  }

  if (empty) empty.hidden = visible !== 0;
}

if (input && cards.length > 0) {
  applyFilter();
  input.addEventListener("input", applyFilter);
}
