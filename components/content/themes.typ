// Theme gallery: a compact Hexo-style grid with a client-side search.

#import "@tola/address:0.0.0": asset-url
#import "/components/icon.typ": icon
#import "/site/themes.typ": submit-url

#let _theme-card(theme, t) = {
  let search = theme.name + " " + theme.description + " " + theme.tags.join(" ")
  let card_attrs = (
    class: "group flex min-w-0 flex-col overflow-hidden border border-line bg-canvas transition-colors hover:border-[var(--accent)]",
    "data-theme-card": "",
    "data-search": search,
  )
  let media_attrs = (
    href: theme.demo,
    rel: "noreferrer",
    class: "relative block aspect-[16/10] overflow-hidden border-b border-line bg-[var(--icon-bg)]",
    "aria-label": t.preview + ": " + theme.name,
  )

  html.elem("article", attrs: card_attrs)[
    #html.elem("a", attrs: media_attrs)[
      #html.img(
        src: asset-url("/assets/themes/" + theme.screenshot),
        alt: theme.alt,
        class: "h-full w-full object-cover transition-transform duration-500 group-hover:scale-[1.025] group-focus-visible:scale-[1.025]",
        loading: "lazy",
      )
      #html.elem("span", attrs: (
        class: "absolute inset-0 flex items-center justify-center gap-2 bg-black/60 text-sm font-semibold text-white opacity-0 transition-opacity duration-200 group-hover:opacity-100 group-focus-visible:opacity-100 group-focus-within:opacity-100",
        "aria-hidden": "true",
      ))[
        #icon("eye")
        #t.preview
      ]
    ]
    #html.div(class: "flex flex-1 flex-col p-4")[
      #html.h3(class: "m-0 text-lg font-semibold leading-snug tracking-tight")[
        #html.a(href: theme.repo, rel: "noreferrer", class: "inline-flex items-center gap-1.5 text-accent no-underline hover:underline")[
          #theme.name
          #icon("arrow-up-right", class: "size-3.5")
        ]
      ]
      #html.p(class: "m-0 mt-1 text-sm")[
        #html.a(href: theme.demo, rel: "noreferrer", class: "inline-flex items-center gap-1 text-accent no-underline hover:underline")[
          #t.visit
          #icon("arrow-up-right", class: "size-3.5")
        ]
      ]
      #html.p(class: "m-0 mt-3 text-sm leading-relaxed text-muted", theme.description)
      #html.ul(class: "m-0 mt-auto flex list-none flex-wrap gap-x-3 gap-y-1 p-0 pt-3 text-sm text-muted")[
        #for tag in theme.tags [
          #html.li("#" + tag)
        ]
      ]
    ]
  ]
}

/// Full themes page body; the template adds the shell and container.
#let themes-gallery(page, themes) = {
  let t = page.locale.messages.themes
  let count = themes.len()
  let count_label = t.count.replace("{count}", str(count))

  html.elem("header", attrs: (class: "flex flex-wrap items-center gap-x-8 gap-y-4"))[
    #html.h1(class: "m-0 text-4xl font-extrabold tracking-[-0.04em] text-heading sm:text-5xl", t.title)
    #html.div(class: "ml-auto flex min-w-0 flex-1 flex-wrap items-center justify-end gap-4")[
      #html.elem("span", attrs: (
        class: "font-mono text-sm text-muted",
        "data-theme-count": "",
        "data-template": t.count,
        "aria-live": "polite",
      ), count_label)
      #html.elem("input", attrs: (
        type: "search",
        class: "h-11 w-full max-w-md border border-line bg-canvas px-4 text-sm text-ink placeholder:text-muted focus:border-[var(--accent)] focus:outline-none",
        placeholder: t.searchPlaceholder,
        "aria-label": t.searchLabel,
        "data-theme-search": "",
        autocomplete: "off",
      ))
      #html.a(href: submit-url, rel: "noreferrer", class: "inline-flex h-11 shrink-0 items-center justify-center gap-1.5 border border-line px-4 text-sm font-medium text-heading no-underline transition-colors hover:border-[var(--accent)] hover:text-accent")[
        #t.submit
        #icon("arrow-up-right", class: "size-3.5")
      ]
    ]
  ]

  html.elem("aside", attrs: (class: "mt-8 bg-surface px-5 py-4"))[
    #html.p(class: "m-0 text-sm font-semibold text-heading", t.warningTitle)
    #html.p(class: "m-0 mt-1 text-sm leading-relaxed text-muted", t.warning)
  ]

  html.elem("p", attrs: (
    class: "mt-6 text-sm text-muted",
    "data-theme-empty": "",
    hidden: "",
  ), t.empty)

  html.elem("div", attrs: (class: "mt-8 grid gap-x-8 gap-y-10 sm:grid-cols-2 docs:grid-cols-3"))[
    #for theme in themes {
      _theme-card(theme, t)
    }
  ]
}
