// Mermaid fences publish one SVG per unique diagram.

#import "@tola/address:0.0.0": output-url
#import "/site/colors.typ": shared-ink
#import "@tola/hash:0.0.0": blake3, bytes-to-hex
#import "@preview/merman:0.5.0": mermaid-svg

// Transparent boxes; one ink that reads on both themes.
#let _diagram-font = "system-ui, -apple-system, PingFang SC, Microsoft YaHei, sans-serif"
#let _diagram-ink = shared-ink
// Mermaid lacks a font-weight theme variable.
#let _diagram-weight = "700"
#let _diagram-size = "14px"

#let _diagram-config = (
  theme: "base",
  look: "classic",
  // Keep intrinsic width; CSS scrolls wide diagrams instead of shrinking them.
  flowchart: (useMaxWidth: false),
  themeVariables: (
    primaryColor: "transparent",
    primaryBorderColor: _diagram-ink,
    primaryTextColor: _diagram-ink,
    lineColor: _diagram-ink,
    titleColor: _diagram-ink,
    background: "transparent",
    fontFamily: _diagram-font,
    fontSize: _diagram-size,
  ),
)

// Content-derived id; changing source, config, or weight changes the URL.
#let _diagram-id(source) = {
  let descriptor = (source: source, config: _diagram-config, weight: _diagram-weight)
  bytes-to-hex(blake3(bytes(repr(descriptor)))).slice(0, 8)
}

// Accessible name from Mermaid's accTitle/accDescr.
#let _diagram-parts(source) = {
  let title = ""
  let description = ""
  for line in source.split("\n") {
    let trimmed = line.trim()
    if trimmed.starts-with("accTitle:") { title = trimmed.slice("accTitle:".len()).trim() }
    if trimmed.starts-with("accDescr:") { description = trimmed.slice("accDescr:".len()).trim() }
  }
  let alt = if title == "" { description } else if description == "" { title } else { title + "：" + description }
  (alt: alt)
}

#let _diagram-output(id) = "assets/diagrams/" + id + ".svg"

/// Fence handler for `mermaid` blocks.
#let mermaid-block(source) = {
  let parts = _diagram-parts(source.text)
  let id = _diagram-id(source.text)
  html.div(class: "mermaid-diagram")[
    #metadata((id: id, source: source.text)) <tola-diagram>
    #html.img(src: output-url(_diagram-output(id)), alt: parts.alt, loading: "lazy")
  ]
}

/// Publish each recorded diagram as an SVG at bundle top level.
#let publish-diagrams() = context {
  let seen = (:)
  for item in query(<tola-diagram>) {
    let v = item.value
    if seen.at(v.id, default: false) { continue }
    seen.insert(v.id, true)
    // `scoped-css` sets the font weight.
    asset(_diagram-output(v.id), mermaid-svg(
      v.source,
      site-config: _diagram-config,
      scoped-css: "text{font-weight:" + _diagram-weight + "}",
    ))
  }
}
