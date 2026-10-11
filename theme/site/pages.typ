// Selected pages: locale, segments, key, kind, output, and label.

#import "@tola/source:0.0.0": all-sources, parse-sources
#import "@tola/document:0.0.0": current-document
#import "@tola/collection:0.0.0": group-by, index-by
#import "@tola/address:0.0.0": join-route, output-of, slugify
#import "@tola/schema:0.0.0": array-of, parse
#import "/schemas/page.typ": page-schema, post-schema
#import "/schemas/source.typ": source-schema
#import "locales/lib.typ": source-location
#import "../settings.typ": docs-section

/// Page kind from language-free segments.
#let page-kind(segments) = {
  let section = segments.at(0, default: none)
  if section == none { "home" } else if section == docs-section { "doc" } else if (
    section == "blog"
  ) {
    if segments.len() == 1 { "blog-index" } else { "post" }
  } else { "page" }
}

// Locale prefix plus slugged segments; a permalink wins.
#let _page-route(locale, segments, permalink) = {
  if permalink != none { return permalink }
  let slugs = segments.map(segment => slugify(segment, language: locale.lang))
  let prefix = locale.route.slice(0, -1)
  prefix + join-route(slugs)
}

// Page record; `key` is logical, `output` is the publication filename.
#let _source-page(source) = {
  let (locale, prefix-length) = source-location(source.path)
  let segments = source.route-segments.slice(prefix-length)
  let route = _page-route(locale, segments, source.meta.permalink)
  let label-name = if source.route-segments.len() == 0 { source.path } else { source.route-segments.join("/") }
  (
    ..source,
    locale: locale,
    segments: segments,
    key: join-route(segments),
    kind: page-kind(segments),
    output: output-of(route),
    label: label(label-name),
  )
}

// Posts also require a publication date.
#let _metadata-schema(source) = {
  let location = source-location(source.path)
  if location != none and page-kind(source.route-segments.slice(location.prefix-length)) == "post" {
    post-schema
  } else {
    page-schema
  }
}

// Check all metadata, drop drafts, then resolve published pages.
#let _select-pages(sources) = {
  let resolved = parse-sources(sources, _metadata-schema)
  let published = resolved.filter(source => not source.meta.draft)
  parse(published, array-of(source-schema)).map(_source-page)
}

/// All selected pages, in source order.
#let pages = _select-pages(all-sources())

/// Pages by canonical language tag.
#let pages-by-language = group-by(pages, key: page => page.locale.tag)

/// Published pages indexed by language and logical route.
#let pages-by-language-and-key = {
  let by-language = (:)
  for (tag, local-pages) in pages-by-language {
    by-language.insert(tag, index-by(local-pages, key: page => page.key))
  }
  by-language
}

/// Page containing this call, or none in a generated output.
#let current-page() = pages.find(page => page.output == current-document().output)
