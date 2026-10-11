// Page head entries.

#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": output-url
#import "@tola/web:0.0.0": canonical, head-metadata, plain-text
#import "/components/assets.typ": favicon-png-url, favicon-url

// Site name alone on the home page; otherwise "Page | Site".
#let _browser-title(page) = {
  let site-name = plain-text(site.title)
  if page.kind == "home" { return site-name }
  if page.meta.title == none { return none }
  let page-name = plain-text(page.meta.title)
  if page-name == site-name { site-name } else { page-name + " | " + site-name }
}

#let _translation-links(translations) = {
  let entries = translations.map(target => html.link(
    rel: "alternate",
    hreflang: target.locale.tag,
    href: output-url(target.output, origin: site.origin),
  ))
  let default-target = translations.find(target => target.locale.tag == site.language.tag)
  if default-target != none {
    entries.push(html.link(rel: "alternate", hreflang: "x-default", href: output-url(
      default-target.output,
      origin: site.origin,
    )))
  }
  entries
}

/// Browser metadata for one page; pass published translations only.
#let head-entries(page, translations, feed: none) = {
  let entries = head-metadata(site, title: _browser-title(page), description: page.meta.description)
  entries.push(html.elem("meta", attrs: (
    name: "page-kind",
    content: page.kind,
    "data-pagefind-meta": "kind[content]",
    "data-pagefind-filter": "kind[content]",
  )))
  entries.push(html.elem("meta", attrs: (
    name: "search-preview",
    content: output-url("assets/search-previews/" + page.output + ".json"),
    "data-pagefind-meta": "preview[content]",
  )))
  entries.push(html.link(
    rel: "icon",
    type: "image/svg+xml",
    href: favicon-url(),
  ))
  entries.push(html.link(
    rel: "icon",
    type: "image/png",
    sizes: ((32, 32),),
    href: favicon-png-url(32),
  ))
  // apple-touch-icon is not a typed rel token.
  entries.push(html.elem("link", attrs: (
    rel: "apple-touch-icon",
    sizes: "180x180",
    href: favicon-png-url(180),
  )))
  if feed != none {
    entries.push(html.link(
      rel: "alternate",
      type: "application/rss+xml",
      title: plain-text(site.title) + " " + page.locale.messages.blog.title,
      href: output-url(feed),
    ))
  }
  if site.origin != none {
    entries += canonical(output-url(page.output, origin: site.origin))
    entries += _translation-links(translations)
  }
  entries
}
