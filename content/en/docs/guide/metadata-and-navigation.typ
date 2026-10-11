#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "Metadata and navigation",
  description: "Filter out drafts and build a menu from the published pages.",
  order: 0,
))

#title()

Continue from #link("/docs/getting-started/first-site/")[Your first site]. The menu will list the home page and the installation guide.

= Declare metadata

Replace the home and guide sources and add `content/draft.typ`. Each file calls `tola-meta` once at the top level.

#code-group((
  (label: "content/index.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "My site"))
#title()

Welcome.
```]),
  (label: "content/guide/install.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "Installation guide"))
#title()

Run `tola --version` to print the version.
```]),
  (label: "content/draft.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "Unfinished post", draft: true))
#title()
```]),
))

= Filter pages

Merge the imports into `site.typ` and replace the original page loop. Keep the text settings and the 404 page.

```typst
#import "@tola/address:0.0.0": join-route, output-of, output-url
#import "@tola/schema:0.0.0": optional, schema
#import "@tola/source:0.0.0": all-sources, parse-sources

#let fields = schema((
  title: str,
  draft: optional(bool, default: false),
))

#let pages = {
  parse-sources(all-sources(), fields)
    .filter(source => not source.meta.draft)
    .map(source => (
      source: source,
      output: output-of(join-route(source.route-segments)),
    ))
}

#for page in pages {
  document(page.output, format: "html", title: page.source.meta.title)[
    #html.nav[
      #list(..pages.map(target => link(output-url(target.output))[
        #target.source.meta.title
      ]))
    ]
    #include page.source.file
  ]
}
```

`parse-sources` checks every source and supplies `false` when `draft` is absent. The filter excludes drafts from the published pages and menu. A draft still goes through validation, so `draft: "true"` is a type error.

Run `tola dev`. The menu links to the home page and installation guide, and `/draft/` returns a 404. Change its `draft` to `false` to publish it and add it to the menu.
