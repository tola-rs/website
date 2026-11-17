#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Content metadata",
  description: "Declare page fields with tola-meta and validate them with @tola/schema in the entry.",
  order: 20,
))

#title()

Source files usually carry a title, a publication date, a sort weight, or a draft flag for the entry program to read. Tola lets you declare those fields with `tola-meta`, but attaches no fixed meaning to them: your site or theme schema decides every rule.

= Declaring fields in a source

Call `tola-meta` once at the top level of each content source, either directly or through a wrapper function imported from elsewhere, such as a metadata helper the theme provides.

```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Installation guide",
  draft: true,
))

#title()
```

#callout[
  `tola-meta` must run in ordinary top-level code. `context` blocks and `show` rules with a selector are evaluated during layout, so metadata declared inside them is never discovered by the entry. A file pulled in with `import` that declares `tola-meta` at its own top level contributes that declaration to itself, not to the importing page.
]

= Validating and filtering with `@tola/schema`

The entry gets every source record from `all-sources()` and validates them together with `parse-sources` from `@tola/source` and a schema from `@tola/schema`. `parse-sources` checks field types, fills in defaults, and points at the offending source file when validation fails:

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

Two points need attention:

- *Unknown fields are rejected by default.* `schema((...))` reports fields it does not know about. Add `unknown: "keep"` to pass extra fields through.
- *Drafts are read and validated too.* `parse-sources` runs before `filter`, so writing `draft: true` as the string `"true"` fails `tola check` with a type error, and a Typst syntax error in a draft source file breaks the build as well.

= Common field types and dates

Beyond the basic types, `@tola/schema` offers these combinations:

- `optional(type, default: ...)` allows a field to be missing and supplies a default. When the field is present with the wrong type, it still fails instead of falling back to the default.
- `nullable(type)` allows an explicit `none`.
- *Dates and times*: use `date` for a calendar date, `timestamp` for a date with a time, and `partial-date` for a year or year and month. `union(date, timestamp)` accepts both. A validated `timestamp` exposes `.rfc3339`, which you can pass straight to `@tola/feed` or `@tola/sitemap`.

= Theme field conventions

Fields such as `draft`, `order`, `permalink`, and `description` are not keywords hard-coded in Tola. They are conventions of the theme and of the entry. This site's theme, for example, skips drafts after validation, sorts sibling documents by `order`, and uses `permalink` to override the default route. Before you switch themes, check which fields the new theme's schema accepts.

The same validated, filtered page list can drive menus, feeds, and sitemaps as well as body output. See #link("/docs/guide/metadata-and-navigation/")[Metadata and navigation] and the #link("/docs/reference/packages/schema/")[`@tola/schema` reference].
