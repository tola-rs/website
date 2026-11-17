#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Static assets",
  description: "Separate compile-time inputs from browser resources, and publish images, stylesheets, scripts, and fonts.",
  order: 40,
))

#title()

Reading a file in Typst code does not publish it to the site: `read(...)`, `json(...)`, and `image(...)` only read compile-time inputs. Stylesheets, scripts, fonts, downloadable files, and original images that a browser requests directly must be declared as static assets or build outputs.

= Declaring static assets

Map individual files with `files` or whole directory trees with `trees` under `[assets]` in `tola.toml`:

```toml
[assets]
cache-busting = true
files = [{ source = "static/logo.svg", url = "/media/logo.svg" }]
trees = [{ source = "static/styles", url-prefix = "/styles" }]
```

After the build, `static/logo.svg` is published at `public/media/logo.svg` and `static/styles/main.css` at `public/styles/main.css`.

Rules for a directory tree:

- `include` and `exclude` patterns filter the files in a tree, with paths relative to the site or module root. Without `include` the whole tree is included (`["."]`); set it to `[]` to select nothing.
- When a source file matches both `files` and a `trees` entry, the explicit `files` declaration wins, even when that entry is disabled, so the file is not published unexpectedly through the overlapping tree.

== File symlinks inside a tree

Directory trees skip symlinks by default. To publish a symlink that points to a regular file, enable `follow-file-symlinks = true` on that entry:

```toml
[[assets.trees]]
source = "static/downloads"
url-prefix = "/downloads"
follow-file-symlinks = true
```

Tola publishes the target file's contents under the link's own path and name, and `include` / `exclude` match that link path. Links to directories or broken links are errors. A link inside a module must not leave the module directory, and in a `--pure` build the target must stay inside the site.

= Referencing assets from a page

Reference files declared in `[assets]` with `asset-url` from `@tola/address`:

```typst
#import "@tola/address:0.0.0": asset-url

#html.link(rel: "stylesheet", href: asset-url("/styles/main.css"))
#html.img(src: asset-url("/media/logo.svg"), alt: "Site logo")
```

The value you pass is the site path declared in the configuration, without the deployment prefix. `asset-url` checks that the asset exists, adds `site.base-path`, and appends a `?h=…` query when `cache-busting` is on, so a changed file gets a fresh URL while the published filename stays the same.

#callout[
  Tola neither bundles JavaScript nor rewrites `url(...)` inside CSS. If `/notes/styles/main.css` contains `url("../media/logo.svg")`, the browser resolves it against the published stylesheet and requests `/notes/media/logo.svg`.
]

= Images and fonts

- *Images*: embed vector or raster images in the layout with Typst's native `image(...)`; deliver an original file untouched with `html.img(src: asset-url(...))`; and when you only need scaled derivatives or a responsive `srcset`, use `@tola/image` (see #link("/docs/guide/page-presentation/")[Images, icons, and code]). Keeping originals out of `[assets]` avoids publishing them unnecessarily.
- *Fonts*: compiler fonts and web fonts are independent. `[typst.fonts]` only configures the fonts the Typst compiler may use when it renders `html.frame` (SVG diagrams, for example); list them with `tola inspect fonts` (note that `--pure` builds exclude host system fonts, so ship fonts from the project or a module). Web fonts for the browser must be published through `[assets]` and loaded with CSS `@font-face`.

= Generating assets from code

To emit a static file straight from Typst code at build time, such as site data as JSON, call `asset(...)` at the top level of the entry:

```typst
#import "@tola/address:0.0.0": output-url

#asset("data/site.json", json.encode((title: "My site")))
```

The build writes `public/data/site.json`. Because it is a Bundle output rather than an `[assets]` entry, link to it with `output-url("data/site.json")`. When an external script or tool should produce the file instead, see #link("/docs/concepts/hooks/")[Build hooks].

See the #link("/docs/reference/config/assets/")[`[assets]` configuration reference] for every field.
