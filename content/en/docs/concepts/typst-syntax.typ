#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Typst syntax and HTML",
  description: "Learn the Typst syntax for pages and templates: heading levels, style rules, context, and HTML/MathML export.",
  order: 10,
))

#title()

Typst is neither Markdown nor LaTeX: you write prose directly, use `=` for section headings, `$` for equations, and `#` to enter code mode. For the web, express text, headings, equations, and links as native Typst content, and leave page structure and layout to `html.*` functions and CSS.

= Basic syntax

A Typst file starts in markup mode:

```typst
#title[Research notes]

Put the *conclusion* first and leave _open questions_ for later.

Inline math: $x^2 + y^2$. Put spaces inside the dollar signs for a display equation:

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

= Further reading

- #link("https://typst.app/")[Typst]
- #link("https://tola.build/")[Tola]
```

Common markup at a glance:

- Blank lines separate paragraphs, `*text*` is bold, `_text_` is emphasized, and backticks mark inline code or code blocks.
- `-` starts a bulleted list and `+` starts a numbered list.
- `#` enters code mode from markup and returns to markup when the expression ends; write `#(1 + 2)` to evaluate an expression.

See the #link("https://typst.app/docs/reference/syntax/")[Typst syntax reference] for the full syntax.

== Page titles and heading levels

Under the default export rules, `#title[...]` maps to HTML `<h1>`, `=` maps to `<h2>`, `==` maps to `<h3>`, and so on. Use `#title()` for the page title and start the first body section with `=`. Do not skip levels to change font size: visual size belongs in CSS.

= Content values, functions, and data

== Strings and `content`

`"text"` is a plain string (`str`), used for paths, URLs, and attributes. `[text]` is a content value (`content`) that can hold bold text, equations, links, and other markup; inside code, `[...]` switches back to markup. Component bodies are usually passed in brackets, while HTML written inside a string is escaped and rendered as ordinary text.

```typst
#let name = "Tola"
#let note(body, kind: "note") = html.aside(class: kind, body)

#note(kind: "tip")[Write a note with *#name*.]
```

`kind: "note"` is a named parameter with a default, and the trailing `[...]` supplies the positional `body` argument. The call exports `<aside class="tip">`.

== Arrays and dictionaries

`(a, b)` is an array (a one-item array needs the trailing comma: `(a,)`), and `(title: "Home", draft: false)` is a dictionary. Entries usually keep the page list as an array of dictionaries:

```typst
#let notes = (
  (title: "First note", draft: false),
  (title: "Still writing", draft: true),
)

#{
  let published = notes.filter(note => not note.draft)
  list(..published.map(note => [#note.title]))
}
```

Braces `{...}` open a code block: `let` bindings produce no output and the values of the remaining expressions join together. The example spreads the array into separate `list` arguments with `..`; a `for` loop combines its iterations the same way.

#callout[
  Multi-line `.filter(...)` and `.map(...)` chains must sit inside a `{...}` code block or a `(...)` group. Breaking a chain across lines in markup makes the new line ordinary text. See the #link("https://typst.app/docs/reference/scripting/")[Typst scripting reference].
]

= `import` and `include`

- `import` brings the variables and functions exported by another file into scope.
- `include` inserts the body of another file at the current position.

Each file keeps its own scope, and an imported file does not inherit the caller's local variables, so pass the data it needs as function arguments. Relative paths start beside the current file. A path that starts with `/` resolves from the project root in a site and from the package root in a module package.

```typst
#import "/components/note.typ": note
#note[This text goes to the component.]

#include "/components/intro.typ"
```

= Style rules and `context`

== `set` and `show`

`set` gives later elements default parameters (such as `#set heading(numbering: "1.")`), and `show` intercepts and rewrites matching elements. A `#show: fn` rule without a selector passes the whole remaining body to `fn`, which is how article and page templates wrap content:

```typst
#let article(body) = html.article(class: "note", body)
#show: article
#set heading(numbering: "1.")

= Research notes
== Conclusion
```

To customise a single heading, write `#show heading: it => ...` (`it.body` is the heading text) and keep the native `heading` structure so tables of contents and reference queries keep working. See the #link("https://typst.app/docs/reference/styling/")[Typst styling reference].

== `context` and heading anchors

The same `content` value can end up in different output documents, so `context` defers a query until the content is placed in a document:

```typst
#import "@tola/document:0.0.0": current-document

#context {
  let page = current-document()
  [This document is written to #raw(page.output).]
}

= Research notes <research-notes>

#link(<research-notes>)[Jump to heading]
```

Label a native heading such as `<research-notes>` and `#link(<research-notes>)[...]` jumps to it; labels must be unique within the whole Bundle. Note that only headings that are linked to export an anchor ID. If you need a stable external anchor that does not depend on a local link, write `#html.h2(id: "research-notes")[Research notes]` instead, keeping in mind that hand-written HTML headings do not appear in `headings()` queries. See the #link("https://typst.app/docs/reference/context/")[Typst context reference].

= HTML export and custom shells

Typst exports native paragraphs, headings, lists, and links as HTML, and provides typed tag functions such as `html.aside` and `html.main`. For non-standard attributes such as `data-*`, use `html.elem`:

```typst
#document("index.html", format: "html", title: "Research notes")[
  #html.html(lang: "en")[
    #html.head[
      #html.meta(charset: "utf-8")
      #html.meta(name: "viewport", content: "width=device-width, initial-scale=1")
      #html.title[Research notes]
      #html.style("main { max-width: 42rem; margin: 2rem auto; padding: 1rem; }")
    ]
    #html.body[
      #html.main[
        #title[Research notes]
        #html.elem("aside", attrs: ("data-kind": "tip"))[
          The sum of the squares is $x^2 + y^2$.
        ]
      ]
    ]
  ]
]
```

When a document builds its own `#html.html` shell, keep `#html.head` (the Typst exporter injects equation styles there) and supply the title, viewport, and stylesheets yourself. Move page layout and responsive styles into a separate CSS file and link it as a #link("/docs/concepts/assets/")[static asset]. A custom shell also does not place footnotes automatically, so documents that use footnotes or bibliographies need an explicit check or a matching `show` rule in the template.

Related references: #link("https://typst.app/docs/reference/html/")[HTML export] · #link("https://typst.app/docs/reference/html/typed/")[Typed HTML] · #link("https://typst.app/docs/reference/bundle/")[Bundle export].

= Equations and MathML

Typst exports equations as standard `<math>` (MathML) by default:

```typst
Inline math $x^2 + y^2$.

$ sum_(i=1)^n i = frac(n(n + 1), 2) $
```

Inline math $x^2 + y^2$, and a display equation on its own line:

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

MathML renders with browser fonts (independently of the fonts the Typst compiler uses), so check line breaking on narrow screens and contrast in light and dark themes in a real browser. If a particular complex equation must be rendered by the Typst compiler as a vector with a specific font, convert it to SVG through `html.frame` (SVG loses MathML's selectable text and accessible math semantics):

```typst
#show math.equation: eq => if eq.at("block", default: false) {
  block(html.frame(eq))
} else {
  box(html.frame(eq))
}
```
