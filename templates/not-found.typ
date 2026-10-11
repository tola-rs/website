// Missing-page document with links to published homepages.

#import "@tola/address:0.0.0": output-url
#import "/components/partials/lib.typ": head

#let home-link(page) = html.li(html.a(href: output-url(page.output), lang: page.locale.tag, page.locale.name))

/// Missing-page document.
#let not-found(homes, entries, locale) = html.html(lang: locale.tag)[
  #head(entries, interactive: false)
  #html.body[
    #html.elem("main", attrs: (class: "page-layout prose max-w-reading", "data-pagefind-ignore": "all"))[
      #title()
      #locale.messages.not-found.description
      #html.ul[
        #for page in homes { home-link(page) }
      ]
    ]
  ]
]
