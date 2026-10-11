// Homepage sections.

#import "@tola/site:0.0.0": site
#import "../icon.typ": icon

#let _more-link(href, label) = link(href)[#html.span(label)#icon("arrow-right")]

#let _feature-link(feature) = {
  let href = feature.at("href", default: none)
  let label = feature.at("link", default: none)
  if href != none [
    #html.div(class: "home-more mt-3 text-sm font-medium")[
      #_more-link(href, label)
    ]
  ] else if label != none [
    #html.div(class: "mt-3 text-sm font-medium text-muted")[#label]
  ]
}

#let _section-heading(title) = html.h2(
  class: "m-0 mb-6 text-xl font-semibold leading-snug tracking-tight text-heading sm:text-2xl",
  title,
)

/// Hero: title, lead, actions, meta, and mark.
#let home-hero(
  title,
  lead,
  primary,
  secondary,
  meta,
  logo,
) = html.section(class: "home-hero")[
  #html.div(
    class: "mx-auto grid max-w-page items-center gap-10 px-5 pt-8 pb-5 sm:px-8 md:grid-cols-[minmax(0,1.04fr)_minmax(0,0.96fr)] md:gap-14 md:pt-10 md:pb-3",
  )[
    #html.div(class: "min-w-0")[
      #html.p(class: "home-brand m-0 font-[750] leading-[1.02] tracking-[-0.04em] text-[var(--brand)]", site.title)
      #html.h1(class: "home-title m-0 text-heading font-extrabold", title)
      #html.p(class: "m-0 mt-6 text-base leading-relaxed text-muted sm:text-lg", lead)
      #html.div(class: "home-actions mt-8 flex flex-wrap items-center gap-3")[
        #link(primary.href)[
          #html.span(
            class: "home-primary inline-flex min-h-11 items-center justify-center gap-2 rounded-sm px-4 py-3 text-sm font-semibold leading-none transition-colors sm:px-5",
          )[
            #primary.label
            #icon("arrow-right")
          ]
        ]
        #link(secondary.href)[
          #html.span(
            class: "home-secondary inline-flex min-h-11 items-center justify-center gap-2 rounded-sm border border-line px-4 py-3 text-sm font-medium leading-none text-heading transition-colors sm:px-5",
          )[
            #icon("github", collection: "simple-icons")
            #secondary.label
          ]
        ]
      ]
      // data-pagefind-ignore has no typed counterpart.
      #html.elem(
        "p",
        attrs: (class: "home-meta m-0 mt-5 font-mono text-xs leading-relaxed text-muted", "data-pagefind-ignore": ""),
        meta,
      )
    ]
    #html.div(class: "home-mark flex justify-center")[
      #html.img(
        class: "m-0 h-55 w-auto max-w-full select-none sm:h-65 md:h-80",
        src: logo,
        alt: "",
      )
    ]
  ]
]

/// Capabilities strip; items supply icon, title, and body.
#let home-typst(title, items) = html.section(class: "home-typst")[
  #html.div(class: "mx-auto max-w-page px-5 py-6 sm:px-8")[
    #_section-heading(title)
    #html.div(class: "grid gap-x-8 gap-y-7 sm:grid-cols-2 docs:grid-cols-4")[
      #for item in items [
        #html.article(class: "min-w-0")[
          #html.div(class: "flex items-center gap-2.5 text-accent")[
            #icon(item.icon, class: "home-feature-icon size-5")
            #html.h3(
              class: "m-0 text-sm font-semibold leading-snug tracking-normal text-heading",
              item.title,
            )
          ]
          #html.p(class: "home-capability-body m-0 mt-2.5 text-sm leading-relaxed text-muted", item.body)
        ]
      ]
    ]
  ]
]

/// Linked feature directory.
#let home-features(title, features, links) = html.section(class: "home-features")[
  #html.div(class: "mx-auto max-w-page px-5 pt-8 sm:px-8 md:pt-10")[
    #_section-heading(title)
    #for row in features.chunks(2) [
      #html.div(class: "grid md:grid-cols-2 md:gap-x-12 md:border-t md:border-line")[
        #for feature in row [
          #html.article(class: "min-w-0 border-t border-line py-5 md:border-t-0")[
            #html.div(class: "flex items-center gap-3.5 text-accent")[
              #icon(feature.icon, class: "home-feature-icon size-5")
              #html.h3(
                class: "m-0 text-base font-semibold leading-snug tracking-normal text-heading",
                feature.title,
              )
            ]
            #html.p(class: "m-0 mt-2 text-sm leading-relaxed text-muted", feature.body)
            #_feature-link(feature)
          ]
        ]
      ]
    ]
    #if links.len() > 0 [
      #html.nav(class: "border-t border-line py-5", aria-label: title)[
        #html.ul(class: "m-0 flex list-none flex-wrap gap-x-8 gap-y-3 p-0 text-sm font-medium")[
          #for item in links [
            #html.li(class: "home-more m-0 p-0")[
              #_more-link(item.href, item.label)
            ]
          ]
        ]
      ]
    ]
  ]
]
