#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Overview",
  description: "See how one Typst entry program generates a whole static site.",
  order: 0,
))

#title()

Tola is a static site generator built on #link("https://typst.app/")[Typst]. Unlike the usual pairing of Markdown bodies with a separate template engine, Tola organises the entire site as one Typst program: layout components, page selection, navigation structure, and prose are all written in the same language.

= What a site entry looks like

In Tola, the site entry (by default `site.typ` in the project root) declares which output files to generate. This code defines a home page and an about page directly:

```typst
#let page(body) = html.main(body)

#document("index.html", format: "html", title: "Home")[
  #page[
    = Home

    #link("/about/")[About this site]
  ]
]

#document("about/index.html", format: "html", title: "About this site")[
  #page[
    = About this site

    $ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $
  ]
]
```

The build writes `index.html` and `about/index.html` to the output directory (`public/` by default), served at the routes `/` and `/about/`. Real sites usually move the prose into a `content/` directory and let the entry walk it and `include` each file; #link("/docs/concepts/build-model/")[How a site builds] shows how.

= Native HTML and equation export

Typst exports document elements as semantic HTML directly:

- `= Home` becomes a heading element, `#link(...)` becomes `<a>`, and `#html.main(...)` produces a `<main>` container.
- Display and inline equations export as native MathML, with no front-end script required:

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $

= Built-in link and output checks

Before writing the publish directory, Tola checks output paths and internal references across the whole site. Change `/about/` on the home page to a path that does not exist, such as `/about-us/`, and `tola check` fails right away; two pages that declare the same output path raise a conflict diagnostic as well.

= About the Typst version

Typst's HTML and Bundle exports are still experimental. Each Tola release bundles a fixed Typst version, and `tola --version` reports the one you have.

When you are ready, go to #link("/docs/getting-started/installation/")[Installation] to get Tola, then follow #link("/docs/getting-started/first-site/")[Your first site] through the full flow.
