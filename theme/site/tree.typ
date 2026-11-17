// Ordered tree mechanics: children order, reading order, trails, and neighbors.

#import "@tola/collection:0.0.0": group-by, index-by

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

/// Build a tree; reading-order lists real pages depth-first.
#let build(nodes, root, sort-key: node => node.key) = {
  let by-key = index-by(nodes, key: node => node.key)
  let by-parent = group-by(nodes.filter(node => node.parent != none), key: node => node.parent)
  let tree = (root: root, nodes: by-key, children: (:))
  for key in by-key.keys() {
    tree.children.insert(key, by-parent.at(key, default: ()).sorted(key: sort-key))
  }
  let reading-order = if nodes.len() == 0 { () } else { subtree(tree, root) }
  let positions = (:)
  for (position, page) in reading-order.enumerate() {
    positions.insert(page.key, position)
  }
  (..tree, reading-order: reading-order, positions: positions)
}

/// Root-to-node trail, including the node.
#let trail(tree, key) = {
  let node = tree.nodes.at(key, default: none)
  if node == none { return none }
  let path = (node,)
  while node.parent != none {
    node = tree.nodes.at(node.parent)
    path.push(node)
  }
  path.rev()
}

/// Reading-order neighbors; missing sides are absent.
#let neighbors(tree, key) = {
  let position = tree.positions.at(key, default: none)
  if position == none { return none }
  let order = tree.reading-order
  let result = (:)
  if position > 0 { result.insert("before", order.at(position - 1)) }
  if position + 1 < order.len() { result.insert("after", order.at(position + 1)) }
  result
}
