#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Module queries, commands, and publishing",
  description: "Register Typst queries and editor navigation for a module, expose CLI commands and a site initializer, and pack it for other sites.",
  order: 60,
))

#title()

Beyond components and layouts, a module can package queries, command-line tools, and site scaffolding for the sites that use it. Everything below is declared on demand in `tola-module.toml`.

= Registering queries and editor navigation

A module exports a Typst file with a `<label>` through `[queries.<name>]`, so outside tools can read structured site data:

```toml
[queries.pages]
entry = "queries/pages.typ"
label = "page-list"
```

Inside `queries/pages.typ`, reuse the theme's own page list function so query results match what a build actually produces:

```typst
#import "../lib.typ": pages
#import "@tola/address:0.0.0": output-url

#metadata(pages().map(page => (
  title: page.source.meta.title,
  output: page.output,
  url: output-url(page.output),
))) <page-list>
```

In a consuming site, `tola query notes.pages --json` returns the data as JSON; queries run no build hooks.

To give editors completion, hover documentation, go-to-definition, and rename support for specific parameters of a module's public functions, declare `references` and `definitions` on that query. Each query record must then contain `id` and `name`, plus optional `description`, `source`, and `url` fields:

```toml
[[queries.index.references]]
export = "page-link"
parameter = { positional = 0 }

[[queries.index.definitions]]
export = "page"
parameter = { named = "id" }
```

= Registering module commands and a guide

`[commands.<name>]` registers a subcommand that belongs to the module and runs as `tola <module-alias> <command>`:

```toml
[commands.greet]
nu = "tools/greet.nu"

[commands.pages]
query = "pages"
projection = ["title", "url"]

[commands.guide]
skill = "GUIDE.md"
```

- `nu` runs a Nushell script inside the module. After `use tola get-context`, read the current module alias with `get-context | get module.name` and the module options as overridden by the site with `get-context | get module.options`. Report problems with `use tola diagnostic` and `diagnostic submit`.
- `argv` runs an external command, which reads the call context with `"$TOLA_EXECUTABLE" nu @tola-scripts/context --json`.
- `query` exposes a declared named query directly, with no wrapper script; use `projection` to choose the displayed columns.
- `skill` binds a module authoring document, so a consumer can run `tola <alias> guide` to read it section by section in the terminal.

= Providing a site initializer

With `[init]` declared, users can scaffold a matching site with `tola init my-site --from <module-source> --alias <alias>`:

```toml
[init]
nu = "tools/init.nu"
```

After `use tola get-context`, the initializer script reads these fields from the context:

- `init.outputDir` is a temporary output directory. Write every generated file there; Tola validates the result and moves it into the target directory.
- `init.targetDir` is the final site directory, which relative paths in generated configuration resolve against.
- `module.name` and `module.root` are the alias and root directory chosen for this run. Tola keeps the module's original source in the new site configuration.

See #link("/docs/reference/scripts/context/")[`@tola-scripts/context`] for the remaining fields and for external scripts.

= Packing and distributing

If a module contains files that have to be compiled ahead of time, such as built CSS or JavaScript, list the runtime files for the publish directory in `[pack]` and generate them before packing with `[[hooks.before-pack]]`:

```toml
[pack]
include = ["lib.typ", "site.typ", "assets", "queries", "tools"]
exclude = ["assets/**/*.map"]

[[hooks.before-pack]]
name = "compile-assets"
nu = "author/assets.nu"
```

Pack the module and validate the result:

```sh
mkdir -p dist
tola module pack ./theme --output ./dist/theme
tola module check ./dist/theme
```

`tola module pack` runs `before-pack` first (scripts read the module source directory with `get-context | get hook.inputDir`), copies the files selected by `[pack]` to the target directory, and removes `pack` and `hooks.before-pack` from the delivered `tola-module.toml`. Consumers therefore use the prepared artifacts without installing the author's build tools.

#callout[
  A module published as an archive (`.tar.gz`, `.tar.zst`, or `.zip`) must keep one top-level directory holding `tola-module.toml`, for example `tar -czf dist/theme-v1.0.0.tar.gz -C dist theme`. Source archives that GitHub generates automatically never run `before-pack`, so if a theme depends on prepared assets, attach the packed archive to a release, or commit the packed output into a Git subdirectory and point `git.subdir` at it.
]

Before publishing, create a test site that references `./dist/theme`, change the module alias, override options, set a non-root `base-path`, and get `tola check`, `tola build`, and a browser preview passing. See `tola skill modules --all` for more detail.
