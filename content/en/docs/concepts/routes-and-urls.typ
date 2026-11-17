#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Routes and URLs",
  description: "Relate source paths, site routes, Bundle output paths, and browser URLs.",
  order: 30,
))

#title()

Tola keeps three questions apart: where a source file lives, which file it becomes, and which address a browser requests. Keeping them straight prevents broken paths when you deploy under a sub-path or reference files across modules.

= Layers of a path

Assume the site is deployed at `https://example.com/notes/`, so `base-path = "/notes/"`. The default entry maps `content/guide/install.typ` as follows:

#table(
  columns: (auto, 1fr),
  table.header([Concept], [Example value]),
  [Source path (`source.path`)], [`guide/install.typ`, relative to `content-dir`],
  [Route segments (`source.route-segments`)], [`("guide", "install")`],
  [Site route (route)], [`/guide/install/`],
  [Bundle output path (output)], [`guide/install/index.html`, relative to the publish directory],
  [Published file on disk], [`public/guide/install/index.html`],
  [Full browser URL], [`https://example.com/notes/guide/install/`],
)

`source.path` is handy for deciding where a source belongs in a script or entry, and `source.file` is the native Typst path you pass to `include`. `source.route-segments` is only the default the file layout suggests: you can add a prefix, replace it with `permalink`, or call `slugify` on each segment first.

= Converting between routes and output paths

`join-route` joins the segment array into a route with a leading and trailing `/`, and `output-of` turns that route into a Bundle output path for `document(...)` or `asset(...)`. `route-of` converts the other way:

#table(
  columns: (1fr, 1fr),
  table.header([Route passed to `output-of`], [Bundle output path]),
  [`/`], [`index.html`],
  [`/guide/`], [`guide/index.html`],
  [`/guide`], [`guide`],
  [`/sitemap.xml`], [`sitemap.xml`],
)

Mind the trailing slash: `/guide/` is the directory page `guide/index.html`, while `/guide` without the slash is a file named `guide`. Also, `content/about.typ` and `content/about/index.typ` both default to the segments `("about",)` and map to `about/index.html`; keeping both files raises an output conflict, which you resolve by moving one of them or giving it a different output path in the entry.

= Building browser URLs

Configure `origin` and `base-path` in `tola.toml` when the site is deployed under a sub-path or when you need absolute addresses:

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

`origin` holds the scheme, host, and optional port; `base-path` must start and end with `/` (`"/"` when the site sits at the domain root). Do not concatenate the deployment prefix by hand; use `@tola/address` instead:

```typst
#import "@tola/address:0.0.0": output-url, route-url
#import "@tola/site:0.0.0": site

#let output = "guide/install/index.html"
#let browser-path = output-url(output) // /notes/guide/install/
#let full-url = output-url(output, origin: site.origin)

#assert.eq(browser-path, route-url("/guide/install/"))
#assert.eq(full-url, "https://example.com/notes/guide/install/")
#link(browser-path)[Installation guide]
```

Guidelines:

- *When you have a Bundle output path*, such as `page.output` or a file a hook generates, use `output-url`.
- *When you have a decoded site route*, such as `"/guide/install/"`, use `route-url`.
- Both add `site.base-path` and percent-encode special characters, so the route `/Hello World/` becomes `/notes/Hello%20World/` while the file on disk keeps the unencoded name.
- Append a fragment such as `#intro` after the URL the function returns.
- If you receive an already percent-encoded site path, strip the deployment prefix, decode it once with `decode-url-path`, and pass it back to `output-of`.

= Static asset URLs

Reference files declared in `[assets]` with `asset-url`, for example `asset-url("/media/logo.svg")`:

- It checks that the path is actually a declared and enabled asset in `[assets]`, then adds `base-path` and appends a `?h=…` query when `assets.cache-busting` is on.
- Unlike `output-url`, `asset-url` keeps the full filename even when a static file happens to be named `index.html`, instead of collapsing it to a directory address.
- Files produced by a top-level `asset(...)` call in `site.typ` or by `[[hooks.generate-outputs]]` are Bundle or build outputs rather than `[assets]` entries; reference them with `output-url`.

= Site roots and module paths

The meaning of a path that starts with `/` in Typst depends on where the code runs:

- *In the site entry or a content file*, `/` points at the site root. A module that reads a file from the site, such as `data/menu.json`, uses `project-path("data/menu.json")` from `@tola/site`.
- *Inside a module*, `/` points at that module package's root, and inserting a site content source requires `source.file`.

Static assets a module declares are mounted at `/_tola-modules/<module-alias>/` when published (with `base-path`, for example `/notes/_tola-modules/blog/theme.css`). In module code, `get-module().assets.files` gives the compile-time input paths and `get-module().assets.urls` gives browser URLs that already include the deployment prefix.

See the #link("/docs/reference/packages/address/")[`@tola/address` reference] for full signatures and parameters, or run `tola help --lang en "@tola/address"`.
