#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Nushell scripts",
  description: "Process structured data and write files from build hooks.",
  order: 30,
))

#title()

= Run a script

Tola runs `.nu` files with its bundled Nushell. Save this as `tools/greet.nu`. The `def main` signature declares the arguments.

```nu
def main [name: string, --upper] {
  let message = $"Hello, ($name)"
  if $upper { $message | str upcase } else { $message }
}
```

```sh
tola nu tools/greet.nu Ada --upper
tola nu tools/greet.nu --help
```

The first command prints `HELLO, ADA`. Pipelines can pass records and lists. For example, `open data.json | get title` reads a field. Use `to json` when you need JSON text.

= Publish a file

Save this as `tools/site-json.nu`.

```nu
use tola [get-hook get-site]

def main [] {
  let destination = ((get-hook).output-dir | path join "site.json")
  {title: (get-site).title} | to json | save --raw $destination
}
```

Set `[site].title` and add the hook to `tola.toml`.

```toml
[[hooks.generate-outputs]]
name = "site-json"
nu = "tools/site-json.nu"
outputs = [{ file = "site.json" }]
```

`tola build` writes the title into `public/site.json`. The hook supplies the output directory. To share helper functions, use `export def` in a module and `use` in the script.

= Built-in scripts

```sh
tola nu @tola-scripts/image metadata photo.png
tola nu @tola-scripts/image resize photo.png --width 640 --op fit-width --format webp --output preview.webp
tola check --json > check.json
tola nu --stdin @tola-scripts/diagnostic render < check.json
```

The image commands need an existing `photo.png`, and the resize destination must be new. The diagnostic renderer reads the check report. Place the Tola option `--stdin` before the script name and script options after it.

Use `tola nu --help` for libraries or #link("/docs/reference/scripts/")[Built-in scripts] for command options.
