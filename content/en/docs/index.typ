// Documentation landing page.

#import "@tola/source:0.0.0": tola-meta
#import "@tola/address:0.0.0": output-url
#import "@tola-modules/docs:0.0.0": current-page
#import "@tola-modules/docs:0.0.0": sections

#tola-meta((
  title: "Documentation",
  description: "Install Tola and learn how its build model works.",
  order: 0,
))

#title()

#context {
  let page = current-page()
  for group in sections(page.locale.tag, omit: page.key) [
    = #group.title

    #for target in group.pages [
      - #link(output-url(target.output))[#target.meta.title]: #target.meta.description
    ]
  ]
}
