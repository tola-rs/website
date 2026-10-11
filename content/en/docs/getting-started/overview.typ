#import "@tola/source:0.0.0": tola-meta
#import "/components/content/lib.typ": code-group
#import "/site/info.typ": version

#tola-meta((
  title: "Overview",
  description: "An introduction to Tola and a minimal example.",
  order: 0,
))

#title()

= About

Tola is an open-source static site generator built on #link("https://typst.app/")[Typst].

Typst is a modern typesetting language. Version 0.13 added initial HTML export; 0.14 added typed HTML elements (#link("https://typst.app/docs/reference/html/typed/")[Typed HTML]); 0.15 added experimental Bundle export and #link("https://developer.mozilla.org/en-US/docs/Web/MathML")[MathML] support for equations. These features make it possible to write a site in Typst and use its programming power and ecosystem.

Tola builds on Typst with a static-site perspective. It provides a set of built-in packages under the `@tola` namespace; you compose them yourself. Tola compiles the root program as a Typst Bundle, then checks and publishes the result.

If you do not know Typst, the short version: compared with Markdown, Typst has a higher ceiling. It handles complex typesetting and PDF output, and also works as an advanced HTML generator.

= Minimal example

Let's look at an example:

```
tola-demo/
├── content/
│   ├── index.typ
│   ├── about.typ
│   └── guide/
│       └── install.typ
├── site.typ
└── tola.toml
```

#code-group((
  (label: "site.typ", body: [```typst
#import "@tola/source:0.0.0": all-sources
#import "@tola/address:0.0.0": join-route, output-of

#for source in all-sources() {
  document(
    output-of(join-route(source.route-segments)),
    title: source.meta.title,
  )[
    #include source.file
  ]
}
```]),
  (label: "install.typ", body: [````typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Install",
  description: "How to install Tola?",
))

#title()

Install Tola with Cargo:

```sh
cargo install --locked tola
```

Verify the install:

```sh
tola --version
```
````]),
  (label: "tola.toml", body: [```toml
[site]
title = "Tola demo"
description = "A minimal Tola site"
language = "en"

[build]
entry = "site.typ"
content-dir = "content"
publish-dir = "public"
```])
))

*Entry.* `site.typ` is the site's entry program. Tola compiles it as a Bundle: the root program uses `document` to declare documents and `asset` to declare assets, producing all files of the site in one compilation.

*Sources.* Every discovered lowercase `.typ` file under `content/` is a content source. Its `tola-meta((...))` call declares its metadata; fields such as `title`, `draft`, `permalink`, `order`, and `pin` have no built-in meaning and are handled entirely by your site code. `all-sources()` returns every source; besides `source.meta`, each source carries identity fields such as `path` and `route-segments`. For `content/guide/install.typ`:

- `source.meta.title`: the title declared by the source
- `source.path`: `"guide/install.typ"`
- `source.route-segments`: `("guide", "install")`

*Routes.* `join-route` is a pure function that joins `route-segments` into a site-root route:

#table(
  columns: 2,
  table.header([Step], [Result]),
  [`source.route-segments`], [`("guide", "install")`],
  [`join-route(...)`], [`"/guide/install/"`],
  [`output-of(...)`], [`"guide/install/index.html"`],
)

`document` declares this output path in the bundle, and Tola publishes it to `public/guide/install/index.html`, so it is reachable at `https://tola-demo.com/guide/install/`.

Tola provides `route-segments` rather than a final `route` so you can build the route yourself: add prefixes or suffixes, or `slugify` each segment:

```typst
#import "@tola/address:0.0.0": slugify
#for source in all-sources() {
  let segments = source.route-segments.map(segment => slugify(segment))
  let output = output-of(join-route(segments))
  document(output, title: source.meta.title)[
    #include source.file
  ]
}
```

A few facts follow from the example:

- *A source is not a page.* A source can be published once by `document`, appear in several documents, be published under different prefixes, or be filtered out by `source.meta.draft` and other custom logic. The root program decides.
- *A file path only supplies a default route.* `content/guide/install.typ` suggests `("guide", "install")`; the root program can use another address, or override it with `source.meta.permalink` and other custom logic.

= Build flow

```mermaid
flowchart LR
  source["content/*.typ"] --> root["site.typ"] --> bundle["Typst Bundle"] --> output["public/"]
```

= Notes

- Typst #version.typst's HTML features are still under active development.
- Typst #version.typst's Bundle export is still experimental.
- Typst generates static content and structure; dynamic browser behavior still needs JavaScript.
- Tola is still under active development.

= Next

- #link("/docs/getting-started/installation/")[Installation]: install Tola and verify the executable.
