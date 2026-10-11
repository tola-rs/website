// Table of contents from the current document's outlined headings.

#import "@tola/document:0.0.0": headings
#import "../icon.typ": icon
#import "../assets.typ": inline-script

// Group headings by nesting.
#let _toc-groups(outlined) = {
  let groups = ()
  for heading in outlined {
    if heading.nesting == 1 {
      groups.push((heading: heading, children: ()))
    } else {
      groups.last().children.push(heading)
    }
  }
  groups
}

/// Table of contents; renders nothing without outlined headings.
#let toc(title) = context {
  let outlined = headings(depth: 2).filter(heading => heading.outlined)
  if outlined.len() == 0 { return }
  let groups = _toc-groups(outlined)
  html.elem("aside", attrs: (class: "page-toc", "data-pagefind-ignore": ""))[
    #html.elem("details", attrs: (class: "navigation-panel", "data-navigation-panel": "toc"))[
      #html.summary(class: "navigation-toggle")[
        #title
        #icon("chevron-down")
      ]
      #html.nav(aria-label: title)[
        #html.h2(class: "navigation-title", title)
        #html.ul[
          #for group in groups {
            html.li[
              #link(group.heading.location, group.heading.text)
              #if group.children.len() > 0 {
                html.ul(class: "nav-children")[
                  #for heading in group.children { html.li(link(heading.location, heading.text)) }
                ]
              }
            ]
          }
        ]
      ]
    ]
    #html.script(inline-script("navigation-init"))
  ]
}
