#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Deploy a site",
  description: "Check the build, preview the deployment path, and upload the site.",
  order: 10,
))

#title()

= Missing pages and links

```sh
tola inspect sources
tola check --json --pretty
```

Find the source in `inspect sources`. If it is missing, check the content directory, file extension, and hidden paths. Then read the report's `pages` and `routes` to see what address the entry assigned it. Fix build errors at the location reported.

`tola check` validates output paths and local references without replacing the publish directory. It runs configured build-input and output-generation hooks.

= Deployment prefix

For a production URL such as `https://example.com/notes/`, configure the origin and prefix.

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

Use `base-path = "/"` at the domain root. Replace hard-coded links in the starter with #link("/docs/concepts/routes-and-urls/")[`output-url`].

```sh
tola preview
```

Open the address printed by the command and check that pages and assets load. `preview` builds once with production settings. Run it again after edits.

= Upload

Press Ctrl+C to stop the preview, then build.

```sh
tola build
```

Upload the whole `public/` directory, or the configured `[build].publish-dir`. Build replaces it, so declare hand-maintained files under `[assets]` to include them.

Mount the directory at `base-path`. Check that your host maps `/notes/guide/install/` to `guide/install/index.html`, and configures `404.html` as needed.
