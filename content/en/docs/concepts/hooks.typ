#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Build hooks",
  description: "Run Nushell scripts and external tools before, during, or after a build to extend the site pipeline.",
  order: 60,
))

#title()

When a site needs to compile front-end styles, fetch external data, generate a search index, or deploy automatically, attach the work to the build pipeline with `[[hooks.<stage>]]` in `tola.toml` or `tola-module.toml`. Each hook exits once its run finishes; file watching is scheduled by Tola.

= The three runtime stages

#table(
  columns: (auto, 1fr),
  table.header([Stage], [Use it when]),
  [`before-build`], [You need to prepare inputs before Typst compiles: generate JSON data, compile CSS, or build script assets.],
  [`generate-outputs`], [You need the pages compiled in this run to produce files that ship with the site, such as a search index or `build.txt`.],
  [`after-publish`], [The site has been written to the publish directory and you want to read the result to upload, sync, or notify.],
)

Which stages each command runs, and what development mode does by default:

- `tola build` runs all three stages in order.
- `tola check` and `tola preview` run only the first two and never `after-publish`.
- `tola dev` runs `before-build` and `generate-outputs` and skips `after-publish` by default (set `dev = "run"` to enable it; `generate-outputs` also accepts `dev = "reuse"` to reuse the previous outputs and diagnostics when inputs did not change).
- Within a stage, `order` (default `0`) controls sequence, with lower values first. Hooks with the same `order` run in parallel by default; set `[build] par-hooks = false` to serialise them.

= Enabling and conditional switches

Hooks are enabled by default. Turn one off with `enable = false`, or bind it to a boolean setting with `enabled-by`; project hooks read `[options]` and module hooks read that module instance's options:

```toml
enabled-by = "search.enable"
# If a key name itself contains dots, quote the path segment:
# enabled-by = '"search.enable"'
```

The path must point at a boolean. A missing key, or a parent that is not a table, is an error; `enable = false` skips the lookup entirely.

= `before-build`: prepare inputs

Write `tools/menu.nu` in the project to generate a data file at the site root:

```nu
def main [] {
  mkdir generated
  {title: "My site"} | to json | save --force generated/menu.json
}
```

Declare the hook and its outputs in `tola.toml`:

```toml
[[hooks.before-build]]
name = "menu-data"
nu = "tools/menu.nu"
rerun-on = { include = ["data/**/*.json"] }
generates = ["generated/menu.json"]
```

- `generates` lists output paths relative to the site root (never inside `publish-dir`). Every listed file must exist when the hook exits.
- `rerun-on` declares the input files beyond the entry script whose changes affect the result (module hooks also accept `{ project = "content/**/*.typ" }` to watch site inputs).
- Generated files can be read from Typst as `json("/generated/menu.json")` and, where the browser needs them, published by adding them to `[assets]`. Generating an input does not publish it.

= `generate-outputs`: write published files

Inside the bundled Nushell scripts, read the context of the current call with `get-context`. At this stage `hook.inputDir` holds the compiled pages and assets, and new files go to `hook.outputDir`, which starts empty on every call.

Save this as `tools/build-info.nu`:

```nu
use tola get-context

def main [] {
  let output = (get-context | get hook.outputDir)
  "Built with Tola" | save ($output | path join "build.txt")
}
```

Register the hook in `tola.toml`:

```toml
[[hooks.generate-outputs]]
name = "build-info"
nu = "tools/build-info.nu"
outputs = [{ file = "build.txt" }]
```

- `outputs` declares `{ file = "..." }` or `{ tree = "..." }` relative to the publish root. A generator can only write the paths it declares and cannot overwrite site pages or another hook's files.
- Link to such output from Typst with `output-url("build.txt")`; it does not belong in `[assets]`.
- Data you want to reuse across builds belongs in `hook.cacheDir`; files that only matter for the current call belong in `hook.tempDir`.

= External tools and `after-publish`

Besides bundled `nu` scripts, a hook can call an external executable with `argv = ["tool", "arg1", ...]`. No shell expansion happens, so wildcards and environment variables are not interpreted, and the target machine must have the tool on `PATH`. External tools read the JSON context of the current hook with:

```sh
"$TOLA_EXECUTABLE" nu @tola-scripts/context --json
```

Once the tool parses that JSON it can read the same fields. In `after-publish`, `hook.inputDir` points at the published directory. If that stage fails, the command reports an error and the files already written are kept. Bundled Nushell scripts report problems with `use tola diagnostic` and `diagnostic submit`, while external tools can write a JSON diagnostic report to `reportPath` from the context.

See the #link("/docs/reference/config/hooks/")[`[hooks]` configuration reference] and the #link("/docs/reference/scripts/context/")[`@tola-scripts/context` reference] for every field.
