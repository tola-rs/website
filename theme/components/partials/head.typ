// Browser metadata and shared assets.

#import "@tola/code:0.0.0": code-stylesheet
#import "../assets.typ" as assets
#import "../branding.typ": favicon-links
#import "../../settings.typ": options

/// HTML head with prepared metadata and shared resources.
/// `interactive: false` omits page scripts.
#let head(entries, interactive: true) = html.head[
  #for entry in entries { entry }
  #for entry in favicon-links() { entry }
  #html.meta(name: "darkreader-lock")
  #if options.typescript { html.script(assets.inline-script("preferences")) }
  #code-stylesheet()
  #if options.styles { html.link(rel: "stylesheet", href: assets.stylesheet-url()) }
  #if interactive and options.typescript {
    let scripts = ("controls", "navigation", "toc", "code", "prefetch")
    if options.search { scripts.push("search") }
    for name in scripts {
      html.script("", src: assets.script-url(name), defer: true)
    }
  }
]
