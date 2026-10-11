#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "How a site builds",
  description: "Read content files, declare HTML outputs, and build the site.",
  order: 10,
))

#title()

= Entry and sources

`[build].entry` in `tola.toml` points to a project file such as `site.typ` or to a theme module. `all-sources()` returns the files discovered under the configured content directory, which defaults to `content/`.

Tola lists lowercase `.typ` extensions in path order and skips hidden files and directories, symlinks, and the entry file. Keep shared templates and components outside the content directory.

= HTML output

The starter publishes pages with this loop.

```typst
#import "@tola/address:0.0.0": join-route, output-of
#import "@tola/source:0.0.0": all-sources

#for source in all-sources() {
  document(output-of(join-route(source.route-segments)), format: "html")[
    #include source.file
  ]
}
```

The starter uses `join-route` to assemble a route from the source's segments, then calls `output-of` to get the relative HTML path. `document` declares that output in the Bundle, and `include` inserts the source body. You can filter the source list before the loop or include several files in the same `document`.

Append this to `site.typ` from #link("/docs/getting-started/first-site/")[Your first site]. `tola build` writes `public/pages/index.html`. Open `/pages/` in the preview for links to the home page and installation guide.

```typst
#import "@tola/address:0.0.0": output-url

#document("pages/index.html", format: "html", title: "Page index")[
  = Page index
  #for source in all-sources() [
    #let output = output-of(join-route(source.route-segments))
    - #link(output-url(output))[#raw(source.path)]
  ]
]
```

The index and the content loop use the same route calculation. Add a Typst file under `content/` and the next build writes the corresponding HTML file and links to it from the index.

= Build and checks

```mermaid
flowchart LR
  accTitle: Tola build
  accDescr: site.typ reads the content files and Tola writes the resulting HTML to public.
  source["content/*.typ"] --> entry["site.typ"] --> output["public/"]
```

The entry compiles as a Typst Bundle. Tola combines its outputs with configured static files and hook outputs, then checks for duplicate output paths and broken links to pages, assets, and anchors.

`tola check` validates the build. After validation, `tola build` publishes the site by replacing `[build].publish-dir` (`public/` by default) with the full set of outputs. This also removes HTML for deleted sources.

Deployment makes the site available to readers by serving the contents of the publish directory through a web server or hosting service.
