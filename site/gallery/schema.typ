// Values displayed by the theme gallery component.

#import "@tola/schema:0.0.0" as s

#let entry = s.schema((
  name: s.non-empty(s.trim(str)),
  description: str,
  repo: str,
  demo: str,
  tags: s.optional(s.array-of(str), default: ()),
  screenshot: str,
  alt: str,
))

#let gallery = s.schema((
  submit-url: s.optional(s.nullable(str), default: none),
  entries: s.array-of(entry),
))
