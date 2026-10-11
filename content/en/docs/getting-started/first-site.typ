#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "Your first site",
  description: "Build and preview a static site with the default template.",
  order: 30,
))

#title()

= Create a project

```sh
tola init my-site
cd my-site
```

The starter uses `site.typ` to publish the Typst files in `content/` as HTML. The content directory starts empty.

= Write content

Run `mkdir -p content/guide`, then save each file at the path shown on its tab.

#code-group((
  (label: "content/index.typ", body: [```typst
= My site

Read the #link("/guide/install/")[installation guide].
```]),
  (label: "content/guide/install.typ", body: [```typst
= Installation guide

Run `tola --version` to print the version.
```]),
), label: "Site source files")

= Preview and build

```sh
tola dev
```

Open the address printed by Tola and follow the link to the installation guide. Save a file to rebuild the site.

Press Ctrl+C to stop the server, then build the site.

```sh
tola build
```

The build writes `public/index.html`, `public/guide/install/index.html`, and `public/404.html`. See #link("/docs/concepts/build-model/")[How a site builds].
