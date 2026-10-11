#import "base.typ": base, main, page-layout
#import "/components/partials/lib.typ": page-neighbors, sidebar, toc
#import "/site/tree.typ": neighbors, trail
#import "@tola/document:0.0.0": plain-text

// Pagefind reads the ancestors between the docs landing page and the current page.
#let _search-breadcrumb(tree, key) = {
  let path = trail(tree, key)
  if path.len() < 3 { return }
  html.elem("span", attrs: (
    hidden: "",
    "data-pagefind-ignore": "",
    "data-pagefind-meta": "breadcrumb[data-search-breadcrumb]",
    "data-search-breadcrumb": path.slice(1, -1).map(node => plain-text(node.title)).join(" › "),
  ))
}

#let doc(page, navigation, translations, tree, body, feed: none) = {
  let messages = page.locale.messages
  base(page, navigation, translations, feed: feed)[
    #page-layout("docs")[
      #html.div(class: "docs-sidebar-column")[
        #sidebar(tree, page.key, messages.docs)
      ]
      #toc(messages.on-this-page)
      #main(
        wide: true,
        before: _search-breadcrumb(tree, page.key),
        after: if page.meta.neighbors { page-neighbors(neighbors(tree, page.key), messages.docs) },
      )[#body]
    ]
  ]
}
