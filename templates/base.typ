// HTML shell and complete single-column page.

#import "@tola/code:0.0.0": code-themes
#import "/components/content/lib.typ": heading-permalink, math-svg, render-raw
#import "/components/partials/lib.typ": footer, head, header, search-popup
#import "/site/seo.typ": head-entries

/// Shared HTML shell.
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
  #show math.equation: math-svg
  #show table: it => html.div(class: "table-scroll", it)
  #head(head-entries(page, translations, feed: feed))
  #html.body[
    #header(page, navigation, translations)
    #body
    #footer(page.locale.messages.footer)
    #search-popup(page.locale.messages.search)
  ]
]

/// Page-layout wrapper; `variant` is `home`, `page`, `docs`, or `blog`.
#let page-layout(variant, body) = html.div(class: "page-layout layout-" + variant, body)

/// Main content container; `article: true` marks the RSS article.
#let main(body, home: false, before: none, after: none, article: false) = {
  let width-classes = if home { "max-w-none" } else { "max-w-reading" }
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

/// Complete single-column page.
#let page(page, navigation, translations, body, feed: none) = base(page, navigation, translations, feed: feed)[
  #page-layout(if page.kind == "home" { "home" } else { "page" })[
    #main(home: page.kind == "home")[#body]
  ]
]
