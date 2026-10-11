// Site header: skip link, navigation, search, language, theme, and repository.

#import "@tola/address:0.0.0": output-url
#import "@tola/site:0.0.0": site
#import "../../settings.typ": options, repository
#import "../icon.typ": repository-icon
#import "search.typ": search-button
#import "language-menu.typ": language-menu
#import "theme.typ": theme-button

// Navigation link with a page or section marker.
#let _navigation-link(page, target, active, text) = {
  if target == none { return }
  let attrs = (href: output-url(target.output))
  if target.key == page.key { attrs.insert("aria-current", "page") } else if active {
    attrs.insert("aria-current", "location")
  }
  html.a(..attrs, text)
}

#let _repository-link(label) = {
  if repository == none { return }
  html.a(
    class: "ui-control icon-control",
    href: repository,
    rel: "noreferrer",
    aria-label: label,
    title: label,
  )[
    #repository-icon(repository, class: "brand-mark")
  ]
}

/// Site header.
#let header(page, navigation, translations) = {
  let messages = page.locale.messages
  let brand-target = if navigation.home == none { navigation.documentation } else { navigation.home }
  html.a(href: "#content", class: "skip-link", messages.navigation.skip)
  html.elem("header", attrs: (class: "site-header", "data-pagefind-ignore": ""))[
    #html.div(class: "header-inner")[
      #if brand-target != none { html.a(href: output-url(brand-target.output), class: "brand", site.title) }
      #if options.typescript and options.search {
        html.div(class: "header-search", search-button(messages.search))
      }
      #html.div(class: "header-end contents sm:flex sm:items-center sm:gap-3 sm:ml-auto")[
        #html.elem("nav", attrs: (
          "aria-label": messages.navigation.label,
          class: "main-nav flex items-center gap-1",
        ))[
          #_navigation-link(page, navigation.documentation, page.kind == "doc", messages.navigation.docs)
          #for target in navigation.pages {
            _navigation-link(page, target, false, target.meta.title)
          }
          #_navigation-link(page, navigation.blog-index, page.kind == "post", messages.navigation.blog)
        ]
        #html.elem("div", attrs: (
          class: "toolbar flex shrink-0 items-center gap-1",
        ))[
          #html.span(class: "header-divider hidden sm:block", aria-hidden: true)
          #html.elem("div", attrs: (
            class: "header-controls flex items-center gap-0",
          ))[
            #language-menu(page, translations)
            #if options.typescript { theme-button(messages.appearance) }
          ]
          #html.span(class: "header-divider", aria-hidden: true)
          #html.div(class: "header-social")[#_repository-link(messages.repository)]
        ]
      ]
    ]
  ]
}
