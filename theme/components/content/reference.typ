#import "@tola/address:0.0.0": output-of, output-url
#import "../../site/pages.typ": current-page
#import "reference-data.typ": reference-id, reference-scheme

#let _english() = current-page().locale.tag == "en"

#let _destination(target, current, pages) = {
  if not target.starts-with(reference-scheme) { return target }
  let parts = target.slice(reference-scheme.len()).split("#")
  let page = parts.first()
  let anchor = parts.at(1, default: none)
  let locale = current-page().locale
  let prefix = locale.route.trim("/", at: end)
  let segments = page.split("/")
  if segments.first() == "packages" and segments.len() == 3 {
    page = segments.slice(0, 2).join("/")
    let member = pages.at(page).exports.find(item => item.name == segments.last())
    anchor = member.anchor
  }
  let route = output-url(output-of(prefix + "/docs/reference/" + page + "/"))
  if anchor == none { return route }
  let id = reference-id(page, anchor, locale.tag)
  if page == current { label(id) } else { route + "#" + id }
}

#let _spans(spans, page, pages) = spans.map(span => {
  let value = span.value
  if span.kind == "text" { text(value) }
  else if span.kind == "code" { raw(value) }
  else if span.kind == "emph" { emph(_spans(value, page, pages)) }
  else if span.kind == "strong" { strong(_spans(value, page, pages)) }
  else if span.kind == "link" {
    link(_destination(value.target, page, pages), _spans(value.label, page, pages))
  } else { panic("Unknown reference span: " + span.kind) }
}).join()

#let _heading(page, anchor, body, level: 1) = [
  #heading(level: level, body)#label(reference-id(page, anchor, current-page().locale.tag))
]

#let _blocks(blocks, page, pages, offset: 0) = blocks.map(item => {
  if item.kind == "paragraph" { _spans(item.spans, page, pages) }
  else if item.kind == "heading" {
    _heading(page, item.anchor, _spans(item.spans, page, pages), level: calc.max(1, item.level + offset))
  } else if item.kind == "code" { raw(item.source.trim("\n", at: end), lang: item.language, block: true) }
  else if item.kind == "list" {
    let items = item.items.map(blocks => _blocks(blocks, page, pages, offset: offset))
    if item.start == none { list(..items) } else { enum(start: item.start, ..items) }
  } else if item.kind == "table" {
    let spans = cell => _spans(cell, page, pages)
    let alignments = item.alignments.map(name => ("auto": auto, left: left, center: center, right: right).at(name))
    let cells = item.rows.map(row => row.map(spans)).flatten()
    table(columns: item.headers.len(), align: alignments, table.header(..item.headers.map(spans)), ..cells)
  } else if item.kind == "quote" {
    quote(block: true, _blocks(item.blocks, page, pages, offset: offset))
  } else if item.kind == "rule" { html.hr() }
  else { panic("Unknown reference block: " + item.kind) }
}).join(parbreak())

#let _related(links, page, pages) = if links.len() > 0 {
  let title = if _english() { [Related] } else { [相关条目] }
  let separator = if _english() { [: ] } else { [：] }
  par(strong(title) + separator + links.map(item => link(
    _destination(item.target, page, pages), raw(item.title),
  )).join([, ]))
}

#let _parameters(params, page, pages) = {
  let en = _english()
  for (kind, title) in (
    ("positional", if en { [Positional parameters] } else { [位置参数] }),
    ("rest", if en { [Rest parameters] } else { [可变参数] }),
    ("named", if en { [Named parameters] } else { [命名参数] }),
    ("option", if en { [Options] } else { [选项] }),
  ) {
    let group = params.filter(param => param.kind == kind)
    if group.len() == 0 { continue }
    html.p(strong(title))
    html.ul(class: "reference-parameters", group.map(param => {
      let name = raw(if param.kind == "rest" { ".." + param.name } else { param.name })
      if param.at("short", default: none) != none { name += [, ] + raw("-" + param.short) }
      if param.required { name += if en { [ (required)] } else { [（必填）] } }
      if param.blocks.len() > 0 {
        let separator = if en { [: ] } else { [：] }
        name += separator + _blocks(param.blocks, page, pages)
      }
      html.li(name)
    }).join())
  }
}

#let reference-page(data, pages) = context {
  let page = data.page.slice(reference-scheme.len())
  let entries = data.at("entries", default: ())
  let keys = data.at("keys", default: ())
  let exports = data.at("exports", default: ())
  let commands = data.at("commands", default: ())
  let imports = data.at("import", default: none)
  if imports != none {
    _heading(page, "import-in-typst", if _english() { [Import] } else { [导入] })
    raw(imports, lang: "typst", block: true)
  }
  _blocks(data.at("blocks", default: ()), page, pages, offset: -1)
  if entries.len() > 0 {
    list(..entries.map(entry => link(_destination(entry.target, page, pages), raw(entry.title))))
  }
  if keys.len() > 0 {
    _heading(page, "keys", if _english() { [Configuration keys] } else { [配置字段] })
    for key in keys {
      _heading(page, key.path, raw(key.path), level: 2)
      _blocks(key.blocks, page, pages)
    }
  }
  if exports.len() > 0 {
    _heading(page, "exports", if _english() { [Exports] } else { [导出成员] })
    let language = current-page().locale.tag
    html.ul(class: "reference-exports", exports.map(member => {
      html.li(link(label(reference-id(page, member.anchor, language)), raw(member.name)))
    }).join())
  }
  _related(data.at("related", default: ()), page, pages)
  for member in exports {
    _heading(page, member.anchor, member.name)
    raw(member.declaration, lang: "typc", block: true)
    _blocks(member.blocks, page, pages, offset: -1)
    _parameters(member.parameters, page, pages)
    for method in member.methods {
      _heading(page, method.anchor, method.name, level: 2)
      raw(method.declaration, lang: "typc", block: true)
      _blocks(method.at("blocks", default: ()), page, pages)
      _parameters(method.parameters, page, pages)
    }
    _related(member.related, page, pages)
  }
  for command in commands {
    _heading(page, command.anchor, command.name)
    raw(command.usage, lang: "sh", block: true)
    _blocks(command.blocks, page, pages, offset: -1)
    _parameters(command.parameters + command.options, page, pages)
  }
}
