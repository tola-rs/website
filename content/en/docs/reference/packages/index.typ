#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Built-in packages",
  description: "Signatures and examples for packages in the @tola namespace.",
  order: 10,
))

#title()

Import the packages that ship with Tola at version `0.0.0`.

#table(
  columns: (auto, 1fr),
  table.header([Package], [Use]),
  [#link("/docs/reference/packages/site/")[`site`]], [Read site settings and resolve project paths.],
  [#link("/docs/reference/packages/module/")[`module`]], [Read module options and assets.],
  [#link("/docs/reference/packages/source/")[`source`]], [List sources and validate metadata.],
  [#link("/docs/reference/packages/schema/")[`schema`]], [Validate and convert data.],
  [#link("/docs/reference/packages/address/")[`address`]], [Convert routes, output paths, and URLs.],
  [#link("/docs/reference/packages/collection/")[`collection`]], [Group, index, and traverse records.],
  [#link("/docs/reference/packages/document/")[`document`]], [Query documents, headings, and references.],
  [#link("/docs/reference/packages/datalog/")[`datalog`]], [Query relationships with facts and rules.],
  [#link("/docs/reference/packages/image/")[`image`]], [Inspect, resize, and publish images.],
  [#link("/docs/reference/packages/icon/")[`icon`]], [Use icons from configured collections.],
  [#link("/docs/reference/packages/code/")[`code`]], [Render highlighted code.],
  [#link("/docs/reference/packages/head/")[`head`]], [Create HTML metadata and share cards.],
  [#link("/docs/reference/packages/feed/")[`feed`]], [Generate RSS, Atom, or JSON Feed.],
  [#link("/docs/reference/packages/sitemap/")[`sitemap`]], [Generate an XML sitemap.],
  [#link("/docs/reference/packages/hash/")[`hash`]], [Hash bytes with BLAKE3.],
  [#link("/docs/reference/packages/uuid/")[`uuid`]], [Create UUID v5 values.],
  [#link("/docs/reference/packages/diagnostic/")[`diagnostic`]], [Report source errors and warnings.],
)

See #link("/docs/guide/site-data/")[Site data and queries] and #link("/docs/guide/page-presentation/")[Images, icons, and code] for use in a site. In the terminal, run `tola help "@tola/address" output-url` to look up one function.
