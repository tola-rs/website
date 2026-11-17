// Blog article order, grouped by language.

#import "@tola/collection:0.0.0": group-by

/// Blog articles grouped by language, newest first.
#let posts-by-language(pages) = group-by(
  pages
    .filter(page => page.kind == "post")
    .sorted(key: post => (post.meta.published.unix-seconds, post.meta.published.subsecond, post.key))
    .rev(),
  key: post => post.locale.tag,
)
