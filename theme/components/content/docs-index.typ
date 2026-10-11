// Documentation index grouped by section.

/// Documentation index grouped by section.
#let docs-index(sections, separator) = {
  let index-entry(page) = html.li({
    let label = link(page.label, page.meta.title)
    if page.meta.description != none { label += separator + page.meta.description }
    label
  })
  let index-section(section) = [= #section.title] + html.ul(section.pages.map(index-entry).join())
  if sections.len() == 0 { return }
  html.section(class: "docs-index")[
    #sections.map(index-section).join()
  ]
}
