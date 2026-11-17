#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout, code-group

#tola-meta((
  title: "Metadata, ordering, and navigation",
  description: "Filter drafts, sort by weight, and generate site navigation plus previous and next links.",
  order: 0,
))

#title()

Starting from the directory layout of #link("/docs/getting-started/first-site/")[Your first site], this guide declares metadata with `tola-meta`, excludes draft pages, and drives both the top navigation and the previous/next links from one ordered page list.

= Declaring article metadata

Update the home page and the installation guide, and add a new source marked as a draft. Each file calls `tola-meta` once at the top level:

#code-group((
  (label: "content/index.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "My site", order: 1))
#title()

Welcome.
```]),
  (label: "content/guide/install.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "Installation guide", order: 2))
#title()

Run `tola --version` to print the version.
```]),
  (label: "content/draft.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "Unfinished post", draft: true))
#title()
```]),
), label: "Content sources")

= Validating, sorting, and generating navigation

Update the site entry, `site.typ`: validate every source with `parse-sources`, filter out drafts, sort by `(order, id)`, and compute the previous and next page for each rendered page with `adjacent` from `@tola/collection`.

```typst
#import "@tola/address:0.0.0": join-route, output-of, output-url
#import "@tola/collection:0.0.0": adjacent
#import "@tola/schema:0.0.0": non-empty, optional, schema, trim
#import "@tola/source:0.0.0": all-sources, parse-sources

#let fields = schema((
  title: non-empty(trim(str)),
  order: optional(int, default: 0),
  draft: optional(bool, default: false),
))

#let pages = {
  parse-sources(all-sources(), fields)
    .filter(source => not source.meta.draft)
    .sorted(key: source => (source.meta.order, source.id))
    .map(source => (
      source: source,
      output: output-of(join-route(source.route-segments)),
    ))
}

#for page in pages {
  let neighbors = adjacent(pages, page.output, key: item => item.output)
  document(page.output, format: "html", title: page.source.meta.title)[
    #html.nav[
      #list(..pages.map(target => link(output-url(target.output))[
        #target.source.meta.title
      ]))
    ]
    #include page.source.file
    #html.nav[
      #if "before" in neighbors [
        Previous: #link(output-url(neighbors.before.output))[#neighbors.before.source.meta.title]
      ]
      #if "after" in neighbors [
        Next: #link(output-url(neighbors.after.output))[#neighbors.after.source.meta.title]
      ]
    ]
  ]
}

#document("404.html", format: "html")[Page not found.]
```

A few notes:

- *One `pages` list drives navigation and neighbours.* The menu order and the previous/next order come from the same sorted result instead of guessing from filenames, and `source.id` breaks ties when two pages share an `order`.
- *Validation runs before filtering.* Draft sources must satisfy the schema too: writing `draft: true` as the string `"true"` makes `tola check` fail.

#callout[
  After `tola dev`, the top menu lists only "My site" and "Installation guide", and `/draft/` returns a 404. Set `draft` to `false` and the page appears in the output and in the navigation together.
]

To group pages by section, extract a page's table of contents, or query backlinks, continue with #link("/docs/guide/site-data/")[Site data and queries].
