#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Build hooks",
  description: "Generate inputs and outputs or run commands after publication.",
  order: 60,
))

#title()

= Stages

#table(
  columns: (auto, 1fr),
  table.header([Stage], [Use]),
  [`before-build`], [Produce inputs such as JSON and compiled CSS.],
  [`generate-outputs`], [Read compiled pages and publish files such as a search index.],
  [`after-publish`], [Work with the published directory, for example to upload it.],
)

`build` runs all three. `check`, `preview`, and by default `dev` run the first two. Use `rerun-on` to watch extra files read by the hook.

= Conditions

`enabled-by = "images.enable"` reads a boolean from the site options for a project hook or from the instance options for a module hook. Quote a key segment containing a literal dot, as in `enabled-by = '"images.enable"'`. Missing keys and non-boolean values are errors. `enable = false` skips the lookup. The same syntax applies to module assets.

= Build inputs

Save this as `tools/menu.nu`.

```nu
def main [] {
  mkdir generated
  {title: "My site"} | to json | save --force generated/menu.json
}
```

Add the hook to `tola.toml`.

```toml
[[hooks.before-build]]
name = "menu-data"
nu = "tools/menu.nu"
generates = ["generated/menu.json"]
```

The hook runs at the site root. Every declared file must exist when it finishes. Read the data from a page or the entry.

```typst
#let menu = json("/generated/menu.json")
#menu.title
```

The JSON is a compiler input. Declare it under `[assets]` if the browser needs the original file.

= Published outputs

A `generate-outputs` hook receives the built site and an empty output directory. Declare a file as `{ file = "search.json" }` or a tree as `{ tree = "search" }` using paths relative to the publish directory. Outputs cannot overwrite a page or another hook's file.

Read `(get-hook).input-dir` and `(get-hook).output-dir` after `use tola get-hook`. An external command can use `TOLA_HOOK_INPUT_DIR` and `TOLA_HOOK_OUTPUT_DIR`.

= External tools

Choose `nu` for a Nushell script or `argv` for a program followed by its arguments. Put shell pipelines and substitutions in a script. The executable must be on `PATH`.

Run `"$TOLA_EXECUTABLE" nu @tola-scripts/context --json` inside an external hook to read its settings and directories. See #link("/docs/reference/scripts/context/")[context] for an example and `tola help "[hooks]"` for the configuration keys.
