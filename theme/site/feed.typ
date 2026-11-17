// Feed and sitemap outputs.

#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": output-of
#import "@tola/feed:0.0.0": feed
#import "@tola/document:0.0.0": plain-text
#import "@tola/sitemap:0.0.0": sitemap
#import "../settings.typ": options

// Timestamps serialize as RFC 3339; calendar dates stay as written.
#let _date-value(value) = if type(value) == dictionary { value.rfc3339 } else { value }

#let _sitemap-target(page) = (
  target: page.output,
  lastmod: _date-value(page.meta.updated),
)

/// Sitemap from selected pages; omitted without a site origin.
#let sitemap-output(output, pages) = {
  if site.origin == none { return }
  sitemap(
    output: output,
    targets: pages.filter(page => page.meta.sitemap).map(_sitemap-target),
  )
}

/// RSS output filename for one language when its feed is enabled.
#let feed-path(locale, posts) = {
  if options.blog-feed == "off" or site.origin == none or site.title == "" { return none }
  if options.blog-feed == "auto" and not posts.any(post => post.meta.feed) { return none }
  output-of(locale.route + "feed.xml")
}

#let _feed-entry(post) = (
  id: post.meta.feed-id,
  target: post.output,
  published: post.meta.published.rfc3339,
  updated: _date-value(post.meta.updated),
  summary: post.meta.feed-summary,
  content: if post.meta.feed-content == auto {
    (document: post.output, id: "page-content")
  } else { post.meta.feed-content },
)

/// RSS for one language, in the supplied order.
#let feed-output(output, locale, posts) = feed(
  output: output,
  language: locale.tag,
  title: plain-text(site.title) + " " + locale.messages.blog.title,
  description: locale.messages.blog.feed-description,
  entries: posts.filter(post => post.meta.feed).map(_feed-entry),
)
