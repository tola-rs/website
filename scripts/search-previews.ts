// Produce rich search sections from Tola's rendered HTML, once at build time.
// Typst already owns headings, anchors, code languages and syntax token styles.
import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import { dirname, join, relative, resolve, sep } from "node:path";
import { parse, type DefaultTreeAdapterMap } from "parse5";
import { previewTags, previewMathTags, previewImageUrl, previewText, safeCodeToken, safeMathAttribute, type PreviewNode, type SearchPreviews } from "../static/typescript-sources/shared/search-preview.ts";

type Node = DefaultTreeAdapterMap["node"];
type Element = DefaultTreeAdapterMap["element"];
const excluded = new Set("script style template noscript nav header footer form button input select textarea iframe object embed svg source video audio canvas dialog annotation annotation-xml".split(" "));
const blocks = new Set("p pre ul ol blockquote table dl figure img math".split(" "));
const attr = (node: Element, name: string) => node.attrs.find(value => value.name === name)?.value;
const hasClass = (node: Element, name: string) => (attr(node, "class") ?? "").split(/\s+/).includes(name);
const headingLevel = (node: Element) => /^h[1-6]$/.test(node.tagName) ? Number(node.tagName[1]) : 0;
const ignored = (node: Element) => excluded.has(node.tagName) || (node.tagName === "aside" && !hasClass(node, "callout")) || attr(node, "hidden") !== undefined
  || attr(node, "aria-hidden") === "true" || attr(node, "data-pagefind-ignore") !== undefined
  || attr(node, "data-search-preview-ignore") !== undefined
  || /(?:^|;)\s*(?:display\s*:\s*none|visibility\s*:\s*hidden)\s*(?:;|$)/i.test(attr(node, "style") ?? "");

function find(node: Node, predicate: (element: Element) => boolean): Element | undefined {
  if ("tagName" in node && predicate(node)) return node;
  if ("childNodes" in node) for (const child of node.childNodes) {
    const found = find(child, predicate);
    if (found) return found;
  }
}

function collect(node: Node, content: Element[]) {
  if ("tagName" in node) {
    if (ignored(node)) return;
    if (headingLevel(node) || blocks.has(node.tagName) || hasClass(node, "callout") || hasClass(node, "code-block") || attr(node, "data-search-preview-label") !== undefined) {
      content.push(node);
      return;
    }
  }
  if ("childNodes" in node) node.childNodes.forEach(child => collect(child, content));
}

function copy(node: Node, base: URL, budget: { remaining: number }): PreviewNode[] {
  if (budget.remaining <= 0) return [];
  if (node.nodeName === "#text") {
    const text = (node as DefaultTreeAdapterMap["textNode"]).value.slice(0, budget.remaining);
    budget.remaining -= text.length;
    return [text];
  }
  if (!("tagName" in node) || ignored(node)) return [];
  const children = () => node.childNodes.flatMap(child => copy(child, base, budget));
  const previewLabel = attr(node, "data-search-preview-label")?.trim().slice(0, 80);
  if (previewLabel) {
    return [
      { tag: "p", children: [{ tag: "strong", children: [previewLabel] }] },
      ...children(),
    ];
  }
  if (hasClass(node, "callout")) return [{ tag: "blockquote", children: children() }];
  if (hasClass(node, "code-block") || hasClass(node, "code-toolbar")) {
    return [{ tag: "div", attrs: { class: hasClass(node, "code-block") ? "code-block" : "code-toolbar" }, children: children() }];
  }
  if (!previewTags.has(node.tagName) && !previewMathTags.has(node.tagName)) return children();
  const attrs: Record<string, string> = {};
  if (node.tagName === "span" && hasClass(node, "code-language")) attrs.class = "code-language";
  if (previewMathTags.has(node.tagName)) for (const { name, value } of node.attrs) {
    if (safeMathAttribute(name, value)) attrs[name] = value;
  }
  if (node.tagName === "img") {
    // An empty alt marks a decorative image. A figure can still supply its
    // accessible description through the surrounding caption.
    let parent = node.parentNode;
    while (parent && "tagName" in parent && parent.tagName !== "figure") parent = parent.parentNode;
    if (attr(node, "alt") === "" && (!parent || !("tagName" in parent) || parent.tagName !== "figure")) return [];
    const src = previewImageUrl(attr(node, "src") ?? "", base);
    if (!src) return [];
    attrs.src = src;
    attrs.alt = (attr(node, "alt") ?? "").slice(0, 500);
    for (const name of ["width", "height"]) {
      const value = attr(node, name);
      if (value && /^[1-9]\d{0,4}$/.test(value)) attrs[name] = value;
    }
  }
  if (node.tagName === "a" && attr(node, "href") !== undefined) {
    try {
      const href = new URL(attr(node, "href")!, base);
      if (["http:", "https:", "mailto:"].includes(href.protocol)) {
        attrs.href = href.origin === base.origin ? href.pathname + href.search + href.hash : href.href;
      }
    } catch { /* Invalid links retain their readable text. */ }
  }
  if (node.tagName === "pre" && hasClass(node, "tola-code")) attrs.class = "tola-code";
  const language = node.tagName === "code" ? attr(node, "data-lang") : undefined;
  if (language) attrs["data-lang"] = language.slice(0, 40);
  const structural = node.tagName === "ol" ? ["start"] : node.tagName === "li" ? ["value"]
    : node.tagName === "th" || node.tagName === "td" ? ["colspan", "rowspan"] : [];
  for (const name of structural) {
    const value = attr(node, name);
    if (value && /^-?\d{1,4}$/.test(value)) attrs[name] = value;
  }
  const tokens: Record<string, string> = {};
  if (node.tagName === "span") for (const declaration of (attr(node, "style") ?? "").split(";")) {
    const index = declaration.indexOf(":");
    if (index < 0) continue;
    const name = declaration.slice(0, index).trim();
    const value = declaration.slice(index + 1).trim();
    if (safeCodeToken(name, value)) tokens[name] = value;
  }
  return [{ tag: node.tagName, ...(Object.keys(attrs).length ? { attrs } : {}),
    ...(Object.keys(tokens).length ? { tokens } : {}), children: children() }];
}

function hasContent(nodes: PreviewNode[]): boolean {
  return nodes.some(node => typeof node === "string" ? Boolean(node.trim()) : node.tag === "img" || hasContent(node.children));
}

/** Exact heading IDs key the sidecar. The empty key contains only the page intro. */
export function searchPreviews(html: string, output: string): SearchPreviews | null {
  const document = parse(html);
  const main = find(document, node => node.tagName === "main");
  const body = main && find(main, node => attr(node, "data-pagefind-body") !== undefined);
  if (!body) return null;
  const canonical = find(document, node => node.tagName === "link" && attr(node, "rel") === "canonical");
  const metadata = find(document, node => /\bpreview\[/.test(attr(node, "data-pagefind-meta") ?? ""));
  const previewPath = attr(metadata ?? body, "content") ?? "";
  const prefix = previewPath.includes("/assets/search-previews/") ? previewPath.split("/assets/search-previews/")[0] : "";
  const base = new URL(attr(canonical ?? body, "href") ?? prefix + "/" + output, "https://preview.invalid/");
  const content: Element[] = [];
  collect(body, content);
  const sections: Record<string, PreviewNode[]> = Object.create(null);
  const parents: Record<string, string[]> = Object.create(null);
  const section = (start: number, level: number) => {
    const nodes: PreviewNode[] = [];
    const budget = { remaining: 24000 };
    let count = 0;
    for (const block of content.slice(start)) {
      const rank = headingLevel(block);
      if (rank && (level === 0 || rank <= level)) break;
      const copied = copy(block, base, budget);
      if (!hasContent(copied)) continue;
      nodes.push(...copied);
      if (++count >= 32 || budget.remaining <= 0) break;
    }
    return nodes;
  };
  // The page title is not always the first block: the homepage starts with an
  // eyebrow paragraph. Start the intro after the first h1 wherever it appears.
  const firstHeading = content.findIndex(node => headingLevel(node) === 1);
  sections[""] = section(firstHeading >= 0 ? firstHeading + 1 : 0, 0);
  const ancestors: { level: number; title: string }[] = [];
  for (const [index, node] of content.entries()) {
    const level = headingLevel(node);
    if (!level) continue;
    while (ancestors.length && ancestors.at(-1)!.level >= level) ancestors.pop();
    const id = attr(node, "id");
    if (id) {
      sections[id] = section(index + 1, level);
      parents[id] = ancestors.filter(parent => parent.level > 1).map(parent => parent.title);
    }
    const title = copy(node, base, { remaining: 500 }).map(previewText).join("").trim();
    ancestors.push({ level, title });
  }
  return { sections, parents };
}

async function htmlFiles(directory: string): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true });
  const paths = await Promise.all(entries.map(entry => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? htmlFiles(path) : entry.name.endsWith(".html") ? [path] : [];
  }));
  return paths.flat().sort();
}

if (import.meta.main) {
  const input = Deno.env.get("TOLA_HOOK_INPUT_DIR") ?? Deno.args[0];
  const output = Deno.env.get("TOLA_HOOK_OUTPUT_DIR") ?? Deno.args[1];
  if (!input || !output) throw new Error("Run from the search build hook, or pass rendered HTML and output directories");
  const root = resolve(input);
  let count = 0;
  for (const file of await htmlFiles(root)) {
    const path = relative(root, file).split(sep).join("/");
    const data = searchPreviews(await readFile(file, "utf8"), path);
    if (!data) continue;
    const destination = join(output, "assets/search-previews", path + ".json");
    await mkdir(dirname(destination), { recursive: true });
    await writeFile(destination, JSON.stringify(data));
    count++;
  }
  console.log(`Search previews: ${count} pages`);
}
