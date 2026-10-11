// Browser metadata and shared assets.

#import "@tola/code:0.0.0": code-stylesheet
#import "../assets.typ" as assets

/// HTML head with prepared metadata and shared resources.
/// `interactive: false` omits page scripts.
#let head(entries, interactive: true) = html.head[
  #for entry in entries { entry }
  #html.meta(name: "darkreader-lock")
  #html.script(assets.inline-script("preferences"))
  #code-stylesheet()
  #html.link(rel: "stylesheet", href: assets.stylesheet-url())
  #if interactive {
    for name in ("controls", "navigation", "search", "toc", "code", "prefetch") {
      html.script("", src: assets.script-url(name), defer: true)
    }
  }
]
