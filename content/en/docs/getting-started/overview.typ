#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Overview",
  description: "Build a home page and an about page from site.typ.",
  order: 0,
))

#title()

Tola is a static site generator built on #link("https://typst.app/")[Typst].

= Home and about

Run `tola init my-site`. Replace the page loop in `site.typ` with the code below and keep the `404.html` declaration.

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

Run `tola build` to write `public/about/index.html`, then run `tola dev` to open `/about/` locally. To read page bodies from `content/`, see #link("/docs/concepts/build-model/")[How a site builds].

= HTML export

Typst exports `= Home` as a heading element and `link` as an `<a>`. The `page` function wraps the body in `<main>`.

Typst exports the equation as MathML.

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi)/2 $

= Link checks

Change the link on the home page from `/about/` to `/about-us/` and run `tola check` to see how Tola reports a broken link. To move the page, change the output path in its `document` call as well.

= Typst version

Typst's HTML and Bundle exports are experimental. Run `tola --version` to see which version of Typst comes with Tola.

#link("/docs/getting-started/installation/")[Install Tola] · #link("/docs/getting-started/first-site/")[Your first site]
