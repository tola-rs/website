// Locale name, directory, route, and message schemas.

#import "@tola/address:0.0.0": output-of, route-of
#import "@tola/schema:0.0.0": dictionary-of, literal, map, non-empty, refine, schema, trim, union

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

/// Empty dictionaries describe extensible maps, such as per-page sidebar titles.
#let message-schema(reference) = {
  let message = refine(str, text => text.trim() != "", message: "message must contain text")
  if reference.len() == 0 { return dictionary-of(message) }
  let fields = (:)
  for (key, value) in reference {
    fields.insert(key, if type(value) == dictionary { message-schema(value) } else { message })
  }
  schema(fields)
}

/// Resolved locale fields; language identity passes through.
#let locale-schema(reference) = schema(
  (
    name: non-empty(trim(str)),
    directory: union(literal(""), directory-name),
    route: locale-route,
    messages: message-schema(reference),
  ),
  unknown: "keep",
)
