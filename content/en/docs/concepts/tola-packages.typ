#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Tola packages",
  description: "Import built-ins and use source paths to build links.",
  order: 50,
))

#title()

= Imports

Tola ships the `@tola/*` packages. Import them at version `0.0.0`. The APIs follow the installed Tola version.

```typst
#import "@tola/source:0.0.0": all-sources
#import "@tola/address:0.0.0": join-route, output-of
```

Use `@preview/…` for Typst Universe packages and `@tola-modules/…` for modules registered under an alias in `tola.toml`.

= Example

In #link("/docs/getting-started/first-site/")[Your first site], put this in `content/index.typ` to link to the installation guide.

```typst
#import "@tola/address:0.0.0": join-route, route-url
#import "@tola/source:0.0.0": all-sources

#let guide = all-sources().find(source => source.path == "guide/install.typ")
#let route = join-route(guide.route-segments)
#link(route-url(route))[Read the installation guide]
```

This uses the starter's default route. If the entry sets a custom output for a page, pass that output to `output-url`. Use `@tola/collection` to group or index the resulting page list.

= Reference

See #link("/docs/reference/packages/")[Built-in packages] for signatures, or #link("/docs/guide/tools/")[Package and script examples] for working examples.
