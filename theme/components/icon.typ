// Decorative icon; the enclosing control owns the accessible label.

#import "@tola/icon:0.0.0": icon as render-icon
#import "@tola/module:0.0.0": get-module

#let _classes(class) = if class == none { "ui-icon" } else { "ui-icon " + class }
#let _module-icon = render-icon.with(module: get-module().name)
#let ui-icon(name, class: none) = _module-icon("ui:" + name, attrs: (class: _classes(class),))

#let repository-icon(url, class: none) = ui-icon(
  if url.starts-with("https://github.com/") { "github" } else { "git-fork" },
  class: class,
)

/// Render `name` with class `ui-icon`.
/// - collection: a site collection name. Omit it to use the module's `ui` collection.
/// - class: extra class on the icon.
#let icon(name, collection: none, class: none) = {
  if collection == none {
    ui-icon(name, class: class)
  } else {
    render-icon(collection + ":" + name, attrs: (class: _classes(class),))
  }
}
