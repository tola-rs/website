#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "Local modules",
  description: "Export a shared component and use the module as a theme.",
  order: 20,
))

#title()

= Define a component

In #link("/docs/getting-started/first-site/")[Your first site], create `theme/` and save the manifest and component at the paths shown on the tabs.

#code-group((
  (label: "theme/tola-module.toml", body: [```toml
[typst]
entry = "lib.typ"
```]),
  (label: "theme/lib.typ", body: [```typst
#let note(body) = html.aside(class: "note", body)
```]),
), label: "Module files")

= Register the module

Add this to `tola.toml`.

```toml
[modules.notes]
path = "theme"
```

Append this to `content/index.typ`.

```typst
#import "@tola-modules/notes:0.0.0": note
#note[Check the version before installing.]
```

Run `tola module check ./theme` and `tola check`. Open the home page with `tola dev` and look for `<aside class="note">` in the source.

= Module entry

Save this as `theme/site.typ` to move the page layout into the module.

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

`source.file` still refers to a site source. `theme.assets.urls` supplies the browser URL of the module stylesheet.

Append to `theme/tola-module.toml`:

```toml
[build]
entry = "site.typ"

[options]
title = "Notes"

[assets]
files = [{ source = "assets/note.css", url = "/note.css" }]
```

Save this stylesheet as `theme/assets/note.css`.

```css
.reading { max-width: 42rem; margin: 2rem auto; padding: 0 1rem; }
.note { padding: 0.75rem 1rem; border-inline-start: 0.25rem solid currentColor; }
```

Set the existing site `[build]` entry to `entry = { module = "notes" }` and add this option.

```toml
[modules.notes.options]
title = "My site"
```

Run `tola build`. The home page and installation guide use the new layout and browser title. The stylesheet appears at `public/_tola-modules/notes/note.css`, and its URL follows the site's `base-path`.

See #link("/docs/concepts/modules-and-themes/")[Modules and themes] for module sources and options.
