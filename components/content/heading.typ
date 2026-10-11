// HTML heading presentation with a static permalink and ASCII id.

#import "@tola/address:0.0.0": slugify
#import "@tola/document:0.0.0": headings

// ASCII slug; symbol-only text uses "section"; collisions get -2, -3, ...
#let _automatic-heading-id(text, used-ids) = {
  let has-letters-or-digits = text.contains(regex("[\\p{L}\\p{N}]"))
  let base = if has-letters-or-digits {
    slugify(text, mode: "ascii")
  } else {
    "section"
  }

  let candidate = base
  let suffix = 2
  while candidate in used-ids {
    candidate = base + "-" + str(suffix)
    suffix += 1
  }
  candidate
}

// One URL id per headings() record; explicit labels win and are reserved first.
#let _heading-anchor-ids(sections) = {
  let labeled-sections = sections.filter(section => section.label != none)
  let explicit-ids = labeled-sections.map(section => str(section.label))
  let used-ids = explicit-ids
  let ids = ()

  for section in sections {
    if not section.outlined or section.level > 5 {
      ids.push(none)
      continue
    }

    let id = if section.label != none {
      str(section.label)
    } else {
      let generated-id = _automatic-heading-id(section.text, used-ids)
      used-ids.push(generated-id)
      generated-id
    }
    ids.push(id)
  }
  ids
}

// Native link() resolves the target; the show rule only adds attributes.
#let _permalink-link(section, link-label) = {
  let accessible-name = link-label.replace("{title}", section.text)
  let attributes = (
    class: "heading-anchor",
    "aria-label": accessible-name,
    "data-pagefind-ignore": "all",
  )

  show html.elem.where(tag: "a"): element => {
    if element.attrs.at("class", default: none) == attributes.class {
      return element
    }
    html.elem("a", attrs: (:..element.attrs, ..attributes), element.body)
  }
  link(section.location, [])
}

/// Rewrite an outlined heading for HTML, preserving its native record.
#let heading-permalink(source, link-label) = context {
  if target() != "html" or not source.outlined or source.level > 5 {
    return source
  }

  let sections = headings()
  let ids = _heading-anchor-ids(sections)
  let location = source.location()
  let index = sections.position(section => section.location == location)
  let section = sections.at(index)

  let heading-body = source.body
  if section.number != none {
    heading-body = section.number + [ ] + heading-body
  }
  let heading-link = _permalink-link(section, link-label)
  let heading-tag = "h" + str(section.level + 1)
  let heading-attrs = (id: ids.at(index), class: "has-heading-anchor")

  html.elem(heading-tag, attrs: heading-attrs, heading-body + heading-link)
}
