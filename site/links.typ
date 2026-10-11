// Resolve authored logical links to the current language's page label.

#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": route-url

// Directory-like key: `/docs/intro` becomes `/docs/intro/`.
// URL syntax and native targets return none.
#let _page-key(destination) = {
  if type(destination) != str or not destination.starts-with("/") or destination.starts-with("//") {
    return none
  }
  if destination.contains(regex("[%?#]")) { return none }
  // A filename stays a URL.
  if not destination.ends-with("/") and destination.split("/").last().contains(".") { return none }
  if destination.ends-with("/") { destination } else { destination + "/" }
}

/// Resolve a body link to the current language's target.
#let localize-link(element, targets-by-key, published-keys, published-urls) = {
  let key = _page-key(element.dest)
  if key == none or key not in published-keys { return element }
  // A published mounted URL wins over a logical key.
  if site.base-path != "/" {
    let mounted-url = route-url(element.dest, base-path: "/")
    if mounted-url in published-urls { return element }
  }
  link(targets-by-key.at(key).label, element.body)
}
