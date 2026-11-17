#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Site data and queries",
  description: "Group pages into indexes, build a table of contents, query backlinks, and extract data with Datalog and tola query.",
  order: 10,
))

#title()

#callout[
  Calling `current-source()` inside a page returns the current source file. When one source is arranged into several documents, `current-source()` stays the same while `current-document()`, called inside `context`, returns the output path and route of each document. See #link("/docs/concepts/tola-packages/")[Tola packages] for the full list of built-ins.
]

= Grouping and indexing pages

`@tola/collection` is the tool for arranging the page list an entry selects:

```typst
#import "@tola/collection:0.0.0": group-by

#let pages = (
  (title: "First note", section: "Notes"),
  (title: "Second note", section: "Notes"),
  (title: "Installation", section: "Guide"),
)

#for (section, members) in group-by(pages, key: page => page.section) [
  #heading(section)
  #list(..members.map(page => page.title))
]
```

- A one-to-one unique index: `index-by`, which errors on a duplicate key.
- Grouping by a single value: `group-by`.
- Several tags on one page (one-to-many grouping): `group-by-keys`, where the callback returns an array of keys.
- Breadcrumbs and tree descendants: configure a parent-key callback and use `lineage` and `descendants`.

= A table of contents for this page

Inside the `document(...)` body of a document template, read the headings of the current document with `headings()` from `@tola/document` and build a table of contents:

```typst
#import "@tola/document:0.0.0": headings

#context {
  let sections = headings(depth: 2).filter(section => section.outlined)
  html.nav(aria-label: "On this page")[
    #list(..sections.map(section => link(section.location, section.body)))
  ]
}
```

`headings(depth: 2)` keeps only headings whose actual level is at most 2, and filtering on `section.outlined` matches Typst's native outline so headings you left out of it are skipped. When `section.location` is passed to `link`, Tola generates the anchor for the target heading in the exported HTML.

= Backlinks: who links to this page

`references()` queries the Typst `link` and `ref` edges between documents inside `context`. Wrap the article body in a container labelled `<article-body>` and list the other documents that reference the current page outside that container:

```typst
#import "@tola/document:0.0.0": references

#context {
  let seen = ()
  for item in references(to: auto, from-within: <article-body>) {
    let output = item.document.output
    if output in seen { continue }
    seen.push(output)
    link(item.document.location)[#item.document.route]
  }
}
```

Two things to keep in mind:

- A heading label selects only the heading itself. Use a container around the body, such as `html.main` or `html.article`, as the `from-within` scope, and place the backlink list outside that scope.
- If a source page links to the current page several times, the query returns one record per link. Deduplicate on `document.output` to get a unique list of source pages.

= Querying recursive relations with Datalog

To follow links several hops deep, such as finding every page reachable from A when A links to B and B links to C, declare facts and inference rules with `@tola/datalog`:

```typst
#import "@tola/datalog:0.0.0": database, relation, rule, var

#let link-to = relation("link-to", 2)
#let reachable = relation("reachable", 2)
#let (x, y, z) = ("x", "y", "z").map(var)

#let db = database(
  (link-to, reachable),
  facts: (
    link-to.atom("home", "guide"),
    link-to.atom("guide", "install"),
  ),
  rules: (
    rule(reachable.atom(x, y), link-to.atom(x, y)),
    rule(reachable.atom(x, z), reachable.atom(x, y), link-to.atom(y, z)),
  ),
)

#let rows = db.query(select: (y,), where: (reachable.atom("home", y),))
#list(..rows.map(row => row.first()))
```

The page prints `guide` and `install`. The first argument of `database` must list every relation, including those that only rules derive. Call `.atom(...)` on a relation to build facts and conditions, and read the result with `db.query(...)`. In a real site, feed the internal links that `references()` reports into `facts`.

= Exporting data to scripts with `tola query`

When you do not need a rendered page, expose site data through `#metadata(...)` for the command line or an external script. Create `tools/model.typ` in the project:

```typst
#import "@tola/source:0.0.0": all-sources
#metadata(all-sources().map(source => source.path)) <model>
```

Then run this from the site root:

```sh
tola query ./tools/model.typ --label model --json --pretty
```

A query runs no build hooks and never touches the publish directory. If a module declares a named query in `tola-module.toml` (see #link("/docs/guide/module-publishing/")[Module queries, commands, and publishing]), run `tola query <alias>.<query>` directly; add `-i` to filter records interactively in the terminal.

Full APIs: #link("/docs/reference/packages/collection/")[`collection`] · #link("/docs/reference/packages/document/")[`document`] · #link("/docs/reference/packages/datalog/")[`datalog`].
