#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout, code-group

#tola-meta((
  title: "Local modules",
  description: "Write a reusable Typst component library from scratch and grow it into a local theme with styles and configurable options.",
  order: 50,
))

#title()

Starting from #link("/docs/getting-started/first-site/")[Your first site], the two steps below move reusable components and the page layout into a local `theme/` directory.

= Step 1: write a Typst component module

Create `theme/` inside the site and add the manifest and the component definition:

#code-group((
  (label: "theme/tola-module.toml", body: [```toml
[typst]
entry = "lib.typ"
```]),
  (label: "theme/lib.typ", body: [```typst
#let note(body) = html.aside(class: "note", body)
```]),
), label: "Minimal module")

Register the module under the alias `notes` in the site's `tola.toml`:

```toml
[modules.notes]
path = "theme"
```

Import and call it at the end of `content/index.typ`:

```typst
#import "@tola-modules/notes:0.0.0": note

#note[Check the version before installing.]
```

Run `tola module check ./theme` to validate the manifest and its file declarations, then `tola build`. `public/index.html` now contains the rendered `<aside class="note">`.

= Step 2: grow it into a full theme

To hand the page layout, default options, and stylesheet to the module as well, complete the files below.

1. Write the styles in `theme/assets/note.css`:

```css
.reading { max-width: 42rem; margin: 2rem auto; padding: 0 1rem; }
.note { padding: 0.75rem 1rem; border-inline-start: 0.25rem solid currentColor; }
```

2. Create the theme entry `theme/site.typ` and read the instance configuration and module asset URLs with `get-module()`:

```typst
#import "@tola/address:0.0.0": join-route, output-of
#import "@tola/module:0.0.0": get-module
#import "@tola/source:0.0.0": all-sources

#let theme = get-module()

#for source in all-sources() {
  document(output-of(join-route(source.route-segments)), format: "html")[
    #html.html[
      #html.head[
        #html.meta(charset: "utf-8")
        #html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
        #html.title(theme.options.title)
        #html.link(rel: "stylesheet", href: theme.assets.urls.at("note.css"))
      ]
      #html.body[
        #html.main(class: "reading")[#include source.file]
      ]
    ]
  ]
}

#document("404.html", format: "html")[Page not found.]
```

#callout[
  Never hard-code the example alias `"notes"` in module code. Always read the current instance with `get-module()` so the module keeps working when a consumer renames the alias to `docs` or `blog`, and keep using `source.file` to pull site article bodies in.
]

3. Extend `theme/tola-module.toml` with the build entry, default options, and the module's assets:

```toml
[build]
entry = "site.typ"

[options]
title = "Notes"

[assets]
files = [{ source = "assets/note.css", url = "/note.css" }]
```

4. Finally update the site's `tola.toml`: set the `[build]` `entry` to `{ module = "notes" }` and override options as needed:

```toml
[build]
entry = { module = "notes" }

[modules.notes.options]
title = "My site"
```

Run `tola build`. Every content page uses the new layout, the browser title reads "My site", and the stylesheet is published at `public/_tola-modules/notes/note.css`. If you change the site's `base-path`, `theme.assets.urls` picks up the new prefix automatically.

= Further customisation and distribution

When a module should be shared or reused by other projects long term, two more things usually follow:

- Export an optional `render-site(...)` function from `lib.typ` and call it from `site.typ`, so consumers can override parts of the layout from their own `site.typ` instead of editing the theme source.
- Add named queries, CLI subcommands, a site initializer, and packing configuration to the module; see #link("/docs/guide/module-publishing/")[Module queries, commands, and publishing] for the steps.

See #link("/docs/concepts/modules-and-themes/")[Modules and themes] for module sources, option merging, and loading boundaries.
