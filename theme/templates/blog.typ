#import "@tola/address:0.0.0": output-url
#import "base.typ": base, main, page as single-page, page-layout
#import "/components/content/lib.typ": post-byline
#import "/components/partials/lib.typ": toc

#let index(page, navigation, translations, body, feed: none) = single-page(page, navigation, translations, feed: feed)[
  #body
  #if feed != none { html.p(link(output-url(feed), page.locale.messages.blog.rss)) }
]

#let post(page, navigation, translations, body, feed: none) = {
  let messages = page.locale.messages
  let index = navigation.blog-index
  let return-link = if index != none { html.p(link(index.label, messages.blog.back)) }
  base(page, navigation, translations, feed: feed)[
    #page-layout("blog")[
      #toc(messages.on-this-page)
      #main(article: true, after: return-link)[
        #post-byline(page.meta, messages.blog)
        #body
      ]
    ]
  ]
}
