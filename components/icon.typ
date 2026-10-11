// Decorative icon; the enclosing control owns the accessible label.

#import "@tola/icon:0.0.0": icon as render-icon

/// Render `name` with class `ui-icon`.
/// - collection: declared icon collection; defaults to `lucide`.
/// - class: extra class on the icon.
#let icon(name, collection: "lucide", class: none) = render-icon(
  collection + ":" + name,
  attrs: (class: if class == none { "ui-icon" } else { "ui-icon " + class }),
)
