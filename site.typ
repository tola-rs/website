// Publish HTML pages, per-language feeds and the sitemap.
// Site modules prepare the data; templates render complete pages.

#import "@tola/site:0.0.0": site
#import "@tola/collection:0.0.0": group-by, index-by
#import "@tola/address:0.0.0": output-url
#import "@tola/web:0.0.0": head-metadata
#import "site/pages.typ": pages, pages-by-language
#import "site/locales/lib.typ": locales
#import "site/links.typ": localize-link
#import "site/blog.typ": posts
#import "site/docs.typ" as docs
#import "site/feed.typ": feed-output, feed-path, sitemap-output
#import "templates/base.typ" as base
#import "templates/blog.typ" as blog
#import "templates/doc.typ": doc
#import "templates/not-found.typ": not-found
#import "/components/content/diagram.typ": publish-diagrams
#import "/components/content/frame.typ": publish-frames
#import "/components/content/code.typ": reset-code-lines

// Defaults for everything outside a locale-specific document: assets, figures and the 404 shell.
#set text(
  lang: site.language.lang,
  script: site.language.script,
  region: site.language.region,
  font: "Noto Sans SC",
  size: 12pt,
)

// Site data ---------------------------------------------------------------

#let language-order = locales.keys()

// Pages grouped by logical key; each group ordered by configured language.
#let translations-by-key = group-by(
  pages.sorted(key: page => language-order.position(tag => tag == page.locale.tag)),
  key: page => page.key,
)

// Link shorthands resolve against these two sets.
#let published-keys = translations-by-key.keys()
#let published-urls = pages.map(page => output-url(page.output))

// Templates -----------------------------------------------------------------

/// Bind the template for a page kind; the remaining argument is the native body.
#let template-for(page, navigation, translations, tree, feed) = {
  if page.kind == "doc" {
    doc.with(page, navigation, translations, tree, feed: feed)
  } else if page.kind == "blog-index" {
    blog.index.with(page, navigation, translations, feed: feed)
  } else if page.kind == "post" {
    blog.post.with(page, navigation, translations, feed: feed)
  } else {
    base.page.with(page, navigation, translations, feed: feed)
  }
}

/// `document(...)` records author names; the full records stay on the page.
#let author-names(page) = {
  let authors = page.meta.authors
  if authors == none { () } else { authors.map(author => author.name) }
}

// Pages ---------------------------------------------------------------------

#for (tag, locale) in locales {
  let local-pages = pages-by-language.at(tag, default: ())
  let targets-by-key = index-by(local-pages, key: page => page.key)
  let tree = docs.tree(tag)
  let feed = feed-path(locale)
  let navigation = (
    home: targets-by-key.at("/", default: none),
    documentation: tree.reading-order.at(0, default: none),
    blog-index: targets-by-key.at("/blog/", default: none),
  )

  for page in local-pages {
    let translations = translations-by-key.at(page.key)

    [#document(
        page.output,
        format: "html",
        title: page.meta.title,
        description: page.meta.description,
        author: author-names(page),
        keywords: page.meta.tags,
      )[
        #reset-code-lines()
        #set text(lang: locale.lang, script: locale.script, region: locale.region)
        #show: template-for(page, navigation, translations, tree, feed)
        #{
          // Layout links already name their targets; this shorthand belongs to the body.
          show link: element => localize-link(element, targets-by-key, published-keys, published-urls)
          include page.file
        }
      ] #page.label]
  }

}

// Missing page ----------------------------------------------------------------

#let default-locale = locales.at(site.language.tag)
#let missing-title = default-locale.messages.not-found.title
#let homes = pages.filter(page => page.kind == "home")
#let missing-head = head-metadata(site, title: missing-title) + (html.meta(name: "robots", content: "noindex"),)

#document("404.html", format: "html", title: missing-title)[
  #reset-code-lines()
  #not-found(homes, missing-head, default-locale)
]

// Outputs ---------------------------------------------------------------------

// One feed per language that enables it.
#for (tag, locale) in locales {
  let feed = feed-path(locale)
  if feed != none { feed-output(feed, locale, posts(tag)) }
}

#sitemap-output("sitemap.xml", pages)

// Figures recorded while pages rendered; every unique drawing becomes one file.
#publish-diagrams()
#publish-frames()
