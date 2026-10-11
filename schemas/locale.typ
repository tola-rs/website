// Locale name, directory, route, and message schemas.

#import "@tola/address:0.0.0": output-of, route-of
#import "@tola/schema:0.0.0": map, non-empty, refine, schema, trim

/// One visible physical directory name.
#let directory-name = refine(
  str,
  name => {
    (name != "" and not name.starts-with(".") and not name.contains("/") and not name.contains("\\"))
  },
  message: "expected one visible directory name",
)

/// Decoded directory route ending in `/`.
#let locale-route = map(
  refine(str, route => route.ends-with("/"), message: "expected a directory route ending in `/`"),
  route => route-of(output-of(route)),
)

/// Message fields mirroring the default locale.
#let message-schema(reference) = {
  let fields = (:)
  for (key, value) in reference {
    fields.insert(key, if type(value) == dictionary { message-schema(value) } else {
      refine(str, text => text.trim() != "", message: "message must contain text")
    })
  }
  schema(fields)
}

/// Resolved locale fields; language identity passes through.
#let locale-schema(reference) = schema(
  (
    name: non-empty(trim(str)),
    directory: directory-name,
    route: locale-route,
    messages: message-schema(reference),
  ),
  unknown: "keep",
)
