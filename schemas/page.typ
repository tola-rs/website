// Page and post metadata.

#import "@tola/schema:0.0.0": (
  check, convert, date, describe, issue, literal, non-empty, nullable, ok, one-or-many, optional, schema, timestamp,
  trim, union, url-path,
)
#import "@tola/site:0.0.0": site
#import "@tola/web:0.0.0": plain-text

/// Author: a name, or a dictionary with name, email, and url.
#let author = convert(
  union(non-empty(trim(str)), schema(
    (
      name: non-empty(trim(str)),
      email: optional(nullable(str)),
      url: optional(nullable(str)),
    ),
    unknown: "keep",
  )),
  value => ok(if type(value) == str { (name: value) } else { value }),
  output: dictionary,
)

/// Metadata text: trimmed string or inline content.
#let page-text = union(trim(str), content)

/// Page metadata fields.
#let page-schema = check(
  schema((
    order: describe(
      optional(int, default: 0),
      "documentation position among published siblings in this language; unique within its parent (default 0), with gaps allowed; fixed groups ignore it",
    ),
    title: describe(
      optional(nullable(page-text), default: site.title),
      "the page title, shown in the browser tab and in lists",
    ),
    description: describe(
      optional(nullable(page-text), default: site.description),
      "the page summary, shown in search results and link previews",
    ),
    authors: describe(
      optional(nullable(one-or-many(author)), default: site.authors),
      "who wrote the page: a name, or a dictionary with name, email, and url",
    ),
    tags: describe(
      optional(one-or-many(str), default: ()),
      "the topics this page belongs to",
    ),
    draft: describe(
      optional(bool, default: false),
      "keeps the page out of the published site",
    ),
    permalink: describe(
      optional(nullable(url-path), default: none),
      "overrides the route: `/about/` is a directory, `/about.html` is a file; encode literal % and # as %25 and %23",
    ),
    feed: describe(
      optional(bool, default: true),
      "includes this blog post in its language's RSS feed",
    ),
    sitemap: describe(
      optional(bool, default: true),
      "includes the page in `sitemap.xml`",
    ),
    neighbors: describe(
      optional(bool, default: true),
      "shows previous/next links on documentation pages",
    ),
    feed-id: describe(
      optional(union(str, literal(auto)), default: auto),
      "a stable feed identifier; `auto` derives one from the page's address",
    ),
    published: describe(
      optional(nullable(timestamp), default: none),
      "the publication date: a calendar datetime (missing time means UTC midnight), or an RFC 3339 string with timezone; leap seconds are unsupported",
    ),
    updated: describe(
      optional(nullable(union(date, timestamp)), default: none),
      "the last change: a calendar date or timestamp; date-only values keep their calendar precision",
    ),
    feed-summary: describe(
      optional(nullable(page-text), default: none),
      "an RSS summary alongside the body: plain text, or markup limited to text, breaks, emphasis, strong, strike, and URL links",
    ),
    feed-content: describe(
      optional(nullable(union(literal(auto), str, content, dictionary)), default: auto),
      "the feed body: auto selects the article, none omits it; otherwise plain text, supported markup, or a `(document:, id:)` selection",
    ),
  )),
  meta => {
    if not meta.draft and (meta.title == none or plain-text(meta.title).trim() == "") {
      (issue("Published pages need a nonempty title", path: ("title",)),)
    } else { () }
  },
  on: ("draft", "title"),
)

/// Posts also require a publication date unless drafted.
#let post-schema = check(
  page-schema,
  meta => {
    if not meta.draft and meta.published == none {
      (issue("Published blog pages need a publication date; use draft: true while writing", path: ("published",)),)
    } else { () }
  },
  on: ("draft", "published"),
)
