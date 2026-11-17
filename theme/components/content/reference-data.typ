#let reference-scheme = "tola-help://"

#let reference-id(page, anchor, language) = {
  let prefix = if language == "en" { "en-ref-" } else { "ref-" }
  prefix + page.replace("/", "-") + "-" + anchor
}

#let _span-text(spans) = spans.map(span => {
  if span.kind in ("emph", "strong") { _span-text(span.value) }
  else if span.kind == "link" { _span-text(span.value.label) }
  else { span.value }
}).join()

#let _summary(blocks) = {
  let paragraph = blocks.find(block => block.kind == "paragraph")
  if paragraph == none { "" } else { _span-text(paragraph.spans).trim() }
}

/// Titles and previews for a reference page and its members.
#let reference-metadata(data, order: 0) = {
  let page = data.page.slice(reference-scheme.len())
  let previews = (:)
  for member in data.at("exports", default: ()) {
    for entry in (member,) + member.methods {
      previews.insert(reference-id(page, entry.anchor, data.language), (
        title: entry.name,
        description: _summary(entry.at("blocks", default: ())),
        signature: if entry.at("kind", default: "function") == "function" { entry.declaration } else { "" },
        same-page: true,
      ))
    }
  }
  (title: data.title, description: _summary(data.at("blocks", default: ())), order: order, link-previews: previews)
}
