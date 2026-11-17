#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Writing Nushell scripts",
  description: "Run site scripts with typed parameters in the bundled Nushell, write files from build hooks, and call the bundled image and diagnostic tools.",
  order: 40,
))

#title()

Tola bundles its own Nushell runtime, so nothing has to be installed locally, and it never loads your personal environment, which keeps script behaviour identical on every machine.

= Running site scripts

Save a script that needs argument parsing as `tools/greet.nu`; the type signature of `def main` generates parameter validation and `--help` text automatically:

```nu
# Build a greeting from a name
def main [name: string, --upper] {
  let message = $"Hello, ($name)"
  if $upper { $message | str upcase } else { $message }
}
```

```sh
tola nu tools/greet.nu Ada --upper
tola nu tools/greet.nu --help
```

A few habits to follow:

- *Never call `main` manually at the end of a script.* Nu runs `main` after the top-level code. Keep the top level free of side effects so `--help` never writes files by accident.
- *Keep data structured.* Use `open` to parse JSON and TOML (`open --raw` for plain text), filter or reshape records through pipelines, and convert with `to json | save --raw ...` only when writing to disk or handing data to another process.
- *Pass standard input.* When a script should read piped input, put Tola options such as `--stdin` before the script path, as in `printf '%s' '{"name":"Tola"}' | tola nu --stdin upper.nu`.
- *Share helper functions.* Put pure functions in their own file, export them with `export def`, and import them with `use`. Send progress messages to `print --stderr` so they never mix with the structured return value.

= Writing site files from a build hook

Save this script as `tools/site-json.nu`. `get-context` returns the context of the current call, and `hook.outputDir` is the output directory that the `generate-outputs` stage assigns to this hook. The site title comes from `get-site`.

```nu
use tola [get-context get-site]

def main [] {
  let destination = (get-context | get hook.outputDir | path join "site.json")
  {title: (get-site).title} | to json | save --raw $destination
}
```

Set `title` under `[site]` in `tola.toml` and register the `generate-outputs` hook:

```toml
[[hooks.generate-outputs]]
name = "site-json"
nu = "tools/site-json.nu"
outputs = [{ file = "site.json" }]
```

After `tola build`, `public/site.json` contains the site title. The script has to run in a `generate-outputs` hook because only that stage provides `hook.outputDir`. See #link("/docs/reference/scripts/context/")[`@tola-scripts/context`] for the fields each stage supplies.

= Calling the bundled image and diagnostic scripts

Tola also ships the `@tola-scripts/*` tools, which are meant to be called directly from the command line or a build pipeline:

```sh
tola nu @tola-scripts/image metadata photo.png
tola nu @tola-scripts/image resize photo.png --width 640 --op fit-width --format webp --output preview.webp
tola check --json > check.json
tola nu --stdin @tola-scripts/diagnostic render < check.json
```

- `@tola-scripts/image` reads image metadata or resizes and converts images without any external image tooling. The `--output` file must not exist yet, and a single dimension keeps the aspect ratio.
- `@tola-scripts/diagnostic` renders structured diagnostic JSON as a highlighted terminal view. To report warnings or errors directly from a Nu hook or module command, use `use tola diagnostic` with `diagnostic submit` to add them to the build report.

Run `tola nu --help` to see the libraries available in the current environment, and see the #link("/docs/reference/scripts/")[Built-in scripts reference] or `tola help scripts` for every script parameter.
