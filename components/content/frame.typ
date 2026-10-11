// Frame layout content as a published SVG on HTML; inline on paged targets.

#import "@tola/address:0.0.0": output-url
#import "@tola/hash:0.0.0": blake3, bytes-to-hex

#let _frame-output(id) = "assets/frames/" + id + ".svg"

#let _frame-id(body) = bytes-to-hex(blake3(bytes(repr(body)))).slice(0, 8)

/// Frame `body` as an SVG image on HTML.
#let svg-frame(body, alt: "") = context {
  if target() == "html" {
    let id = _frame-id(body)
    [#metadata((id: id, body: body)) <tola-frame>]
    html.div(class: "svg-frame")[
      #html.img(src: output-url(_frame-output(id)), alt: alt, loading: "lazy")
    ]
  } else {
    align(center, body)
  }
}

/// Write each recorded frame as an SVG at bundle top level.
#let publish-frames() = context {
  let seen = ()
  for item in query(<tola-frame>) {
    let v = item.value
    if v.id in seen { continue }
    seen.push(v.id)
    document(_frame-output(v.id), format: "svg")[
      #set page(width: auto, height: auto, margin: 0pt, fill: none)
      #v.body
    ]
  }
}
