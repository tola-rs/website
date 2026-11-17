#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Command line",
  description: "Use dev, check, preview, build, plus the configuration, formatting, and editor commands.",
  order: 30,
))

#title()

Site commands walk up from the current directory to the nearest `tola.toml`. To work on a site elsewhere, pass the configuration path with `-C`:

```sh
tola inspect -C path/to/tola.toml config
```

= Everyday development workflow

#table(
  columns: (auto, 1fr),
  table.header([Command], [What it does]),
  [`tola dev`], [Starts a local server, watches for changes, and rebuilds and updates in place automatically.],
  [`tola check`], [Builds and validates output paths and internal references without touching the publish directory.],
  [`tola preview`], [Builds once with production settings and serves the result from memory.],
  [`tola build`], [Writes the complete site to the publish directory (default `public/`) after validation passes.],
)

== Init and version

```sh
tola --version
tola init my-site --dry-run
tola init my-site
```

- `--version` prints the versions of Tola and its bundled Typst and Nushell.
- `init` accepts a missing or empty directory by default and generates `tola.toml`, `site.typ`, `.gitignore`, `.ignore`, and an empty `content/`. Add `--dry-run` to preview the files it would create, or `--force` to initialise a non-empty directory without overwriting existing files. When a theme provides an initializer, use `tola init my-site --from <source>`.

== Local development <local-dev>

```sh
tola dev
tola dev --port 0
```

`--port 0` lets the system pick a free port. Open the address the terminal actually prints, especially when the port is taken or a `base-path` is configured, and press `Ctrl+C` to stop the server.

If a page still shows old content after an edit, read the diagnostics in the terminal first: when a rebuild fails the development server keeps serving the last successful build. External scripts that need build events can run `tola dev --json`, which emits one JSON event per line (including `server-ready` and `build-finished`).

== Checks and preview <check-and-preview>

```sh
tola check
tola preview --base-path /notes/
```

`tola check` runs the pre-build hooks, compiles the site, and validates outputs and references, but never replaces the publish directory. Additional options:

- `--no-build` checks only the syntax of the site's own Typst sources without a full compile, so imports, evaluation, routes, and links go unverified.
- `--no-hooks` skips the `before-build` and `generate-outputs` hooks and uses whatever generated inputs are already on disk.

`tola preview` builds once with production settings (minification, `base-path`, and so on) and serves the result from memory, which makes it the right tool to verify a deployment prefix, minified scripts and styles, and the 404 page before shipping. `--base-path` tries a different deployment path temporarily. Re-run the command after editing files.

== Building the publish directory

```sh
tola build
tola build -o public-review
```

The default output is `public/`. `-o` selects another output directory inside the project; it must be empty or already hold a Tola publication record for the same site.

= Configuration checks and troubleshooting

When a page is missing or the build fails, narrow it down in this order:

```sh
tola doctor
tola inspect config
tola inspect sources
tola inspect fonts
tola inspect icons
tola check --json --pretty
```

- `doctor` checks site configuration, paths, and the environment of external tools.
- `inspect config` shows the merged effective configuration, including the resolved entry, input directory, and publish path.
- `inspect sources` lists the source files Tola discovered. If a file you expect is missing, check the `content-dir` setting, the lowercase `.typ` extension, hidden directories, and symlinks.
- `check --json --pretty` prints a structured report for comparing `pages`, `routes`, and reference errors; add `-v` for more detail.
- `inspect fonts` and `inspect icons` list the fonts visible to the Typst compiler and the configured icon collections respectively (add a collection name to list its icons). Fonts used by the browser have to be checked in CSS and the browser's network panel.

To keep the complete build report, run `tola build --json --pretty > build-report.json`. When a post-publication hook fails, the files already written to the publish directory are kept, and the `published` field in the report tells you the state.

= Formatting and editors <editor-setup>

```sh
tola fmt --check
tola editor setup --list
tola editor template vscode
```

- `tola fmt --check` only reports formatting differences; drop `--check` to rewrite the site's Typst sources. Formatting rules live under `[formatter]` in `tola.toml` and are shared by the CLI and the language service.
- `tola editor setup <editor>` merges workspace settings into a supported editor such as `vscode` or `helix`, while `editor template` prints the settings template. After upgrading Tola, run `tola editor packages` to refresh the built-in package declarations the editor uses. Other LSP-capable editors can connect to `tola lsp` directly.
- Add `--nu` (for example `tola editor setup helix --nu`, or `tola editor setup vscode --nu` on macOS and Linux) to configure the bundled Nushell language server at the same time; for manual setup the command is `tola nu --lsp`.

= More tooling commands

- `tola nu --help` lists the bundled Nu libraries and scripts; `tola nu tools/report.nu --help` shows the options of a site script.
- `tola query` runs a Typst data query from the site or a module (see #link("/docs/guide/site-data/")[Site data and queries]).
- `tola update` and `tola vendor` refresh `tola.lock` and bundle inputs for offline builds (see #link("/docs/guide/deploy/")[Checks, offline builds, and deployment]).
- `tola module check` and `tola module pack` validate or pack a module for publication.
- `tola <module-alias> --help` lists the subcommands a module registers in this site, such as `tola docs guide` here.
- `tola completions --help` and `tola manpage --help` generate shell completions and a man page.

Run `tola <command> --help` at any time for the full options; configuration and built-in package documentation live in the #link("/docs/reference/overview/")[Reference overview]. From here, read #link("/docs/concepts/build-model/")[How a site builds] to understand the build model in depth.
