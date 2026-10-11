// Language disclosure for published translations.

#import "@tola/address:0.0.0": output-url
#import "../icon.typ": icon

#let _language-option(locale, target) = {
  let current = target.locale.tag == locale.tag
  let attrs = (
    class: "language-option",
    href: output-url(target.output),
    lang: target.locale.tag,
    hreflang: target.locale.tag,
  )
  if current { attrs.insert("aria-current", true) }
  html.a(..attrs)[#html.span(target.locale.name) #if current { icon("check") }]
}

/// Language menu; renders nothing for fewer than two translations.
#let language-menu(locale, translations) = {
  if translations.len() < 2 { return }
  let label = locale.messages.languages
  let name = label + ": " + locale.name
  html.elem("details", attrs: (class: "header-menu", name: "header-menu", "data-header-menu": "", "data-hover-menu": ""))[
    #html.summary(class: "ui-control header-menu-trigger", aria-label: name)[
      #icon("languages")
      #icon("chevron-down", class: "menu-chevron")
    ]
    #html.nav(class: "header-panel language-panel", aria-label: label)[
      #for target in translations {
        _language-option(locale, target)
      }
    ]
  ]
}
