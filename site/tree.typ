// Ordered tree mechanics: children order, reading order, trails, and neighbors.

#import "@tola/collection:0.0.0": adjacent, group-by, index-by, lineage

/// Build a tree; reading-order lists real pages depth-first.
#let build(nodes, root, sort-key: node => node.key) = {
  let by-key = index-by(nodes, key: node => node.key)
  let by-parent = group-by(nodes.filter(node => node.parent != none), key: node => node.parent)
  let children = (:)
  for node in nodes {
    children.insert(node.key, by-parent.at(node.key, default: ()).sorted(key: sort-key))
  }
  let visit(key) = {
    let node = by-key.at(key)
    let found = if node.page != none { (node.page,) } else { () }
    for child in children.at(key, default: ()) { found += visit(child.key) }
    found
  }
  (root: root, nodes: by-key, children: children, reading-order: visit(root))
}

/// Real pages below `key`, including itself.
#let subtree(tree, key) = {
  let found = ()
  let node = tree.nodes.at(key)
  if node.page != none { found.push(node.page) }
  for child in tree.children.at(key, default: ()) {
    found += subtree(tree, child.key)
  }
  found
}

/// Root-to-node trail, including the node.
#let trail(tree, key) = {
  let parent(key) = tree.nodes.at(key).parent
  lineage(tree.nodes.values(), key, parent, key: node => node.key)
}

/// Reading-order neighbors; missing sides are absent.
#let neighbors(tree, key) = adjacent(tree.reading-order, key, key: page => page.key)
