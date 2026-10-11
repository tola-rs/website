// Raw fences: code by default; handlers dispatch other languages.

#import "@tola/code:0.0.0": render-code
#import "../icon.typ": icon
#import "diagram.typ": mermaid-block

// Fence languages rendered by another component.
#let handlers = (
  "mermaid": mermaid-block,
)

// Line selections: "3", "5-7", or "3,5-7".
#let _parse-lines(spec) = {
  let lines = ()
  for part in spec.split(",") {
    let bounds = part.trim().split("-")
    let start = int(bounds.first())
    let end = if bounds.len() > 1 { int(bounds.at(1)) } else { start }
    lines += range(start, end + 1)
  }
  lines
}


// Apply hl/add/del classes; CSS draws the diff markers.
#let _decorate(body, hl: (), add: (), del: ()) = {
  show raw.line: line => {
    let classes = "line"
    if line.number in hl { classes += " hl" }
    if line.number in add { classes += " diff-add" }
    if line.number in del { classes += " diff-del" }
    html.span(class: classes, line.body)
  }
  body
}

// Options for the next block code.
#let _pending = state("code-lines", none)

/// Set options for the next code block: `hl:2,4-5`, `add:4-6`, `del:3`.
#let code-lines(options) = _pending.update(options)

/// Clear pending options at document start.
#let reset-code-lines() = _pending.update(none)

// Parse "hl:2,4-5" tokens.
#let _parse-options(options) = {
  let hl = ()
  let add = ()
  let del = ()
  for token in options.split(regex("\s+")) {
    if token == "" { continue }
    let parts = token.split(":")
    if parts.len() < 2 { panic("code option needs a value: " + token) }
    let lines = _parse-lines(parts.slice(1).join(":"))
    if parts.first() == "hl" { hl = lines }
    else if parts.first() == "add" { add = lines }
    else if parts.first() == "del" { del = lines }
    else { panic("unknown code option: " + token) }
  }
  (hl: hl, add: add, del: del)
}

#let _code-block(source, messages, dark-theme: none) = {
  let rendered = render-code(source, dark-theme: dark-theme, attrs: if source.block {
    ("data-code-label": messages.label)
  } else { (:) })
  if not source.block { return rendered }
  html.div(class: "code-block")[
    // html.elem keeps these controls as direct children, without an implicit paragraph.
    #html.elem("div", attrs: (class: "code-toolbar"), {
      html.span(class: "code-language", source.lang)
      html.elem(
        "button",
        attrs: (
          type: "button",
          class: "code-copy",
          hidden: "",
          "data-copy-code": "",
          "aria-label": messages.copy,
          title: messages.copy,
          "data-copy-label": messages.copy,
          "data-copied-label": messages.copied,
          "data-copy-error": messages.error,
        ),
        {
          icon("clipboard", class: "copy-icon")
          icon("check", class: "copied-icon")
        },
      )
      html.elem("span", attrs: (
        class: "sr-only",
        "data-copy-status": "",
        role: "status",
        "aria-live": "polite",
        "aria-atomic": "true",
      ))
    })
    #rendered
  ]
}

/// Render a raw fence, dispatching to `handlers`.
/// Fence info strings accept only `[A-Za-z0-9_-]`; options are function arguments.
#let render-raw(source, messages, dark-theme: none) = {
  if not source.block {
    let handler = if source.lang != none { handlers.at(source.lang, default: none) } else { none }
    if handler != none { return handler(source) }
    return _code-block(source, messages, dark-theme: dark-theme)
  }
  let handler = if source.lang != none { handlers.at(source.lang, default: none) } else { none }
  if handler != none { return handler(source) }
  context {
    let options = _pending.get()
    if options != none { _pending.update(none) }
    let block = _code-block(source, messages, dark-theme: dark-theme)
    if options == none { block } else {
      let parsed = _parse-options(options)
      _decorate(block, hl: parsed.hl, add: parsed.add, del: parsed.del)
    }
  }
}
