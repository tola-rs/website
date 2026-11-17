#import "@tola/code:0.0.0": code-themes
#import "/components/content/lib.typ": heading-permalink, render-raw
#import "/components/partials/footer.typ": footer
#import "/components/partials/header.typ": header
#import "/components/partials/lib.typ": head, search-popup
#import "/site/seo.typ": head-entries
#import "/settings.typ": options

#let base(page, navigation, translations, body, feed: none) = html.elem(
  "html",
  attrs: (lang: page.locale.tag, "data-page-kind": page.kind),
)[
  #set raw(theme: code-themes.github)
  #show raw: source => render-raw(source, page.locale.messages.code, dark-theme: code-themes.github-dark)
  #show heading: source => heading-permalink(
    source,
    page.locale.messages.heading.permalink,
  )
  #show table: it => html.div(class: "table-scroll", it)
  #head(head-entries(page, translations, feed: feed))
  #html.body[
    #header(page, navigation, translations)
    #body
    #footer(page.locale.messages.footer)
    #if options.typescript and options.search { search-popup(page.locale.messages.search) }
  ]
]

#let page-layout(variant, body) = html.div(class: "page-layout layout-" + variant, body)

/// `article: true` marks the body used in RSS.
#let main(body, home: false, wide: false, before: none, after: none, article: false) = {
  let width-classes = if home or wide { "max-w-none" } else { "max-w-reading" }
  let body-class = if home { "home-content" } else { "prose prose-page" }
  let body-tag = if article { "article" } else { "div" }
  let body-attrs = if article { (id: "page-content") } else { (:) }
  body-attrs.insert("class", body-class)
  if not home {
    body-attrs.insert("data-pagefind-body", "")
  }

  html.main(
    id: "content",
    tabindex: -1,
    class: "min-w-0 w-full mx-auto " + width-classes,
  )[
    #before
    #html.elem(body-tag, attrs: body-attrs)[#body]
    #after
  ]
}

#let page(page, navigation, translations, body, feed: none) = {
  let landing = page.meta.layout == "landing"
  let wide = page.meta.layout == "wide"
  base(page, navigation, translations, feed: feed)[
    #page-layout(if landing { "home" } else if wide { "wide" } else { "page" })[
      #main(home: landing, wide: wide)[#body]
    ]
  ]
}
