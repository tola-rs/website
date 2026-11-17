#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Checks, offline builds, and deployment",
  description: "Validate pages and links before going live, pin and vendor dependencies for offline builds, then preview and deploy the publish directory.",
  order: 70,
))

#title()

= Pre-deployment checks

Before publishing, confirm that every page made it into the output as expected and that no link or asset is missing:

```sh
tola inspect sources
tola check --json --pretty
```

- If a source does not appear in the page list, first check whether `tola inspect sources` discovered it (verify `content-dir`, the lowercase `.typ` extension, hidden directories, and symlinks). If the source is there but not rendered, check the filters of the entry or theme, for example a `draft: true` flag.
- `tola check` runs the before-build and generate-outputs hooks, validates every route and internal link, and leaves the existing publish directory untouched.

= Verifying the production origin and path prefix

If the site is deployed under a sub-path such as `https://example.com/notes/`, set `origin` and `base-path` in `tola.toml` (`base-path = "/"` when it sits at the domain root):

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

Make sure internal links in templates and prose are built with #link("/docs/concepts/routes-and-urls/")[`output-url`, `route-url`, or `asset-url`] rather than hard-coded absolute paths without the prefix, then start a production preview:

```sh
tola preview
```

Open the preview address the terminal prints and click through navigation links, images, styles, and the 404 page to confirm everything loads. To try another prefix temporarily, run `tola preview --base-path /notes/` directly.

= Dependency pinning and pure offline builds

The remote modules and icon collections a site references are recorded in `tola.lock`. Commit that file so collaborators and CI resolve exactly the same inputs. When remote modules should move forward, preview the change before refreshing the lock entries:

```sh
tola update <module-alias> --dry-run
tola update <module-alias>
```

These build options restrict where inputs may come from:

#table(
  columns: (auto, 1fr),
  table.header([Option], [When to use it]),
  [`--locked`], [Require inputs to match `tola.lock` exactly and never rewrite the lockfile; pinned remote inputs may still be downloaded.],
  [`--offline`], [Forbid network access and use only local and cached inputs, failing when one is missing.],
  [`--pure`], [Use only project files and pinned inputs under `vendor`, excluding host caches, global packages, and system fonts.],
)

For a fully self-contained `--pure` build on an offline machine or in CI, configure `[vendor]` in `tola.toml` and bundle the dependencies:

```toml
[vendor]
path = "vendor"
```

```sh
tola vendor --dry-run
tola vendor
tola build --pure
```

#callout[
  `vendor` copies the selected Typst packages, remote modules, and icon collections, but never compiler fonts. A pure build environment has to supply fonts through the project's configured font paths or a module's font directory. External tools launched by hooks still run with their own environment.
]

= Building and uploading

Press `Ctrl+C` to leave the preview, then run the production build:

```sh
tola build
```

Upload everything inside `public/` (or the directory named by `[build].publish-dir`) to a hosting service or web server, and configure the host as follows:

- Map a directory path such as `/notes/guide/install/` to the matching `index.html`.
- Point unmatched paths at the `404.html` in the site root.
- If `[[hooks.after-publish]]` uploads the site, note that the build has already written the publish directory; when the upload hook fails the command reports an error and the files on disk are not rolled back.
