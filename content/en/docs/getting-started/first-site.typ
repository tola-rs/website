#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "Your first site",
  description: "Initialise a project, write two pages, then preview and build it locally.",
  order: 20,
))

#title()

= Initialise a project

Create the site from your working directory:

```sh
tola init my-site
cd my-site
```

`tola init` generates `tola.toml`, `site.typ`, `.gitignore`, `.ignore`, and an empty `content/` directory. The default entry, `site.typ`, publishes the `.typ` files under `content/` as HTML and adds a `404.html`.

= Add page content

Create the two files below under `content/` at the paths shown on their tabs (create `content/guide` first if it does not exist):

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

= Live preview <live-preview>

Start the development server:

```sh
tola dev
```

Open the local address printed by Tola in a browser and follow the link to the installation guide to see `/guide/install/`. Now edit and save `content/guide/install.typ`: the page is rebuilt and refreshed automatically, with no restart needed.

= Check and build

After stopping the development server with `Ctrl+C`, run a full-site check first and then produce the final static files:

```sh
tola check
tola build
```

`tola check` validates the compiled result, output paths, and internal links without touching the publish directory; `tola build` writes the complete site to `public/`:

- `content/index.typ` → `public/index.html`
- `content/guide/install.typ` → `public/guide/install/index.html`
- the default 404 page → `public/404.html`

To get completion, diagnostics, and go-to-definition in your editor, see how to configure a workspace in #link("/docs/getting-started/cli-usage/")[Command line]. To learn how `site.typ` maps source files to HTML paths, continue with #link("/docs/concepts/build-model/")[How a site builds].
