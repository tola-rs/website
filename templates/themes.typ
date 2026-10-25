// Themes gallery template: a wide, screenshot-led page.

#import "base.typ": base
#import "/components/assets.typ": script-url

/// Themes gallery page.
#let themes-page(page, navigation, translations, body, feed: none) = base(
  page,
  navigation,
  translations,
  feed: feed,
)[
  #html.elem("main", attrs: (
    id: "content",
    tabindex: "-1",
    class: "mx-auto w-full max-w-site px-5 py-12 sm:px-8",
    "data-pagefind-body": "",
  ))[
    #html.div(class: "mx-auto max-w-page")[#body]
  ]
  #html.script("", src: script-url("themes"), defer: true)
]
