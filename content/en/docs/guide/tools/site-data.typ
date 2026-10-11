#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Site data and queries",
  description: "Read site data, group pages, and query links.",
  order: 0,
))

#title()

= Data sources

#table(
  columns: (auto, 1fr),
  table.header([Package], [Use]),
  [`@tola/site`], [Read configuration and resolve project paths from a module.],
  [`@tola/module`], [Read a module instance's alias, options, and assets.],
  [`@tola/source`], [Find source files and read their metadata.],
  [`@tola/schema`], [Validate data and supply defaults.],
  [`@tola/address`], [Convert routes, output paths, and URLs.],
  [`@tola/collection`], [Group pages, index by key, or traverse a hierarchy.],
  [`@tola/datalog`], [Declare facts and rules for recursive queries.],
  [`@tola/document`], [Read the current document, headings, and references.],
)

`current-source()` identifies the source file. A source can occur in several outputs. Call `current-document()` in `context` to see which output contains it.

= Group pages

Put this in a page. Replace the example array with your entry's page list to generate a section index.

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

`group-by` assigns one key per item. Use `group-by-keys` to place a page under several tags. Use `index-by` for unique keys.

= Query headings

`headings` reads the current document. Pass each heading's location to `link`.

```typst
#import "@tola/document:0.0.0": headings

#context {
  let sections = headings(depth: 2).filter(section => section.outlined)
  list(..sections.map(section => link(section.location, section.text)))
}
```

= Query reachable pages

If A links to B and B links to C, Datalog can find both destinations from A.

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

The result contains `guide` and `install`. The first rule finds direct links. The second follows another link from each reachable page. `select` picks the result columns. Use `references()` to derive link facts from real pages.

Declare every relation and its column count in `database`, including relations with no facts yet. Use `relation.atom` for facts and conditions, then call `db.query` on the database.

#link("/docs/reference/packages/collection/")[`collection`] · #link("/docs/reference/packages/document/")[`document`] · #link("/docs/reference/packages/datalog/")[`datalog`]
