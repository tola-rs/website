#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Command line",
  description: "Use init, dev, check, build, and the editor commands.",
  order: 20,
))

#title()

= Projects and configuration

```sh
tola --version
tola init my-site --dry-run
tola init my-site
cd my-site
tola inspect config
```

`--version` prints the versions of Tola, Typst, and Nushell. `init` expects a missing or empty directory. `--dry-run` lists planned files. `--force` allows other files in the directory while preserving existing starter files. Use `tola init my-site --from <source>` with a theme initializer.

Commands find the nearest `tola.toml` by walking up from the current directory. Use `-C` to choose one explicitly.

```sh
tola inspect -C path/to/tola.toml config
```

= Development and builds

== Local development

```sh
tola dev
tola dev --port 0
```

`dev` rebuilds when files change and updates the browser. `--port 0` selects a free port. Open the address printed by the command. Press Ctrl+C to stop.

If a page stays stale, check the terminal. The server keeps serving the last successful build when a rebuild fails. `tola dev --json` emits one event per line. `server-ready` reports the address and `build-finished` reports the result.

== Checks and preview

```sh
tola check
tola preview
```

`check` builds and validates links without updating the publish directory. `--no-build` parses Typst syntax only. A full check also evaluates imports and validates outputs.

`preview` serves one in-memory build using production settings. Restart it after edits. Both commands run the first two hook stages. Use `tola check --no-hooks` with existing generated inputs.

== Build output

```sh
tola build
```

`build` writes to `public/` by default. Use `tola build -o public-review` to keep a separate build. The target must be within the project and either empty or previously published by the same site. Try a different deployment prefix with `tola preview --base-path /notes/`.

= Troubleshooting

== Missing pages

```sh
tola inspect sources
tola check --json --pretty
```

Find the source in `inspect sources`. If it is missing, check the content directory, extension, hidden paths, and symlinks. Then check `pages` and `routes` for the output selected by the entry or theme. Compare the browser URL against the deployment prefix.

== Fonts, icons, and entry

```sh
tola doctor
tola inspect config
tola inspect fonts
tola inspect icons
```

`doctor` reports configuration and tool problems. `inspect fonts` lists fonts visible to Typst. Check browser fonts in CSS and the browser's network panel. Pass a collection name to `inspect icons` to list its members.

Use `tola check -v` for more detail or `tola build --json --pretty > build-report.json` for a machine-readable report. If a post-publication hook fails, check `published` to see whether Tola wrote the site.

= Formatting and editors

```sh
tola fmt --check
tola editor setup --list
tola editor template vscode
```

`fmt --check` reports formatting differences. `tola fmt` applies them. `editor template` prints settings. `editor setup` merges workspace settings, and `editor packages` refreshes packages used by the editor. Other LSP clients can run `tola lsp`.

`tola editor setup helix --nu` configures the bundled Nushell language server. On macOS and Linux, `tola editor setup vscode --nu` creates a launcher for the VS Code Nushell extension. For manual setup, use `tola nu --lsp`.

= Dependencies and offline builds

`tola.lock` pins resolved inputs. Run `tola update <module> --dry-run` to see the modules and icon collections checked and the changes to their lock entries. Run without `--dry-run` to apply the update or without a name to refresh all remote inputs.

#table(
  columns: (auto, 1fr),
  table.header([Option], [Behavior]),
  [`--locked`], [Check the lockfile and fetch missing pinned inputs without changing it.],
  [`--offline`], [Use available local inputs and report what is missing.],
  [`--pure`], [Use the site and its vendored inputs, without host caches, packages, or fonts.],
)

```toml
[vendor]
path = "vendor"
```

```sh
tola vendor --dry-run
tola vendor
tola build --pure
```

`vendor` copies resolved packages, modules, and remote icons. Configure fonts through the site or its modules. External programs launched by hooks still use their own environment.

= Scripts, modules, and queries

- `tola nu tools/report.nu --help` shows script options. `tola nu --help` lists bundled libraries and scripts.
- `tola module check ./theme` validates a module. `tola module pack` prepares it for distribution.
- `tola <alias> --help` lists commands exported by the module. This site's `tola docs guide` opens the theme guide.
- `tola completions --help` and `tola manpage --help` describe shell completions and man pages.

== Site queries

In #link("/docs/getting-started/first-site/")[Your first site], save this as `tools/model.typ` to expose source paths through a Typst metadata element.

```typst
#import "@tola/source:0.0.0": all-sources
#metadata(all-sources().map(source => source.path)) <model>
```

```sh
tola query ./tools/model.typ --label model --json --pretty
```

The example returns `guide/install.typ` and `index.typ`. Queries skip build hooks and leave the publish directory alone. Run a query from a theme with `tola query <alias>.<query>`.

See #link("/docs/reference/overview/#offline-help")[Offline help] for configuration and API lookups.
