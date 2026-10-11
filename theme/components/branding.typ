// URLs prepared by the branding hook and published by its output hook.

#import "@tola/address:0.0.0": output-url
#import "@tola/module:0.0.0": get-module
#import "@tola/site:0.0.0": project-path
#import "assets.typ": output-name

#let _manifest = json(project-path("generated/" + get-module().name + "/brand/manifest.json"))
#let _url(key) = {
  let art = _manifest.at(key, default: none)
  if art != none { output-url(output-name("brand/" + art.file)) + "?h=" + art.digest }
}

/// Homepage logo URL, or `none` when the site has no logo.
#let logo-url() = _url("logo")

/// Prepared favicon PNG at 32, 180 or 512 pixels.
#let favicon-png-url(px) = {
  assert(px in (32, 180, 512), message: "favicon-png-url supports 32, 180 or 512 pixels")
  _url("favicon-" + str(px))
}

#let _vector = _url("favicon")
#let _png = favicon-png-url(32)

/// Browser favicon URL, preferring the prepared SVG.
#let favicon-url() = if _vector != none { _vector } else { _png }

#let favicon-links() = {
  if _png == none { return () }
  let links = (html.link(rel: "icon", type: "image/png", sizes: ((32, 32),), href: favicon-png-url(32)),)
  if _vector != none {
    links.push(html.elem("link", attrs: (
      rel: "icon", type: "image/svg+xml", sizes: "any", href: _vector,
    )))
  }
  links.push(html.elem("link", attrs: (
    rel: "apple-touch-icon", sizes: "180x180", href: favicon-png-url(180),
  )))
  links
}
