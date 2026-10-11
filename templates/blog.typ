// Blog index and post templates.

#import "@tola/address:0.0.0": output-url
#import "base.typ": base, main, page as single-page, page-layout
#import "/components/content/lib.typ": post-byline
#import "/components/partials/lib.typ": toc

// Subscription link when a feed exists.
#let feed-link(feed, text) = if feed != none { html.p(link(output-url(feed), text)) }

// Back link to the blog index.
#let index-return-link(target, text) = if target != none { html.p(link(target.label, text)) }

/// Blog index.
#let index(page, navigation, translations, body, feed: none) = single-page(page, navigation, translations, feed: feed)[
  #body
  #feed-link(feed, page.locale.messages.blog.rss)
]

/// Blog post with byline and table of contents.
#let post(page, navigation, translations, body, feed: none) = base(page, navigation, translations, feed: feed)[
  #page-layout("blog")[
    #toc(page.locale.messages.on-this-page)
    #main(article: true, after: index-return-link(navigation.blog-index, page.locale.messages.blog.back))[
      #post-byline(page.meta, page.locale.messages.blog)
      #body
    ]
  ]
]
