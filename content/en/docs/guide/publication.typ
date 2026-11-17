#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Sharing, feeds, and sitemaps",
  description: "Generate <head> metadata and social sharing cards, then publish feed.xml and sitemap.xml.",
  order: 30,
))

#title()

Canonical addresses, Open Graph cards, RSS feeds, and sitemaps all need the absolute URL the site is finally deployed at, so start by setting `[site].origin` in `tola.toml`:

```toml
[site]
origin = "https://example.com"
```

= Generating `<head>` and sharing tags

`@tola/head` provides `head-metadata` (title, character encoding, viewport, description) along with `canonical`, `open-graph`, and `twitter-card`. In a custom `html.html` shell, concatenate the arrays they return and place them into `html.head` with `.join()`:

```typst
#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": output-url
#import "@tola/document:0.0.0": plain-text
#import "@tola/head:0.0.0": canonical, head-metadata, open-graph

#let url = output-url("index.html", origin: site.origin)
#let page-title = plain-text([My site])
#let entries = (
  head-metadata(site, title: page-title)
  + canonical(url)
  + open-graph(title: page-title, url: url)
)

#document("index.html", format: "html")[
  #html.html[
    #html.head(entries.join())
    #html.body[Welcome.]
  ]
]
```

With `origin` configured, the build writes `<title>`, `<link rel="canonical" ...>`, and `og:title` / `og:type` / `og:url` metadata into the `<head>` of `public/index.html`.

#callout[
  Two details are easy to miss. First, when an article title is formatted Typst `content`, extract plain text with `plain-text` from `@tola/document` before passing it to the tag functions. Second, the cover image address in a sharing card does not publish the image; confirm that the file is actually emitted through `[assets]` or `@tola/image`.
]

= Publishing feeds and a sitemap

Call `@tola/feed` and `@tola/sitemap` at the end of `site.typ` to generate `feed.xml` and `sitemap.xml`:

```typst
#import "@tola/feed:0.0.0": feed
#import "@tola/sitemap:0.0.0": sitemap

#feed(
  title: "My site",
  entries: ((
    id: "urn:my-site:install-guide",
    target: "guide/install/index.html",
    title: "Installation guide",
    published: datetime(year: 2026, month: 9, day: 1),
  ),),
)

#sitemap(targets: ("index.html", "guide/install/index.html"))
```

About feed entries and full-text output:

- *Stable `id` and timestamps*: give each article an `id` that does not change with its URL so readers do not see duplicate items. When `@tola/schema` parses a `timestamp`, pass `.rfc3339` directly.
- *Summary only or full text*: with only `summary`, an entry carries the summary alone. To include the article body without the page header and navigation, give the body container a unique ID such as `id: "article"` and pass `content: (document: page.output, id: "article")` to the entry.
- *Linking to a section*: to make a feed entry jump to a specific heading, declare a fixed anchor with `#html.h2(id: "requirements")[Requirements]` and set the entry's `target` to `(output: "guide/install/index.html", fragment: "requirements")`.
- *Sitemaps*: `sitemap` covers whole documents and does not support fragments. It accepts a date or timestamp as the modification date, and generating it should be skipped while the site has no `origin`.

Full parameters: #link("/docs/reference/packages/head/")[`head`] · #link("/docs/reference/packages/feed/")[`feed`] · #link("/docs/reference/packages/sitemap/")[`sitemap`].
