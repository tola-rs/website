#import "@tola/collection:0.0.0": index-by
#import "@tola/address:0.0.0": join-route
#import "@tola/source:0.0.0": parse-sources
#import "/schemas/docs.typ": sibling-orders
#import "/site/tree.typ": build, subtree
#import "../settings.typ": docs-groups, docs-section

#let _docs-root = join-route((docs-section,))
#let _fixed-groups = docs-groups.map(group => _docs-root + group + "/")

#let _node-title(segments, target, locale) = {
  if target != none { return target.meta.title }
  if segments.len() == 1 { return locale.messages.navigation.docs }
  let slug = segments.last()
  let first = slug.clusters().first()
  let fallback = upper(first) + slug.slice(first.len()).replace("-", " ")
  if segments.len() == 2 { return locale.messages.docs.groups.at(slug, default: fallback) }
  fallback
}

// Keep groups in the sidebar even when they have no landing page.
#let _docs-nodes(documentation-pages, locale) = {
  let by-key = index-by(documentation-pages, key: page => page.key)
  let nodes = (:)
  for page in documentation-pages {
    for length in range(1, page.segments.len() + 1) {
      let segments = page.segments.slice(0, length)
      let key = join-route(segments)
      if key in nodes { continue }
      let target = by-key.at(key, default: none)
      let parent = if length == 1 { none } else { join-route(segments.slice(0, -1)) }
      nodes.insert(key, (
        key: key,
        page: target,
        title: _node-title(segments, target, locale),
        parent: parent,
      ))
    }
  }
  nodes.values()
}

#let _group-rank(key) = {
  let rank = _fixed-groups.position(group => group == key)
  if rank == none { _fixed-groups.len() } else { rank }
}

/// Build one language's documentation tree and validate its sibling orders.
#let tree(pages, locale) = {
  let documentation-pages = pages.filter(page => page.kind == "doc")
  let nodes = _docs-nodes(documentation-pages, locale)
  let docs = build(nodes, _docs-root, sort-key: node => {
    let order = if node.page != none { node.page.meta.order }
    (_group-rank(node.key), if order == none { 1 } else { 0 }, if order == none { 0 } else { order }, node.key)
  })
  let order-schema = sibling-orders(docs.children, fixed: _fixed-groups)
  let _ = parse-sources(documentation-pages, order-schema)
  let sections = docs
    .children
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
