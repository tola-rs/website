// Resolve authored logical links and attach previews to exported body links.

#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": output-url, route-url
#import "@tola/document:0.0.0": plain-text

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
#let localize-link(element, targets-by-key, translations-by-key, pages-by-url) = {
  let key = _page-key(element.dest)
  if key == none or key not in translations-by-key { return element }
  // A published mounted URL wins over a logical key.
  if site.base-path != "/" {
    let mounted-url = route-url(element.dest, base-path: "/")
    if mounted-url in pages-by-url { return element }
  }
  let target = targets-by-key.at(key, default: none)
  if target == none {
    let translations = translations-by-key.at(key)
    target = translations.find(page => page.locale.tag == site.language.tag)
    if target == none { target = translations.first() }
  }
  link(target.label, element.body)
}

// Resolve an exported href against the mounted page URL. Bundle links can use
// relative index.html paths even when the public page URL ends with a slash.
#let _linked-path(href, page) = {
  let path = href.trim().split(regex("[?#]")).first()
  if path == "" { return output-url(page.output) }
  if path.starts-with("//") and site.origin != none {
    path = site.origin.split(":").first() + ":" + path
  }
  if site.origin != none {
    if path == site.origin { path = "/" }
    else if path.starts-with(site.origin + "/") { path = path.slice(site.origin.len()) }
  }
  if path.starts-with("//") or path.contains(regex("^[a-zA-Z][a-zA-Z0-9+.-]*:")) {
    return none
  }
  if not path.starts-with("/") {
    let directory = output-url(page.output).split("/").slice(0, -1).join("/")
    path = directory + "/" + path
  }
  if path.ends-with("/.") or path.ends-with("/..") { path += "/" }
  let segments = ()
  for segment in path.split("/").slice(1) {
    if segment == ".." {
      if segments.len() > 0 { let _ = segments.pop() }
    } else if segment != "." {
      segments.push(segment)
    }
  }
  path = "/" + segments.join("/")
  if path.ends-with("/index.html") { path = path.slice(0, -"index.html".len()) }
  path
}

#let _preview-signature(signature) = html.span(class: "link-preview-signature", {
  let token(value) = html.elem("span", attrs: ("data-code-text": value))
  show text: element => token(element.text)
  show linebreak: _ => token("\n")
  raw(signature, lang: "typc", block: false)
})

/// Preview cross-page links and fragments that explicitly allow same-page previews.
#let preview-link(element, page, pages-by-url) = {
  if "data-link-preview" in element.attrs { return element }
  if element.attrs.at("class", default: none) == "heading-anchor" { return element }
  let href = element.attrs.at("href", default: none)
  if type(href) != str { return element }
  let path = _linked-path(href, page)
  if path == none { return element }
  let target = pages-by-url.at(path, default: none)
  if target == none and not path.ends-with("/") {
    target = pages-by-url.at(path + "/", default: none)
  }
  if target == none { return element }
  let fragment = href.split("#").at(1, default: "")
  let preview = if fragment != "" { target.meta.link-previews.at(fragment, default: none) }
  if target.output == page.output and (preview == none or not preview.same-page) { return element }

  let title = if preview == none { plain-text(target.meta.title) } else { preview.title }
  let description = if preview != none { preview.description }
  else if target.meta.description == none { "" }
  else { plain-text(target.meta.description) }
  let signature = if preview == none { "" } else { preview.signature }
  let accessible-description = (signature.replace(regex("\\s+"), " ") + " " + description).trim()
  let attrs = (: ..element.attrs, "data-link-preview": "")
  if accessible-description != "" and "aria-description" not in attrs and "aria-describedby" not in attrs {
    attrs.insert("aria-description", accessible-description)
  }
  // CSS reads the card text from attributes so it stays out of article and feed text.
  let card = html.elem("span", attrs: (
    class: "link-preview-card",
    lang: target.locale.tag,
    "aria-hidden": "true",
    "data-title": title,
    "data-description": description,
  ), {
    if signature != "" {
      _preview-signature(signature)
    }
    html.elem("span", attrs: (class: "link-preview-tip", "aria-hidden": "true"))
  })
  let connector = html.elem("span", attrs: (class: "link-preview-connector", "aria-hidden": "true"))
  html.elem("a", attrs: attrs, element.body + card + connector)
}
