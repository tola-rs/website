// The Bundle root supplies page data for contextual helpers in document bodies.

#import "@tola/address:0.0.0": output-url
#import "@tola/document:0.0.0": current-document

#let _data = state("docs-render-data", none)

#let set-render-data(pages-by-url, trees-by-language, posts-by-language) = _data.update((
  pages: pages-by-url,
  trees: trees-by-language,
  posts: posts-by-language,
))

/// Page containing this call, or none in a generated output.
#let current-page() = _data.final().pages.at(output-url(current-document().output), default: none)

/// Index sections, optionally omitting a page key.
#let sections(language, omit: none) = {
  _data.final().trees.at(language).sections
    .map(section => (..section, pages: section.pages.filter(page => page.key != omit)))
    .filter(section => section.pages.len() > 0)
}

/// Blog articles for one language, newest first.
#let posts(language) = _data.final().posts.at(language, default: ())
