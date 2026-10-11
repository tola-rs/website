#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Modules and themes",
  description: "Share templates, entry programs, assets, and commands.",
  order: 70,
))

#title()

= Module manifest

`tola-module.toml` declares what a module provides. A module with a build entry can serve as a theme and select, route, and render the site's pages.

#table(
  columns: (auto, 1fr),
  table.header([Key], [Use]),
  [`[typst] entry`], [Exports for `@tola-modules/alias:0.0.0`.],
  [`[build] entry`], [Entry program a site can select.],
  [`[nu] entry`], [Exports for Nushell scripts.],
  [`[commands]`], [Commands such as `tola blog check`.],
)

= Choosing a theme

Register a local module and select its entry in `tola.toml`.

```toml
[build]
entry = { module = "blog" }

[modules.blog]
path = "theme"

[modules.blog.options]
show-title = true
```

`blog` is the alias for this instance. Import a component as `#import "@tola-modules/blog:0.0.0": note`. To use only its components, register the module and keep the project's build entry.

A module can also come from Git or an archive. Git sources take a `tag`, `branch`, or `rev` and an optional `subdir`. Archive sources can specify `sha256`. Share `tola.lock` to pin the resolved inputs.

= Options and diagnostics

The manifest's `[options]` supplies defaults. The site overrides them under `[modules.blog.options]`. Tables merge recursively. Arrays and scalars are replaced. Call `get-module()` inside the module or `get-module("blog")` to read that instance.

Check the theme's documentation for options and render functions. Use `tola blog --help` to list module commands and `tola inspect config` to check the selected entry.

See #link("/docs/concepts/routes-and-urls/")[Site paths] for module asset paths and #link("/docs/guide/local-module/")[Local modules] for a working theme.
