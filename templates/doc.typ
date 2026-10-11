// Documentation page template.

#import "base.typ": base, main, page-layout
#import "/components/partials/lib.typ": page-neighbors, sidebar, toc
#import "/site/docs.typ": page-navigation
#import "@tola/web:0.0.0": plain-text

/// Documentation page with sidebar and reading neighbors.
#let doc(page, navigation, translations, tree, body, feed: none) = {
  let messages = page.locale.messages
  let position = page-navigation(tree, page.key)
  // The docs root is a landing entry, not a content ancestor; keep it out of
  // the search trail.
  let trail = position.trail.filter(node => node.key != tree.root)
  let search-breadcrumb = if trail.len() < 2 { "" } else { trail.slice(0, -1).map(node => plain-text(node.title)).join(" › ") }
  base(page, navigation, translations, feed: feed)[
    #page-layout("docs")[
      #sidebar(tree, page.key, messages.docs.navigation)
      #toc(messages.on-this-page)
      #main(
        before: [
          // Pagefind metadata sits outside the indexed body.
          #if trail.len() > 1 {
            html.elem("span", attrs: (
              hidden: "",
              "data-pagefind-ignore": "",
              "data-pagefind-meta": "breadcrumb[data-search-breadcrumb]",
              "data-search-breadcrumb": search-breadcrumb,
            ))
          }
        ],
        after: if page.meta.neighbors { page-neighbors(position.neighbors, messages.docs) },
      )[#body]
    ]
  ]
}
