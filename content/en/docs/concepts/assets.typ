#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Static assets",
  description: "Publish and link to images, stylesheets, scripts, and fonts.",
  order: 30,
))

#title()

= Asset declarations

Save a logo as `static/logo.svg` and add this to `tola.toml`.

```toml
[assets]
cache-busting = true
files = [{ source = "static/logo.svg", url = "/media/logo.svg" }]
trees = [{ source = "static/styles", url-prefix = "/styles" }]
```

`files` assigns URLs to individual files. `trees` preserves paths within a directory. For example, `static/styles/main.css` lands at `public/styles/main.css`. Use `include` and `exclude` to filter paths relative to the site or module root. An explicit file declaration takes precedence over a tree.

= File symlinks

Set `follow-file-symlinks = true` on a tree to publish regular files through symlinks. If `static/downloads/guide.txt` points to `shared/notes.txt`, the published URL uses `guide.txt` and serves the target's contents.

```toml
[[assets.trees]]
source = "static/downloads"
url-prefix = "/downloads"
follow-file-symlinks = true
```

Filters match the link's own path. Broken links and links to directories are errors. A module symlink must point inside that module. In a `--pure` build, site links must point inside the site.

= Asset URLs

```typst
#import "@tola/address:0.0.0": asset-url

#html.img(src: asset-url("/media/logo.svg"), alt: "Site logo")
```

Pass the declared URL to `asset-url`. It adds the deployment prefix and, with caching enabled, a `?h=…` suffix that changes with the file. The output filename stays the same.

Use `asset-url` for stylesheets too. The browser resolves CSS `url(...)` against the published stylesheet. From `/notes/styles/main.css`, `url("../media/logo.svg")` resolves to `/notes/media/logo.svg`.

= Publishing assets

`read`, `json`, and `image` read inputs to the compiler. Declare an asset when the browser needs to request the original file. Use `@tola/image` to generate thumbnails or responsive sizes during the build.

`[typst.fonts]` configures fonts for Typst rendering, including SVG produced with `html.frame`. See `tola inspect fonts`. Ship browser fonts as static assets and load them with CSS `@font-face`.

= Generated assets

Declare a generated file with Bundle's `asset`.

```typst
#asset("data/site.json", json.encode((title: "My site")))
```

This writes `public/data/site.json`. Link to it with `output-url("data/site.json")`. For outputs from external tools, see #link("/docs/concepts/hooks/")[Build hooks].
