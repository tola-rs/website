#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Content metadata",
  description: "Declare and validate fields such as titles and drafts.",
  order: 20,
))

#title()

= Field declarations

Use `tola-meta` once per source to declare fields such as a title, publication date, or draft flag.

```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Installation guide",
  draft: true,
))

= Installation guide
```

Call it at the top level, either directly or through an imported function. `context` and selector-based `show` rules run during layout, too late to register source metadata. A top-level declaration in an imported file belongs to that file.

= Validation

`all-sources()` exposes the declared dictionary as `source.meta`. `parse-sources` checks each source, supplies defaults, and reports type errors with source locations.

```typst
#import "@tola/schema:0.0.0": non-empty, optional, schema, trim
#import "@tola/source:0.0.0": all-sources, parse-sources

#let fields = schema((
  title: non-empty(trim(str)),
  draft: optional(bool, default: false),
))

#let pages = {
  parse-sources(all-sources(), fields)
    .filter(source => not source.meta.draft)
}
```

Here the title must be a nonempty string, and missing `draft` defaults to `false`. The filter decides what gets published. Drafts are still evaluated and validated.

= Field conventions

The entry or theme defines what `draft`, `order`, and `permalink` do. This site's theme skips drafts, sorts pages within groups by `order`, and uses `permalink` to override the default route.

See #link("/docs/guide/metadata-and-navigation/")[Metadata and navigation] for a menu that uses the filtered page list.
