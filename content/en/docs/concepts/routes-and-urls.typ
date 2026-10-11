#import "@tola/source:0.0.0": tola-meta
#import "@tola/address:0.0.0": output-url

#tola-meta((
  title: "Site paths",
  description: "Map a source file to its output path and browser URL.",
  order: 40,
))

#title()

#let address-reference = output-url("docs/reference/packages/address/index.html")

= Path mapping

For a site mounted at `https://example.com/notes/`, the starter maps `content/guide/install.typ` as follows.

#table(
  columns: (auto, 1fr),
  table.header([Value], [Example]),
  [Source path], [`guide/install.typ`],
  [Route segments], [`("guide", "install")`],
  [Site route], [`/guide/install/`],
  [Bundle output], [`guide/install/index.html`],
  [Published file], [`public/guide/install/index.html`],
  [Browser URL], [`https://example.com/notes/guide/install/`],
)

`source.path` is relative to the content directory. Pass `source.file` to `include`. The entry can use the default `source.route-segments`, add a prefix, or slugify each segment.

= Routes and outputs

`join-route` joins segments into a route with leading and trailing slashes. Pass that route to `output-of` to get the path for `document`. Bundle outputs are relative to the publish directory.

#table(
  columns: (1fr, 1fr),
  table.header([Route], [Output]),
  [`/`], [`index.html`],
  [`/guide/`], [`guide/index.html`],
  [`/guide`], [`guide`],
  [`/sitemap.xml`], [`sitemap.xml`],
)

`route-of("guide/index.html")` returns `/guide/`. Both `content/about.typ` and `content/about/index.typ` default to `/about/`. Give one of them a different output to resolve the conflict.

= Browser URLs

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

`origin` holds the scheme and domain, with an optional port. `base-path` has leading and trailing slashes. Use `"/"` at the domain root. `site.url` combines both.

```typst
#import "@tola/address:0.0.0": output-url, route-url
#import "@tola/site:0.0.0": site

#let output = "guide/install/index.html"
#let browser-path = output-url(output) // /notes/guide/install/
#let full-url = output-url(output, origin: site.origin)
#assert.eq(browser-path, route-url("/guide/install/"))
#link(browser-path)[Installation guide]
```

Use #link(address-reference + "#en-ref-packages-address-output-url-function")[`output-url`] with an output path and #link(address-reference + "#en-ref-packages-address-route-url-function")[`route-url`] with a route. Both add the deployment prefix and URL encoding. To reuse an already encoded URL path as a route, strip the prefix and apply `decode-url-path` once. Append a fragment after building the URL.

= Asset URLs

`asset-url` looks up an address from `[assets]`, adds the prefix and, if configured, a cache hash. Use `output-url` for known paths from Bundle `asset` calls or generation hooks.

= Module paths

An absolute Typst input path starts at the project root in site code and at the package root in module code. Use `source.file` to include site content from a module. Use `project-path("data/menu.json")` from `@tola/site` to read a project file.

A module's asset sources are relative to the module. Published URLs include the alias, such as `/notes/_tola-modules/blog/theme.css`. Read inputs through `get-module().assets.files` and browser URLs through `get-module().assets.urls`.

See #link(address-reference)[the address reference] for conversions.
