// Site header: skip link, navigation, search, language, theme, and repository.

#import "@tola/address:0.0.0": output-url
#import "/site/info.typ": repository
#import "../icon.typ": icon
#import "search.typ": search-button
#import "language-menu.typ": language-menu
#import "theme.typ": theme-button

// Navigation link with a page or section marker.
#let _navigation-link(page, target, section, text) = {
  if target == none { return }
  let attrs = (href: output-url(target.output))
  if target.key == page.key { attrs.insert("aria-current", "page") } else if (
    page.segments.at(0, default: none) == section
  ) { attrs.insert("aria-current", "location") }
  html.a(..attrs, text)
}

#let _repository-link(label) = html.a(
  class: "ui-control icon-control",
  href: repository,
  rel: "noreferrer",
  aria-label: label,
  title: label,
)[
  #icon("github", collection: "simple-icons", class: "brand-mark")
]

/// Site header.
#let header(page, navigation, translations) = {
  let messages = page.locale.messages
  html.a(href: "#content", class: "skip-link", messages.navigation.skip)
  html.elem("header", attrs: (class: "site-header", "data-pagefind-ignore": ""))[
    #html.div(class: "header-inner")[
      #if navigation.home != none { html.a(href: output-url(navigation.home.output), class: "brand")[Tola] }
      #html.div(class: "header-search")[#search-button(messages.search)]
      #html.div(class: "header-end contents sm:flex sm:items-center sm:gap-3 sm:ml-auto")[
        #html.elem("nav", attrs: (
          "aria-label": messages.navigation.label,
          class: "main-nav",
          "un-flex": "~ items-center",
          "un-gap": "1",
        ))[
          #for (target, section, text) in (
            (navigation.documentation, "docs", messages.navigation.docs),
            (navigation.blog-index, "blog", messages.navigation.blog),
          ) {
            _navigation-link(page, target, section, text)
          }
        ]
        #html.elem("div", attrs: (
          class: "toolbar",
          "un-flex": "~ shrink-0 items-center",
          "un-gap": "1",
        ))[
          #html.span(class: "header-divider hidden sm:block", aria-hidden: true)
          #html.elem("div", attrs: (
            class: "header-controls",
            "un-flex": "~ items-center",
            "un-gap": "0",
          ))[
            #language-menu(page.locale, translations)
            #theme-button(messages.appearance)
          ]
          #html.span(class: "header-divider", aria-hidden: true)
          #html.div(class: "header-social")[#_repository-link(messages.repository)]
        ]
      ]
    ]
  ]
}
