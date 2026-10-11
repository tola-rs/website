// A visible note with an optional title.

/// Note with an optional title.
#let callout(body, title: none) = html.aside(class: "callout")[
  #if title != none { html.strong(title) }
  #body
]
