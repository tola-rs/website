import { appendHighlights, queryPattern } from "./search-highlight.ts";

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
};

export function previewLink(value: string, base: URL): URL | null {
  try {
    const url = new URL(value, base);
    return ["http:", "https:", "mailto:"].includes(url.protocol) ? url : null;
  } catch {
    return null;
  }
}

/** Keep media URLs inert and preserve the site's deployment path. */
export function previewImageUrl(value: string, base: URL): string | null {
  try {
    const url = new URL(value, base);
    if (!value.trim() || !["http:", "https:"].includes(url.protocol) || url.username || url.password) return null;
    return url.origin === base.origin ? url.pathname + url.search + url.hash : url.href;
  } catch { return null; }
}

function previewText(node: PreviewNode): string {
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
function previewContext(nodes: PreviewNode[], pattern: RegExp | null): PreviewNode[] {
  const match = pattern ? nodes.findIndex(node => {
    pattern.lastIndex = 0;
    return pattern.test(previewText(node));
  }) : -1;
  if (pattern) pattern.lastIndex = 0;
  const start = Math.max(0, match - 1);
  return nodes.slice(start, start + 8);
}

// Allow only syntax-highlighting variables from @tola/code.
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

function append(nodes: PreviewNode[], target: ParentNode, pattern: RegExp | null, base: URL) {
  for (const node of nodes) {
    if (typeof node === "string") {
      appendHighlights(target, node, pattern);
      continue;
    }
    if (!previewTags.has(node.tag) && !previewMathTags.has(node.tag)) continue;
    const isImage = node.tag === "img";
    const isMath = previewMathTags.has(node.tag);
    const imageSrc = isImage ? previewImageUrl(node.attrs?.src ?? "", base) : null;
    if (isImage && !imageSrc) continue;
    const element = isMath
      ? document.createElementNS("http://www.w3.org/1998/Math/MathML", node.tag)
      : document.createElement(node.tag);
    for (const [name, value] of Object.entries(node.attrs ?? {})) {
      if (name === "href" && node.tag === "a") {
        const href = previewLink(value, base);
        if (href) element.setAttribute(name, href.href);
      } else if (name === "class" && (
        (node.tag === "pre" && value === "tola-code")
        || (node.tag === "div" && (value === "code-block" || value === "code-toolbar"))
        || (node.tag === "span" && value === "code-language")
      )) element.setAttribute("class", value);
      else if (["width", "height"].includes(name) && node.tag === "img" && /^[1-9]\d{0,4}$/.test(value)) element.setAttribute(name, value);
      else if (name === "data-lang" && node.tag === "code") element.setAttribute(name, value.slice(0, 40));
      else if (isMath && safeMathAttribute(name, value)) element.setAttribute(name, value);
      else if (["start", "value", "colspan", "rowspan"].includes(name) && /^-?\d{1,4}$/.test(value)) element.setAttribute(name, value);
    }
    if (node.tag === "span" && element instanceof HTMLElement) for (const [name, value] of Object.entries(node.tokens ?? {})) {
      if (safeCodeToken(name, value)) element.style.setProperty(name, value);
    }
    if (element instanceof HTMLImageElement && imageSrc) {
      element.loading = "lazy";
      element.decoding = "async";
      element.alt = node.attrs?.alt?.slice(0, 500) ?? "";
      element.src = imageSrc;
    }
    // HTML <mark> is invalid inside MathML; retain the native formula tree.
    append(node.children, element, isMath ? null : pattern, base);
    target.append(element);
  }
}

/** Load the matching section. The caller keeps its text excerpt on failure. */
export async function loadSearchPreview(previewUrl: string, anchor: string, query: string): Promise<DocumentFragment | null> {
  try {
    const base = new URL(location.href);
    const url = new URL(previewUrl, base);
    if (url.origin !== base.origin || !["http:", "https:"].includes(url.protocol)) return null;
    url.hash = "";
    const data = await loadPreview(url);
    const key = decodeURIComponent(anchor.replace(/^#/, ""));
    const nodes = data?.sections[key];
    if (!Array.isArray(nodes) || !nodes.length) return null;
    const fragment = document.createDocumentFragment();
    const pattern = queryPattern(query);
    append(previewContext(nodes, pattern), fragment, pattern, base);
    return fragment.textContent?.trim() || fragment.querySelector("img") ? fragment : null;
  } catch { return null; }
}
