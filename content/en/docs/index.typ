// Documentation landing page.

#import "@tola/source:0.0.0": tola-meta
#import "@tola/address:0.0.0": output-url
#import "@tola-modules/docs:0.0.0": current-page, sections

#tola-meta((
  title: "Documentation",
  description: "Build your first Tola site, organize content, write modules, and deploy it.",
  order: 0,
))

#title()

Tola builds the entire site in Typst: content, templates, routes, and build output are all governed by one program. If you are new, start with #link("/docs/getting-started/overview/")[Overview] and #link("/docs/getting-started/first-site/")[Your first site]. When you need a specific field or function signature, go straight to #link("/docs/reference/overview/")[Reference].

#let _reference-roots = (
  "/docs/reference/overview/",
  "/docs/reference/config/",
  "/docs/reference/packages/",
  "/docs/reference/scripts/",
)

#context {
  let page = current-page()
  for group in sections(page.locale.tag, omit: page.key) [
    #let targets = if group.pages.any(item => item.key.starts-with("/docs/reference/")) {
      group.pages.filter(item => item.key in _reference-roots)
    } else {
      group.pages
    }
    = #group.title

    #for target in targets [
      - #link(output-url(target.output))[#target.meta.title]: #target.meta.description
    ]
  ]
}
