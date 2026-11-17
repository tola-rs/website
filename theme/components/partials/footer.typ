// Footer credits and versions.

#import "../../settings.typ": copyright, options, site-repository, versions
#import "../icon.typ": repository-icon, ui-icon

#let _link-or-text(target, text) = if target == none { text } else { link(target, text) }

#let _copyright-line(messages) = {
  if copyright.len() == 0 { return }
  let years = copyright.at("years", default: none)
  let holder = copyright.at("holder", default: none)
  let holder-url = copyright.at("url", default: none)
  let contributors = copyright.at("contributors", default: none)
  html.p(class: "footer-copyright")[
    #ui-icon("copyright")
    #html.span[
      #if years != none [#years — ]
      #if holder != none [#_link-or-text(holder-url, holder) ]
      #if contributors != none [
        #messages.contributors-join #link(contributors, messages.contributors)
      ]
    ]
  ]
}

#let _versions-line(messages) = {
  if versions.len() == 0 { return }
  let entries = versions.pairs().map(((key, version)) => options.version-labels.at(key, default: key) + " " + version)
  html.p(class: "footer-versions")[
    #ui-icon("book-open", class: "footer-icon")
    #messages.versions
    #entries.join(" · ")
  ]
}

/// Footer credits, tool versions, and repository link.
#let footer(messages) = if site-repository != none or versions.len() > 0 or copyright.len() > 0 {
  html.elem("footer", attrs: (
    class: "site-footer",
    "data-pagefind-ignore": "",
  ))[
    #html.div(class: "footer-inner")[
      #if site-repository != none [
        #html.p(class: "footer-source")[
          #link(site-repository)[
            #repository-icon(site-repository, class: "footer-icon")
            #messages.source
          ]
        ]
      ]
      #_versions-line(messages)
      #_copyright-line(messages)
    ]
  ]
}
