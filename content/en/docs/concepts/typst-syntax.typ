#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Typst syntax",
  description: "Markup, content values, show rules, and HTML export.",
  order: 0,
))

#title()

Put the markup examples in `content/index.typ` in #link("/docs/getting-started/first-site/")[Your first site]. Use `tola dev` to see the result. The full HTML example goes in `site.typ`.

= Basic syntax

```typst
= Research notes

Put the *conclusion* first and leave _open questions_ for later.

Inline math: $x^2 + y^2$. Put spaces inside the dollar signs for a display equation.

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

== Links

- #link("https://typst.app/")[Typst]
- #link("https://tola.build/")[Tola]
```

Blank lines separate paragraphs. Use `=` and `==` for headings, `-` for bullets, and `+` for numbered lists. Asterisks make text bold and underscores emphasize it. Backticks mark code. In math, `_` and `^` attach subscripts and superscripts, and `frac` makes a fraction.

`#` enters code from markup. Use `#(1 + 2)` to evaluate a full expression. Inside code, brackets such as `[Hello, #name]` return to markup and produce a content value. See #link("https://typst.app/docs/reference/syntax/")[Typst syntax].

= Content and data

== Content functions

A string such as `"tip"` can supply a filename, URL, or HTML attribute. A content value such as `[Read *this*]` can contain markup, links, and equations.

```typst
#let name = "Tola"
#let note(body, kind: "note") = html.aside(class: kind, body)

#note(kind: "tip")[Write a note with *#name*.]
```

`kind: "note"` defines a named parameter with a default. The trailing brackets supply the positional `body` argument. The example produces an `<aside class="tip">` containing emphasized text.

== Arrays and dictionaries

`(a, b)` is an array, and `(a,)` is a one-item array. `(title: "Home", draft: false)` is a dictionary. A site can store pages in an array and each page's fields in a dictionary.

```typst
#let notes = (
  (title: "First note", draft: false),
  (title: "Draft", draft: true),
)

#{
  let published = notes.filter(note => not note.draft)
  list(..published.map(note => [#note.title]))
}
```

`filter` selects published notes and `map` extracts their titles as content. `..` spreads the resulting array into separate arguments to `list`. A code block combines values in order. A `let` binding contributes no output. A `for` loop similarly combines its iterations' results.

Put a multi-line method chain inside a code block or parentheses so Typst reads it as a single expression. See #link("https://typst.app/docs/reference/scripting/")[Typst scripting].

= Import and include

Use `import` to bring named definitions into scope. Use `include` to insert another file's content. Save the earlier `note` function to `components/note.typ` and create `components/intro.typ`. Then add this to `content/index.typ`.

```typst
#import "/components/note.typ": note
#note[This text goes to the component.]

#include "/components/intro.typ"
```

Each file has its own scope. Pass page data as arguments to components. Relative paths start beside the calling file. A leading slash starts at the project or package root.

= Rules and context

== Set and show

`set` supplies defaults for an element. A `show` rule can replace matching elements with a function's result. Without a selector, `#show: function` passes the remaining content to that function.

```typst
#let article(body) = html.article(class: "note", body)
#show: article
#set heading(numbering: "1.")

= Research notes

== Conclusion

These are still Typst headings.
```

`#show heading: it => ...` receives one heading at a time. Its body is `it.body`. Keep headings available for the table of contents and references. Use CSS for web layout and breakpoints. See #link("https://typst.app/docs/reference/styling/")[Typst styling].

== Context queries

The same `content` value can appear in different HTML documents. `context` delays queries until Typst places that content in a document. Here `current-document()` gives the output path of the enclosing document through its `output` field.

```typst
#import "@tola/document:0.0.0": current-document

#context {
  let page = current-document()
  [Output: #raw(page.output).]
}

= Research notes <research-notes>

#link(<research-notes>)[Jump to heading]
```

The angle-bracket label lets `link` find the heading. Use unique labels within a Bundle. `headings()` reads the headings of the current document. See #link("https://typst.app/docs/reference/context/")[Typst context].

= HTML export

Typst exports headings, paragraphs, lists, and links as HTML. Use `html.aside` and other typed constructors for HTML elements. Use `html.elem("aside", attrs: ("data-kind": "tip"))[Body]` for custom attributes.

== Page example

Use this as `site.typ` in a test site. It declares HTML outputs and supplies its own head and body.

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
        = Research notes
        #html.elem("aside", attrs: ("data-kind": "tip"))[
          The sum of the squares is $x^2 + y^2$.
        ]
      ]
    ]
  ]
]

#document("404.html", format: "html")[Page not found.]
```

Run `tola build` and inspect `public/index.html` for `<main>`, an `<aside>` with `data-kind`, and `<math>`. For a shared theme, move the inline styles into a #link("/docs/concepts/assets/")[stylesheet asset].

#link("https://typst.app/docs/reference/html/")[HTML export] · #link("https://typst.app/docs/reference/html/typed/")[Typed HTML] · #link("https://typst.app/docs/reference/bundle/")[Bundle export]

= MathML

Typst emits `<math>` for both inline and display equations.

```typst
Inline math $x^2 + y^2$.

$ sum_(i=1)^n i = frac(n(n + 1), 2) $
```

Inline math $x^2 + y^2$.

$ sum_(i=1)^n i = frac(n(n + 1), 2) $

Inspect the HTML to find `<msup>` for superscripts and `<mfrac>` for the fraction. The display equation has `display="block"`. See #link("https://typst.app/blog/2026/typst-0.15#mathml")[MathML in Typst 0.15].
