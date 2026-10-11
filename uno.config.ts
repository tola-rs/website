import { defineConfig, presetAttributify, presetTypography, presetWind4 } from "unocss";
import type { Theme } from "unocss/preset-wind4";
import { htmlExtractor } from "./scripts/html-extractor.ts";

// Restore explicit theme choices in <head>; otherwise follow the system theme.
const dark = ':root[data-theme="dark"]';
const systemDark = ':root:not([data-theme])';
const within = (root: string, selector: string) =>
  `${selector}:where(${root}, ${root} *)`;

export default defineConfig<Theme>({
  presets: [
    presetWind4({ preflights: { reset: true, theme: "on-demand", property: true } }),
    // Keep Attributify's rules, but replace its source regex with the HTML parser.
    { ...presetAttributify({ prefix: "un-", prefixedOnly: true }), extractors: [] },
    presetTypography({
      // Both schemes follow the same semantic variables; the root theme changes
      // their values, so prose never needs a separate dark-mode inversion class.
      colorScheme: {
        body: ["var(--text)", "var(--text)"],
        headings: ["var(--heading)", "var(--heading)"],
        lead: ["var(--text)", "var(--text)"],
        links: ["var(--accent)", "var(--accent)"],
        bold: ["var(--text)", "var(--text)"],
        counters: ["var(--muted)", "var(--muted)"],
        bullets: ["var(--muted)", "var(--muted)"],
        hr: ["var(--line)", "var(--line)"],
        quotes: ["var(--muted)", "var(--muted)"],
        "quote-borders": ["var(--line)", "var(--line)"],
        captions: ["var(--muted)", "var(--muted)"],
        kbd: ["var(--muted)", "var(--muted)"],
        "kbd-shadows": ["var(--text)", "var(--text)"],
        code: ["var(--text)", "var(--text)"],
        "pre-code": ["var(--text)", "var(--text)"],
        "pre-bg": ["var(--code-block-bg)", "var(--code-block-bg)"],
        "th-borders": ["var(--line)", "var(--line)"],
        "td-borders": ["var(--line)", "var(--line)"],
      },
      cssExtend: {
        // The main container owns the reading width.
        "max-width": "none",
        "line-height": "1.7",
        "code::before": { content: "none" },
        "code::after": { content: "none" },
        "blockquote p:first-of-type::before": { content: "none" },
        "blockquote p:last-of-type::after": { content: "none" },
        kbd: { "box-shadow": "none" },
      },
    }),
  ],
  extractorDefault: false,
  extractors: [htmlExtractor],
  outputToCssLayers: {
    cssLayerName: (layer) => layer === "default" ? "utilities" : layer === "base" ? "reset" : layer,
  },
  theme: {
    font: {
      sans: 'system-ui, -apple-system, "Segoe UI", "PingFang SC", "Microsoft YaHei", sans-serif',
      mono: 'ui-monospace, "SFMono-Regular", Consolas, "Liberation Mono", monospace',
    },
    breakpoint: { xs: "28rem", sm: "40rem", md: "48rem", docs: "60rem", toc: "72rem" },
    container: { reading: "74ch", site: "90rem", page: "76rem", blog: "70rem" },
    colors: {
      canvas: "var(--bg)", surface: "var(--surface)", ink: "var(--text)", heading: "var(--heading)",
      "inline-code": "var(--inline-code-bg)", "code-ink": "var(--inline-code-text)",
      "code-block": "var(--code-block-bg)",
      muted: "var(--muted)", line: "var(--line)", accent: "var(--accent)",
    },
  },
  shortcuts: {
    "ui-icon": "block size-4.5 shrink-0",
    "ui-control": "inline-flex min-h-10 cursor-pointer items-center justify-center gap-2 rounded-none border-0 bg-transparent px-3 py-2 text-sm leading-none font-medium text-ink no-underline transition-colors",
    "panel-surface": "rounded-none border border-line bg-canvas text-ink",
  },
  variants: [
    {
      name: "site-dark",
      order: -1,
      match(matcher) {
        if (!matcher.startsWith("dark:")) return;
        return [
          { matcher: matcher.slice(5), selector: (s) => within(dark, s) },
          { matcher: matcher.slice(5), selector: (s) => within(systemDark, s), parent: "@media (prefers-color-scheme: dark)" },
        ];
      },
    },

  ],
});
