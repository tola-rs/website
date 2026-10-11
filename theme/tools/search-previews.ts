import { glob, mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname, join, relative, sep } from "node:path";
import { parse, type DefaultTreeAdapterMap } from "parse5";
import { previewTags, previewMathTags, previewImageUrl, previewLink, safeCodeToken, safeMathAttribute, type PreviewNode, type SearchPreviews } from "../typescript-sources/shared/search-preview.ts";

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

function copy(node: Node, target: PreviewNode[], base: URL, budget: { remaining: number }) {
  if (budget.remaining <= 0) return;
  if (node.nodeName === "#text") {
    const text = (node as DefaultTreeAdapterMap["textNode"]).value.slice(0, budget.remaining);
    budget.remaining -= text.length;
    target.push(text);
    return;
  }
  if (!("tagName" in node) || ignored(node)) return;

  const copyChildren = (children: PreviewNode[]) => {
    for (const child of node.childNodes) {
      if (budget.remaining <= 0) break;
      copy(child, children, base, budget);
    }
  };
  const previewLabel = attr(node, "data-search-preview-label")?.trim().slice(0, 80);
  if (previewLabel) {
    target.push({ tag: "p", children: [{ tag: "strong", children: [previewLabel] }] });
    copyChildren(target);
    return;
  }
  const children: PreviewNode[] = [];
  if (hasClass(node, "callout")) {
    copyChildren(children);
    target.push({ tag: "blockquote", children });
    return;
  }
  const codeClass = hasClass(node, "code-block") ? "code-block"
    : hasClass(node, "code-toolbar") ? "code-toolbar" : undefined;
  if (codeClass) {
    copyChildren(children);
    target.push({ tag: "div", attrs: { class: codeClass }, children });
    return;
  }
  if (!previewTags.has(node.tagName) && !previewMathTags.has(node.tagName)) {
    copyChildren(target);
    return;
  }
  const attrs: Record<string, string> = {};
  if (node.tagName === "span" && hasClass(node, "code-language")) attrs.class = "code-language";
  if (previewMathTags.has(node.tagName)) for (const { name, value } of node.attrs) {
    if (safeMathAttribute(name, value)) attrs[name] = value;
  }
  if (node.tagName === "img") {
    // A caption can describe an image with empty alt text.
    let parent = node.parentNode;
    while (parent && "tagName" in parent && parent.tagName !== "figure") parent = parent.parentNode;
    if (attr(node, "alt") === "" && (!parent || !("tagName" in parent) || parent.tagName !== "figure")) return;
    const src = previewImageUrl(attr(node, "src") ?? "", base);
    if (!src) return;
    attrs.src = src;
    attrs.alt = (attr(node, "alt") ?? "").slice(0, 500);
    for (const name of ["width", "height"]) {
      const value = attr(node, name);
      if (value && /^[1-9]\d{0,4}$/.test(value)) attrs[name] = value;
    }
  }
  const href = node.tagName === "a" ? attr(node, "href") : undefined;
  if (href !== undefined) {
    const url = previewLink(href, base);
    if (url) attrs.href = url.origin === base.origin ? url.pathname + url.search + url.hash : url.href;
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
  copyChildren(children);
  target.push({ tag: node.tagName, ...(Object.keys(attrs).length ? { attrs } : {}),
    ...(Object.keys(tokens).length ? { tokens } : {}), children });
}

function hasContent(nodes: PreviewNode[]): boolean {
  return nodes.some(node => typeof node === "string" ? Boolean(node.trim()) : node.tag === "img" || hasContent(node.children));
}

/** Exact heading IDs key the sidecar. The empty key contains only the page intro. */
function searchPreviews(html: string, output: string): SearchPreviews | null {
  const document = parse(html);
  const main = find(document, node => node.tagName === "main");
  const body = main && find(main, node => attr(node, "data-pagefind-body") !== undefined);
  if (!body) return null;
  const canonical = find(document, node => node.tagName === "link" && attr(node, "rel") === "canonical");
  const address = find(document, node => node.tagName === "meta" && attr(node, "name") === "search-page");
  const base = new URL(attr(canonical ?? body, "href") ?? attr(address ?? body, "content") ?? "/" + output, "https://preview.invalid/");
  const content: Element[] = [];
  collect(body, content);
  const sections: Record<string, PreviewNode[]> = Object.create(null);
  const section = (start: number, level: number) => {
    const nodes: PreviewNode[] = [];
    const budget = { remaining: 24000 };
    let count = 0;
    for (let index = start; index < content.length; index++) {
      const block = content[index];
      const rank = headingLevel(block);
      if (rank && (level === 0 || rank <= level)) break;
      const copied: PreviewNode[] = [];
      copy(block, copied, base, budget);
      if (!hasContent(copied)) continue;
      nodes.push(...copied);
      if (++count >= 32 || budget.remaining <= 0) break;
    }
    return nodes;
  };
  // Start after the title, even when a label precedes it.
  const firstHeading = content.findIndex(node => headingLevel(node) === 1);
  sections[""] = section(firstHeading >= 0 ? firstHeading + 1 : 0, 0);
  for (const [index, node] of content.entries()) {
    const level = headingLevel(node);
    if (!level) continue;
    const id = attr(node, "id");
    if (id) sections[id] = section(index + 1, level);
  }
  return { sections };
}

const [input, output] = process.argv.slice(2);
if (!input || !output) throw new Error("Usage: node search-previews.ts <rendered-site> <previews-directory>");

let count = 0;
for await (const file of glob("**/*.html", { cwd: input, withFileTypes: true })) {
  if (!file.isFile()) continue;
  const path = join(file.parentPath, file.name);
  const key = relative(input, path).split(sep).join("/");
  const data = searchPreviews(await readFile(path, "utf8"), key);
  if (!data) continue;
  const destination = join(output, key + ".json");
  await mkdir(dirname(destination), { recursive: true });
  await writeFile(destination, JSON.stringify(data));
  count++;
}
console.log(`Search previews: ${count} pages`);
