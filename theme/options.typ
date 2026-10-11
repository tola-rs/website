// Project options for the docs theme.
//
// Tola merges the manifest defaults with the site's module options before validation.

#import "@tola/schema:0.0.0" as s

#let schema = s.schema((
  /// The site's source repository, linked from the header.
  repository: s.optional(s.nullable(str), default: none),
  /// The repository that owns the site's own source, linked from the footer.
  site-repository: s.optional(s.nullable(str), default: none),
  /// Project-relative source file for the homepage logo.
  logo: s.optional(s.nullable(str), default: none),
  /// Project-relative source file for browser and home-screen icons.
  favicon: s.optional(s.nullable(str), default: none),
  /// Tool versions shown in the footer.
  versions: s.optional(s.dictionary-of(str), default: (:)),
  /// Display names for keys in `versions`; keys are used when no name is supplied.
  version-labels: s.optional(s.dictionary-of(str), default: (:)),
  /// Copyright shown in the footer.
  copyright: s.optional(s.dictionary-of(str), default: (:)),
  /// Top-level content directory and URL segment for documentation.
  docs-section: s.refine(str, value => value.match(regex("^[a-z0-9]+(-[a-z0-9]+)*$")) != none and value != "blog", message: "expected a lowercase route segment other than `blog`"),
  /// Documentation group order; groups not listed sort last.
  docs-groups: s.array-of(str),
  /// Additional logical page routes to show in the header.
  nav-pages: s.array-of(s.refine(str, value => value.starts-with("/") and value.ends-with("/"), message: "expected a logical page route such as `/about/`")),
  /// Whether to generate blog feeds without published posts.
  blog-feed: s.enum-of(("auto", "always", "off")),
  /// The body font used for Typst documents.
  font: str,
  /// Compile the browser TypeScript entry points before the site is built.
  typescript: bool,
  /// Compile the Tailwind stylesheet from sources before rendering.
  styles: bool,
  /// Generate the Pagefind index and rich search previews after the site is built.
  search: bool,
  /// Default native image parameters and optional batch conversion.
  resize-images: s.schema((
    enabled: bool,
    format: s.enum-of(("webp", "png", "jpg")),
    quality: s.refine(int, value => value >= 0 and value <= 100, message: "expected an image quality from 0 to 100"),
    widths: s.array-of(s.refine(int, value => value > 0, message: "expected a positive image width")),
    background: s.refine(str, value => value == "" or value.match(regex("^#[0-9a-fA-F]{6}$")) != none, message: "expected an empty background or an opaque #RRGGBB color"),
  )),
  /// Locale message overrides keyed by canonical language tag.
  messages: s.optional(s.dictionary-of(s.any), default: (:)),
  /// Locale names, content directories and routes keyed by canonical language tag.
  locales: s.optional(s.dictionary-of(s.schema((
    name: s.optional(str),
    directory: s.optional(str),
    route: s.optional(str),
  ))), default: (:)),
))
