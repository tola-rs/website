// Usage:
//   #import "/components/equation.typ": math-svg
//   #show math.equation: math-svg
#let math-svg(equation, alt: auto) = context {
  if target() != "html" { return equation }
  let block = equation.at("block", default: math.equation.block)
  let alternative = if alt == auto { equation.at("alt", default: math.equation.alt) } else { alt }
  let attributes = (
    class: if block { "tola-math-block" } else { "tola-math-inline" },
    role: "math",
  )
  if alternative != none { attributes.insert("aria-label", alternative) }
  if block {
    html.elem("div", attrs: attributes, html.frame(equation))
  } else {
    html.elem("span", attrs: attributes, box(html.frame(equation)))
  }
}
