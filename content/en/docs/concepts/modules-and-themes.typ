#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Modules and themes",
  description: "Understand module manifests, source declarations, option merging, and how to customise a site without patching its theme.",
  order: 70,
))

#title()

A module is a directory with a `tola-module.toml` in it. A module can supply nothing more than a set of reusable Typst components or a Nushell helper library, or it can declare `[build] entry` and act as a complete theme, taking over page selection, route generation, and page rendering for the site.

= What a module manifest declares

`tola-module.toml` declares the capabilities a module offers:

#table(
  columns: (auto, 1fr),
  table.header([Key], [Use]),
  [`[typst] entry`], [Exports public Typst functions and components, imported by a site as `@tola-modules/<alias>:0.0.0`.],
  [`[build] entry`], [Supplies an entry program that a site can use as its theme.],
  [`[nu] entry`], [Exports public Nushell definitions, imported by scripts with `use tola-modules <alias>`.],
  [`[queries]`], [Registers named Typst queries, reachable as `tola query <alias>.<name>`, with editor completion and go-to-definition.],
  [`[commands]`], [Registers module subcommands, such as `tola docs guide` from this site's `docs` module.],
  [`[init]`], [Registers a site initializer, available as `tola init <dir> --from <source>`.],
  [`[pack]`], [Declares which files to include or leave out when packing a module for publication, used by `tola module pack`.],
)

= Registering a module and choosing its source

Register a module with `[modules.<alias>]` in the site's `tola.toml`; the consuming site picks the alias. Each module takes exactly one source from `path`, `git`, or `tarball`:

```toml
[build]
entry = { module = "blog" }

[modules.blog]
path = "theme"

[modules.blog.options]
show-title = true
```

- *Local directory (`path`)*: a directory path resolved against `tola.toml`.
- *Git repository (`git`)*: takes `url`, an optional `subdir`, and one of `tag`, `branch`, or a full `rev` (omit all three to use the default branch).
- *Archive (`tarball`)*: supports `tar.gz`, `tar.zst`, and `zip` from a local `path` or a remote `url`, with an optional `sha256` check. The archive must contain one top-level directory holding `tola-module.toml`.

The resolved version digest of a remote repository or archive is pinned in `tola.lock`; run `tola update <alias>` when you want to pull a newer revision. To use only a module's components and keep the site's own `site.typ`, configure `[modules.<alias>]` and leave `[build] entry` alone.

= Options and customising a theme

Theme defaults live in the manifest's `[options]`, and the site overrides them under `[modules.<alias>.options]`. Dictionary tables merge recursively, while arrays and scalar values are replaced as a whole. Inside the module, `get-module()` reads the options and assets of the current instance; site code and external templates use `get-module("<alias>")` to read a named instance.

To customise a site without editing the theme's source, work through these steps in order:

1. *Adjust options first.* Start with the `[modules.<alias>.options]` and style settings the theme documents.
2. *Replace static assets.* Use `[modules.<alias>.assets.replace]` to substitute a site-local file for a specific asset the theme declares, keeping the module's URL.
3. *Wrap the entry function.* If the theme exports a customisable render function such as `render-site`, point `[build] entry` back at the site's own `"site.typ"`, import the theme's render function there, and pass your own layout callbacks.

Inside a module, reading package files, static assets, and site project files each resolves from a different root; see #link("/docs/concepts/routes-and-urls/")[Site paths]. To write your first module and theme, start with #link("/docs/guide/local-module/")[Local modules].

See the #link("/docs/reference/config/modules/")[`[modules]` configuration reference] for the full set of manifest fields.
