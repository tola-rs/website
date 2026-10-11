// Documentation trees, reading order, and index sections.

#import "@tola/collection:0.0.0": index-by
#import "@tola/address:0.0.0": join-route
#import "@tola/source:0.0.0": parse-sources
#import "/schemas/docs.typ": sibling-orders
#import "/site/tree.typ": build, neighbors, subtree, trail
#import "pages.typ": pages-by-language
#import "locales/lib.typ": locales

#let _docs-root = "/docs/"
#let _group-order = ("getting-started", "concepts", "guide", "reference")
#let _fixed-groups = _group-order.map(group => _docs-root + group + "/")

// Real page title, or a localized label for a virtual group.
#let _node-title(segments, target, locale) = {
  if target != none { return target.meta.title }
  if segments.len() == 1 { return locale.messages.navigation.docs }
  if segments.len() == 2 { return locale.messages.docs.groups.at(segments.last(), default: segments.last()) }
  segments.last()
}

// Flat nodes: every prefix path becomes a node; missing pages are virtual groups.
#let _docs-nodes(documentation-pages, locale) = {
  let by-key = index-by(documentation-pages, key: page => page.key)
  let nodes = ()
  let seen = (:)
  for page in documentation-pages {
    for length in range(1, page.segments.len() + 1) {
      let segments = page.segments.slice(0, length)
      let key = join-route(segments)
      if key not in seen {
        seen.insert(key, true)
        let target = by-key.at(key, default: none)
        let parent = if length == 1 { none } else { join-route(segments.slice(0, -1)) }
        nodes.push((
          key: key,
          page: target,
          title: _node-title(segments, target, locale),
          parent: parent,
        ))
      }
    }
  }
  nodes
}

// Known groups first, unnamed groups last.
#let _group-rank(key) = {
  let rank = _group-order.position(group => key == _docs-root + group + "/")
  if rank == none { _group-order.len() } else { rank }
}

// Editorial order for real pages; virtual groups sort as zero.
#let _page-order(node) = if node.page == none { 0 } else { node.page.meta.order }

// Tree with one section per root group.
#let _docs-tree(documentation-pages, locale) = {
  let nodes = _docs-nodes(documentation-pages, locale)
  let docs = build(nodes, _docs-root, sort-key: node => (
    _group-rank(node.key),
    _page-order(node),
    node.key,
  ))
  let sections = docs.children
    .at(_docs-root, default: ())
    .map(group => (title: group.title, pages: subtree(docs, group.key)))
  let root = docs.nodes.at(_docs-root, default: none)
  if root != none and root.page != none {
    sections = ((title: root.title, pages: (root.page,)),) + sections
  }
  (
    ..docs,
    sections: sections.filter(section => section.pages.len() > 0),
  )
}

// Drop one page from prepared sections.
#let _index-sections(tree, omit: none) = {
  let sections = tree.sections.map(section => {
    let pages = section.pages.filter(page => page.key != omit)
    (..section, pages: pages)
  })
  sections.filter(section => section.pages.len() > 0)
}

/// Breadcrumb trail and reading-order neighbors.
#let page-navigation(tree, key) = (
  trail: trail(tree, key),
  neighbors: neighbors(tree, key),
)

#let _trees-by-language = {
  let trees = (:)
  for (tag, locale) in locales {
    let documentation-pages = pages-by-language.at(tag, default: ()).filter(page => page.kind == "doc")
    let tree = _docs-tree(documentation-pages, locale)
    let order-schema = sibling-orders(tree.children, fixed: _fixed-groups)
    let _ = parse-sources(documentation-pages, order-schema)
    trees.insert(tag, tree)
  }
  trees
}

/// Prepared tree for one language.
#let tree(language) = _trees-by-language.at(language)

/// Index sections, optionally omitting a page key.
#let sections(language, omit: none) = _index-sections(tree(language), omit: omit)
