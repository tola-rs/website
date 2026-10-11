// Documentation sidebar and reading neighbors.

#import "@tola/address:0.0.0": output-url
#import "../icon.typ": icon
#import "../assets.typ": inline-script

#let _node-link(current-key, node, class: none) = {
  let attrs = (href: output-url(node.page.output))
  if class != none { attrs.insert("class", class) }
  if node.key == current-key { attrs.insert("aria-current", "page") }
  html.a(..attrs, node.title)
}

/// Documentation sidebar; virtual groups without a page render as labels.
#let sidebar(tree, current-key, label) = {
  let root = tree.nodes.at(tree.root)
  let groups = tree.children.at(tree.root)
  // Recursive branch.
  let branch(node, group: false) = {
    let children = tree.children.at(node.key)
    if children.len() == 0 {
      let leaf = if node.page != none {
        _node-link(current-key, node, class: if group { "nav-group" } else { none })
      } else {
        html.span(class: "nav-group", node.title)
      }
      return html.li(leaf)
    }

    let branch-title = if node.page != none { _node-link(current-key, node) } else { node.title }
    html.li[
      #html.elem("details", attrs: (class: "nav-section", open: "", "data-navigation-group": node.key))[
        #html.summary(class: "nav-group")[
          #branch-title
          #icon("chevron-down")
        ]
        #html.ul(class: "nav-children", children.map(branch).join())
      ]
    ]
  }
  html.elem("aside", attrs: (
    class: "docs-sidebar",
    "data-pagefind-ignore": "",
    "data-navigation-base": output-url("index.html"),
  ))[
    #html.elem("details", attrs: (class: "navigation-panel", "data-navigation-panel": "sidebar"))[
      #html.summary(class: "navigation-toggle")[
        #label
        #icon("chevron-down")
      ]
      #html.nav(aria-label: label)[
        #html.ul[
          // The docs root is the header entry; repeating it here adds a
          // duplicate "Documentation" row above the real groups.
          #groups.map(branch.with(group: true)).join()
        ]
      ]
    ]
    #html.script(inline-script("navigation-init"))
  ]
}

#let _neighbor-link(direction, text, target) = if target == none { none } else {
  let arrow = if direction == "before" { "chevron-left" } else { "chevron-right" }
  html.a(href: output-url(target.output), class: "neighbor " + direction)[
    #icon(arrow)
    #html.span(class: "neighbor-text")[
      #html.span(class: "muted", text)
      #html.strong(target.meta.title)
    ]
  ]
}

/// Previous/next reading links.
#let page-neighbors(neighbors, messages) = {
  if neighbors == none or neighbors.len() == 0 { return }
  html.nav(aria-label: messages.navigation, class: "page-neighbors")[
    #for (direction, text) in (("before", messages.previous), ("after", messages.next)) {
      _neighbor-link(direction, text, neighbors.at(direction, default: none))
    }
  ]
}
