// Blog article order, grouped by language.

#import "@tola/collection:0.0.0": group-by
#import "pages.typ": pages

#let _posts-by-language = group-by(
  pages
    .filter(page => page.kind == "post")
    .sorted(key: post => (post.meta.published.unix-seconds, post.meta.published.subsecond, post.key))
    .rev(),
  key: post => post.locale.tag,
)

/// Blog articles for one language, newest first.
#let posts(language) = _posts-by-language.at(language, default: ())
