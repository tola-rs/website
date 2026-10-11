#import "@tola/site:0.0.0": site, project-path
#import "@tola/collection:0.0.0": group-by, index-by
#import "@tola/address:0.0.0": output-of, output-url, route-of
#import "@tola/head:0.0.0": head-metadata
#import "site/pages.typ": pages, pages-by-language, pages-by-language-and-key
#import "settings.typ": font, options
#import "components/assets.typ": output-name
#import "@tola/module:0.0.0": get-module
#import "site/locales/lib.typ": locales
#import "site/links.typ": localize-link, preview-link
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

#set text(
  lang: site.language.lang,
  script: site.language.script,
  region: site.language.region,
  font: font,
  size: 12pt,
)

// Pages grouped by logical key; each group ordered by configured language.
#let translations-by-key = group-by(
  locales.keys().map(tag => pages-by-language.at(tag, default: ())).flatten(),
  key: page => page.key,
)

#let pages-by-url = index-by(pages, key: page => output-url(page.output))
#let nav-keys = options.nav-pages.map(path => route-of(output-of(path))).dedup()

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

#let page-body(page, targets-by-key) = {
  show link: element => localize-link(element, targets-by-key, translations-by-key, pages-by-url)
  if options.styles {
    show html.elem.where(tag: "a"): element => preview-link(element, page, pages-by-url)
    include page.file
  } else {
    include page.file
  }
}

#for (tag, locale) in locales {
  let local-pages = pages-by-language.at(tag, default: ())
  let targets-by-key = pages-by-language-and-key.at(tag, default: (:))
  let tree = docs.tree(tag)
  let feed = feed-path(locale, posts(tag))
  let navigation = (
    home: targets-by-key.at("/", default: none),
    documentation: tree.reading-order.at(0, default: none),
    pages: nav-keys.map(key => targets-by-key.at(key, default: none)).filter(target => target != none),
    blog-index: targets-by-key.at("/blog/", default: none),
  )

  for page in local-pages {
    let translations = translations-by-key.at(page.key)

    [#document(
        page.output,
        format: "html",
        title: page.meta.title,
        description: page.meta.description,
        author: if page.meta.authors == none { () } else { page.meta.authors.map(author => author.name) },
        keywords: page.meta.tags,
      )[
        #reset-code-lines()
        #set text(lang: locale.lang, script: locale.script, region: locale.region)
        #show: template-for(page, navigation, translations, tree, feed)
        #page-body(page, targets-by-key)
      ] #page.label]
  }
}

#let default-locale = locales.at(site.language.tag)
#let missing-title = default-locale.messages.not-found.title
#let homes = pages.filter(page => page.kind == "home")
#let missing-head = head-metadata(site, title: missing-title) + (html.meta(name: "robots", content: "noindex"),)

#document("404.html", format: "html", title: missing-title)[
  #reset-code-lines()
  #not-found(homes, missing-head, default-locale)
]

#for (tag, locale) in locales {
  let entries = posts(tag)
  let feed = feed-path(locale, entries)
  if feed != none { feed-output(feed, locale, entries) }
}

#sitemap-output("sitemap.xml", pages)

#if options.styles {
  let output = output-name("styles/site.css")
  let source = project-path("generated/" + get-module().name + "/styles/site.css")
  asset(output, read(source, encoding: none))
}

#publish-diagrams()
#publish-frames()
