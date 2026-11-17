#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Tola packages",
  description: "Learn how @tola/* built-ins, @tola-modules/* module packages, and @preview/* community packages are imported and what each group is for.",
  order: 50,
))

#title()

Tola ships a set of `@tola/*` Typst packages for reading site configuration, validating metadata, computing routes, processing images, and generating feeds. Import them without installing anything.

= Package namespaces and import versions

Three package prefixes appear in Typst code, each with a different source:

- `@tola/<name>:0.0.0` for built-in packages; the import version is always `0.0.0`.
- `@tola-modules/<alias>:0.0.0` for local or remote modules registered in the site's `tola.toml` (also version `0.0.0`).
- `@preview/<name>:<version>` for third-party community packages from Typst Universe.

```typst
#import "@tola/address:0.0.0": join-route, route-url
#import "@tola/source:0.0.0": all-sources

#let guide = all-sources().find(source => source.path == "guide/install.typ")
#let route = join-route(guide.route-segments)
#link(route-url(route))[Read the installation guide]
```

If the entry program overrides the output path of a page, build the link from `output-url(page.output)` instead, so links do not drift from the page's real location.

#callout[
  If a file needs Typst's native `document(...)` function and the query functions of `@tola/document` together, import the members you need (`#import "@tola/document:0.0.0": current-document, headings`) or alias the package (`as doc`). A plain module import shadows the global `document`.
]

= Built-in packages at a glance

#table(
  columns: (auto, 1fr),
  table.header([Package], [Main use]),
  [`@tola/source`], [Discover the sources under `content/`, declare metadata with `tola-meta`, and parse it for many sources at once.],
  [`@tola/schema`], [Define field types and defaults, and validate metadata, dates, and site paths.],
  [`@tola/address`], [Generate slugs and convert between routes, Bundle output paths, and browser URLs.],
  [`@tola/site`], [Read the `[site]` and `[options]` configuration and locate project files with `project-path`.],
  [`@tola/module`], [Read module aliases, options, and assets with `get-module` inside a module or a site.],
  [`@tola/document`], [Query the current document, its `headings`, and its link `references` inside `context`.],
  [`@tola/collection`], [Group a page list, index it, find neighbours with `adjacent`, and walk hierarchy.],
  [`@tola/datalog`], [Query recursive relations, such as page reachability, from facts and rules.],
  [`@tola/image`], [Read image metadata, resize and crop on demand, and generate responsive `img` / `srcset` output.],
  [`@tola/icon`], [Render SVG icons from configuration or a module manifest, or produce icon URLs.],
  [`@tola/code`], [Highlight `raw` blocks with light and dark themes, with bundled language syntaxes and a stylesheet.],
  [`@tola/head`], [Generate `<head>` metadata, `canonical` links, Open Graph tags, and Twitter cards.],
  [`@tola/feed`], [Generate RSS and Atom feeds (`feed.xml`).],
  [`@tola/sitemap`], [Generate `sitemap.xml` with absolute URLs.],
  [`@tola/diagnostic`], [Report structured diagnostics directly from Typst code.],
  [`@tola/hash` / `@tola/uuid`], [Compute BLAKE3 digests and generate canonical UUID v5 values.],
)

Run `tola help --lang en "@tola/address"` locally to see the full signature of any built-in package or member. For worked examples, see #link("/docs/guide/site-data/")[Site data and queries], #link("/docs/guide/page-presentation/")[Images, icons, and code], and the #link("/docs/reference/packages/")[Built-in packages reference].
