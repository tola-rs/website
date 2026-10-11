// Footer credits and versions.

#import "../icon.typ": icon
#import "/site/info.typ": copyright, site-repository, version

#let _copyright-line(messages) = html.p(class: "footer-copyright")[
  #icon("copyright")#html.span[
    #copyright.years — #link(copyright.url, copyright.holder) #messages.contributors-join #link(copyright.contributors, messages.contributors)
  ]
]

/// Footer credits, tool versions, and repository link.
#let footer(messages) = html.elem("footer", attrs: (
  class: "site-footer",
  "data-pagefind-ignore": "",
))[
  #html.div(class: "footer-inner")[
    #html.p(class: "footer-source")[
      #link(site-repository)[
        #icon("github", collection: "simple-icons", class: "footer-icon")
        #messages.source
      ]
    ]
    #html.p(class: "footer-versions")[
      #icon("book-open", class: "footer-icon")
      #messages.versions Tola #version.tola · Typst #version.typst
    ]
    #_copyright-line(messages)
  ]
]
