// Highlight query terms in plain search text without injecting markup.

function queryPattern(query: string): RegExp | null {
  const terms = [...new Set(query.trim().split(/\s+/u).map(term => term.replace(/^["']+|["']+$/g, "")))]
    .filter(Boolean).slice(0, 10).sort((a, b) => b.length - a.length);
  return terms.length
    ? new RegExp(terms.map(term => term.slice(0, 80).replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|"), "giu")
    : null;
}

export function searchHighlights(text: string, query: string): DocumentFragment {
  const fragment = document.createDocumentFragment();
  const pattern = queryPattern(query);
  let offset = 0;
  if (pattern) for (const match of text.matchAll(pattern)) {
    fragment.append(document.createTextNode(text.slice(offset, match.index)));
    const mark = document.createElement("mark");
    mark.textContent = match[0];
    fragment.append(mark);
    offset = match.index! + match[0].length;
  }
  fragment.append(document.createTextNode(text.slice(offset)));
  return fragment;
}
