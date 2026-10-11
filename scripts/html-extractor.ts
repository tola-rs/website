import { parse, type DefaultTreeAdapterMap } from "parse5";
import type { Extractor } from "unocss";

// Typst is a program, not HTML: scan its rendered attributes, never prose,
// comments, escaped examples or script strings. parse5 also decodes entities.
export const htmlExtractor: Extractor = {
  name: "site-html-attributes",
  extract({ code, id }) {
    if (!id?.endsWith(".html")) return [];
    const tokens = new Set<string>();
    const visit = (node: DefaultTreeAdapterMap["node"]) => {
      if ("attrs" in node) {
        for (const { name, value } of node.attrs) {
          if (name === "class") {
            for (const token of value.split(/\s+/)) if (token) tokens.add(token);
          } else if (name.startsWith("un-")) {
            if (!value) tokens.add(`[${name}=""]`);
            for (const token of value.split(/\s+/)) {
              if (token) tokens.add(`[${name}~=${JSON.stringify(token)}]`);
            }
          }
        }
      }
      if ("childNodes" in node) node.childNodes.forEach(visit);
      if ("content" in node) visit(node.content);
    };
    visit(parse(code));
    return tokens;
  },
};
