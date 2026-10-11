// Build-time previews preserve rendered structure; the browser only selects an
// exact section, creates safe DOM nodes and highlights the current query.
export const previewTags = new Set("h1 h2 h3 h4 h5 h6 p pre code span div ul ol li blockquote table caption thead tbody tfoot tr th td a dl dt dd em strong b i s del small sup sub kbd samp var br hr abbr time mark figure figcaption img".split(" "));
export const previewMathTags = new Set("math mrow mi mn mo mtext mspace ms mfrac msqrt mroot mstyle msub msup msubsup munder mover munderover mmultiscripts mprescripts none mtable mtr mtd".split(" "));
export type PreviewNode = string | {
  tag: string;
  attrs?: Record<string, string>;
  tokens?: Record<string, string>;
  children: PreviewNode[];
};
export type SearchPreviews = {
  sections: Record<string, PreviewNode[]>;
  parents?: Record<string, string[]>;
};

/** Keep media URLs inert and preserve the site's deployment path. */
export function previewImageUrl(value: string, base: URL): string | null {
  try {
    const url = new URL(value, base);
    if (!value.trim() || !["http:", "https:"].includes(url.protocol) || url.username || url.password) return null;
    return url.origin === base.origin ? url.pathname + url.search + url.hash : url.href;
  } catch { return null; }
}

export function previewText(node: PreviewNode): string {
  return typeof node === "string" ? node : (node.attrs?.alt ?? "") + node.children.map(previewText).join("");
}

export function safeMathAttribute(name: string, value: string): boolean {
  if (name === "display") return ["inline", "block"].includes(value);
  if (["displaystyle", "stretchy", "fence", "separator", "largeop", "movablelimits", "accent", "accentunder"].includes(name)) return /^(true|false)$/.test(value);
  if (["columnalign", "rowalign"].includes(name)) return /^(?:(?:left|center|right|top|bottom|baseline|axis)\s*)+$/.test(value);
  if (["columnspacing", "rowspacing", "width", "height", "depth", "lspace", "rspace", "linethickness"].includes(name)) return /^(?:\d*\.?\d+(?:em|ex|px|pt|%)?\s*)+$/.test(value);
  return name === "scriptlevel" && /^[+-]?\d$/.test(value);
}

/** Center the preview on the matching block instead of always showing the intro. */
export function previewContext(nodes: PreviewNode[], query: string): PreviewNode[] {
  const pattern = queryPattern(query);
  const match = pattern ? nodes.findIndex(node => {
    pattern.lastIndex = 0;
    return pattern.test(previewText(node));
  }) : -1;
  const start = Math.max(0, match - 1);
  return nodes.slice(start, start + 8);
}

// These are the variables @tola/code emits on its syntax spans. They are the
// only inline styles carried by a preview; arbitrary CSS never enters the DOM.
export function safeCodeToken(property: string, value: string): boolean {
  const kind = property.match(/^--tola-code-(?:dark-)?(color|weight|style|decoration)$/)?.[1];
  if (kind === "color") return /^(?:#[\da-f]{3,8}|[a-z]+|(?:rgb|hsl)a?\([\d\s.,%/+-]+\))$/i.test(value);
  if (kind === "weight") return /^(?:normal|bold|[1-9]\d{0,2}|1000)$/.test(value);
  if (kind === "style") return /^(?:normal|italic|oblique)$/.test(value);
  return kind === "decoration" && /^(?:(?:none|underline|overline|line-through)\s*)+$/.test(value);
}

const cache = new Map<string, Promise<SearchPreviews | null>>();

async function loadPreview(url: URL): Promise<SearchPreviews | null> {
  const key = url.href;
  const cached = cache.get(key);
  if (cached) return cached;
  const pending = fetch(key, { credentials: "same-origin", redirect: "error" })
    .then(async response => response.ok ? await response.json() as SearchPreviews : null)
    .catch(() => null);
  cache.set(key, pending);
  if (cache.size > 8) cache.delete(cache.keys().next().value!);
  const data = await pending;
  if (!data && cache.get(key) === pending) cache.delete(key);
  return data;
}

function append(nodes: PreviewNode[], target: ParentNode, pattern: RegExp | null) {
  for (const node of nodes) {
    if (typeof node === "string") {
      let offset = 0;
      if (pattern) for (const match of node.matchAll(pattern)) {
        target.append(document.createTextNode(node.slice(offset, match.index)));
        const mark = document.createElement("mark");
        mark.textContent = match[0];
        target.append(mark);
        offset = match.index! + match[0].length;
      }
      target.append(document.createTextNode(node.slice(offset)));
      continue;
    }
    if (!previewTags.has(node.tag) && !previewMathTags.has(node.tag)) continue;
    if (node.tag === "img" && !previewImageUrl(node.attrs?.src ?? "", new URL(location.href))) continue;
    const element = previewMathTags.has(node.tag)
      ? document.createElementNS("http://www.w3.org/1998/Math/MathML", node.tag)
      : document.createElement(node.tag);
    for (const [name, value] of Object.entries(node.attrs ?? {})) {
      if (name === "href" && node.tag === "a") {
        try {
          const href = new URL(value, location.href);
          if (["http:", "https:", "mailto:"].includes(href.protocol)) element.setAttribute(name, href.href);
        } catch { /* Invalid links retain their readable text. */ }
      } else if (name === "class" && (
        (node.tag === "pre" && value === "tola-code")
        || (node.tag === "div" && (value === "code-block" || value === "code-toolbar"))
        || (node.tag === "span" && value === "code-language")
      )) element.setAttribute("class", value);
      else if (name === "src" && node.tag === "img") element.setAttribute(name, previewImageUrl(value, new URL(location.href))!);
      else if (name === "alt" && node.tag === "img") element.setAttribute(name, value.slice(0, 500));
      else if (["width", "height"].includes(name) && node.tag === "img" && /^[1-9]\d{0,4}$/.test(value)) element.setAttribute(name, value);
      else if (name === "data-lang" && node.tag === "code") element.setAttribute(name, value.slice(0, 40));
      else if (previewMathTags.has(node.tag) && safeMathAttribute(name, value)) element.setAttribute(name, value);
      else if (["start", "value", "colspan", "rowspan"].includes(name) && /^-?\d{1,4}$/.test(value)) element.setAttribute(name, value);
    }
    if (node.tag === "span" && element instanceof HTMLElement) for (const [name, value] of Object.entries(node.tokens ?? {})) {
      if (safeCodeToken(name, value)) element.style.setProperty(name, value);
    }
    if (element instanceof HTMLImageElement) {
      element.loading = "lazy";
      element.decoding = "async";
      element.alt = node.attrs?.alt?.slice(0, 500) ?? "";
    }
    // HTML <mark> is invalid inside MathML; retain the native formula tree.
    append(node.children, element, previewMathTags.has(node.tag) ? null : pattern);
    target.append(element);
  }
}

function queryPattern(query: string): RegExp | null {
  const terms = [...new Set(query.trim().split(/\s+/u).map(term => term.replace(/^["']+|["']+$/g, "")))]
    .filter(Boolean).slice(0, 10).sort((a, b) => b.length - a.length);
  return terms.length ? new RegExp(terms.map(term => term.slice(0, 80).replace(/[.*+?^${}()|[\]\\]/g, "\\$&")).join("|"), "giu") : null;
}

/** The same safe query marking is used for titles, breadcrumbs and rich text. */
export function searchHighlights(text: string, query: string): DocumentFragment {
  const fragment = document.createDocumentFragment();
  append([text], fragment, queryPattern(query));
  return fragment;
}

/** Load a build-generated sidecar lazily. The caller keeps its safe excerpt if
 * the requested section is unavailable; its result title supplies the heading.
 */
export async function loadSearchPreview(previewUrl: string, anchor: string, query: string): Promise<{
  content: DocumentFragment;
  parents: string[];
} | null> {
  try {
    const url = new URL(previewUrl, location.href);
    if (url.origin !== location.origin || !["http:", "https:"].includes(url.protocol)) return null;
    url.hash = "";
    const data = await loadPreview(url);
    const key = decodeURIComponent(anchor.replace(/^#/, ""));
    const nodes = data?.sections[key];
    if (!Array.isArray(nodes) || !nodes.length) return null;
    const fragment = document.createDocumentFragment();
    append(previewContext(nodes, query), fragment, queryPattern(query));
    return fragment.textContent?.trim() || fragment.querySelector("img")
      ? { content: fragment, parents: data?.parents?.[key] ?? [] } : null;
  } catch { return null; }
}
