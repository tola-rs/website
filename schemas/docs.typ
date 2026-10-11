// Unique order values among published siblings.

#import "@tola/collection:0.0.0": group-by
#import "@tola/schema:0.0.0": check, issue

/// Check for duplicate sibling orders; pass to `parse-sources`.
#let sibling-orders(children, fixed: ()) = {
  let conflicts = (:)
  for (parent, nodes) in children {
    let ordered = nodes.filter(node => node.page != none and node.key not in fixed)
    let by-order = group-by(ordered, key: node => str(node.page.meta.order))
    for (order, siblings) in by-order {
      if siblings.len() < 2 { continue }
      let first = siblings.first().page
      let others = siblings.slice(1).map(node => "also used by source `" + node.page.path + "`")
      let message = "duplicate order " + order + " in `" + parent + "` for `" + first.locale.tag + "`"
      conflicts.insert(first.path, (
        issue(
          message,
          path: ("order",),
          notes: (
            ..others,
            "give these sibling pages different order values; gaps are allowed",
          ),
        ),
      ))
    }
  }
  source => check(dictionary, _ => conflicts.at(source.path, default: ()))
}
