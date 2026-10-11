#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Sharing, feeds, and sitemaps",
  description: "Set up social previews and publish feed.xml and sitemap.xml.",
  order: 20,
))

#title()

When migrating from `@tola/web`, import the relevant functions from `@tola/head`, `@tola/feed`, and `@tola/sitemap`. Import `plain-text` from `@tola/document`.

= HTML head

`head-metadata` creates the title, encoding, viewport, and description. `canonical`, `open-graph`, and `twitter-card` add canonical URLs and social previews. Join their arrays before passing them to `html.head`.

Use `output-url(page.output, origin: site.origin)` to derive the absolute production URL.

= Feed and sitemap

In #link("/docs/getting-started/first-site/")[Your first site], set `[site].origin` to `"https://example.com"` and append this to `site.typ`.

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

`tola build` writes `public/feed.xml` and `public/sitemap.xml`. Give each RSS entry a target and a publication date. A stable `id` lets readers recognize the entry if the URL changes.

A feed entry can link to a fragment such as `guide/install/index.html#requirements`. A sitemap target must name a whole document.

= Build utilities

`@tola/hash` hashes bytes. `@tola/uuid` derives stable UUIDs from namespaces and names. `@tola/diagnostic` reports messages with a severity, source location, and suggestions.

See #link("/docs/reference/packages/feed/")[`feed`] and #link("/docs/reference/packages/sitemap/")[`sitemap`] for parameters.
