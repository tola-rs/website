// Language disclosure for published pages in each language.

#import "@tola/address:0.0.0": join-route, output-url
#import "../icon.typ": ui-icon
#import "../../site/locales/lib.typ": locales
#import "../../site/pages.typ": pages-by-language-and-key

#let _language-option(page, target) = {
  let current = target.locale.tag == page.locale.tag
  let attrs = (
    class: "language-option",
    href: output-url(target.output),
    lang: target.locale.tag,
    hreflang: target.locale.tag,
  )
  if current { attrs.insert("aria-current", true) }
  html.a(..attrs)[
    #html.span(target.locale.name)
    #if current { ui-icon("check") }
  ]
}

/// Link to the translation when published, then to the nearest published parent.
#let language-menu(page, translations) = {
  let targets = locales.keys().map(tag => {
    let translated = translations.find(target => target.locale.tag == tag)
    if translated != none { return translated }
    let targets-by-key = pages-by-language-and-key.at(tag, default: (:))
    for depth in range(page.segments.len() - 1, -1, step: -1) {
      let key = join-route(page.segments.slice(0, depth))
      let parent = targets-by-key.at(key, default: none)
      if parent != none { return parent }
    }
  }).filter(target => target != none)
  if targets.len() < 2 { return }
  let label = page.locale.messages.languages
  let name = label + ": " + page.locale.name
  html.elem("details", attrs: (
    class: "header-menu",
    name: "header-menu",
    "data-header-menu": "",
    "data-hover-menu": "",
  ))[
    #html.summary(class: "ui-control header-menu-trigger", aria-label: name)[
      #ui-icon("languages")
      #ui-icon("chevron-down", class: "menu-chevron")
    ]
    #html.nav(class: "header-panel language-panel", aria-label: label)[
      #for target in targets {
        _language-option(page, target)
      }
    ]
  ]
}
