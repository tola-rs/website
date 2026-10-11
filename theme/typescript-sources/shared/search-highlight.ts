// Highlight query terms in plain search text without injecting markup.

export function queryPattern(query: string): RegExp | null {
  const terms = [...new Set(query.trim().split(/\s+/u).map(term => term.replace(/^["']+|["']+$/g, "")))]
    .filter(Boolean).slice(0, 10).sort((a, b) => b.length - a.length);
  return terms.length
    ? new RegExp(terms.map(term => term.slice(0, 80).replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|"), "giu")
    : null;
}

export function appendHighlights(target: ParentNode, text: string, pattern: RegExp | null) {
  let offset = 0;
  if (pattern) for (const match of text.matchAll(pattern)) {
    target.append(document.createTextNode(text.slice(offset, match.index)));
    const mark = document.createElement("mark");
    mark.textContent = match[0];
    target.append(mark);
    offset = match.index! + match[0].length;
  }
  target.append(document.createTextNode(text.slice(offset)));
}

export function searchHighlights(text: string, query: string): DocumentFragment {
  const fragment = document.createDocumentFragment();
  appendHighlights(fragment, text, queryPattern(query));
  return fragment;
}
