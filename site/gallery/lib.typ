// Theme cards and filtering controls for the gallery page.

#import "@tola/address:0.0.0": asset-url
#import "@tola/site:0.0.0": site
#import "@tola/schema:0.0.0": parse
#import "@tola-modules/docs:0.0.0": icon
#import "schema.typ": gallery
#import "messages.typ": messages

#let _theme-card(theme, t) = {
  let search = theme.name + " " + theme.description + " " + theme.tags.join(" ")
  let card_attrs = (
    class: "flex min-w-0 flex-col overflow-hidden border border-line bg-canvas transition-colors hover:border-[var(--accent)]",
    "data-theme-card": "",
    "data-search": search,
  )
  let media_attrs = (
    href: theme.demo,
    rel: "noreferrer",
    class: "group/preview relative block aspect-[16/10] overflow-hidden border-b border-line bg-[var(--icon-bg)] focus-visible:z-1 focus-visible:-outline-offset-3",
    "aria-label": t.preview + ": " + theme.name,
  )

  html.elem("article", attrs: card_attrs)[
    #html.elem("a", attrs: media_attrs)[
      #html.img(
        src: asset-url(theme.screenshot),
        alt: theme.alt,
        class: "h-full w-full object-cover motion-safe:transition-transform motion-safe:duration-500 motion-safe:group-hover/preview:scale-[1.025] motion-safe:group-focus-visible/preview:scale-[1.025]",
        loading: "lazy",
      )
      #html.elem("span", attrs: (
        class: "absolute inset-0 flex items-center justify-center gap-2 bg-black/60 text-sm font-semibold text-white opacity-0 motion-safe:transition-opacity motion-safe:duration-200 group-hover/preview:opacity-100 group-focus-visible/preview:opacity-100",
        "aria-hidden": "true",
      ))[
        #icon("eye")
        #t.preview
      ]
    ]
    #html.div(class: "flex flex-1 flex-col p-4")[
      #html.h2(class: "m-0 text-lg font-semibold leading-snug tracking-tight")[
        #html.a(
          href: theme.repo,
          rel: "noreferrer",
          class: "inline-flex items-center gap-1.5 text-accent no-underline hover:underline",
        )[
          #theme.name
          #icon("arrow-up-right", class: "size-3.5")
        ]
      ]
      #html.p(class: "m-0 mt-1 text-sm")[
        #html.a(
          href: theme.demo,
          rel: "noreferrer",
          class: "inline-flex items-center gap-1 text-accent no-underline hover:underline",
        )[
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

#let _gallery(t, themes, submit-url, interactive) = {
  let count = themes.len()
  let count_label = t.count.replace("{count}", str(count))

  html.elem("header", attrs: (class: "flex flex-wrap items-center gap-x-8 gap-y-4"))[
    #html.h1(class: "m-0 text-4xl font-extrabold tracking-[-0.04em] text-heading max-md:basis-full sm:text-5xl", t.title)
    #html.div(class: "flex min-w-0 flex-wrap items-center justify-between gap-x-4 gap-y-3 max-md:basis-full md:ml-auto md:flex-1 md:justify-end md:gap-y-4")[
      #if interactive {
        html.elem("input", attrs: (
          type: "search",
          class: "h-11 w-full border border-line bg-canvas px-4 text-sm text-ink placeholder:text-muted focus:border-accent focus-visible:-outline-offset-3 md:max-w-md",
          placeholder: t.searchPlaceholder,
          "aria-label": t.searchLabel,
          "data-theme-search": "",
          autocomplete: "off",
        ))
      }
      #html.elem(
        "span",
        attrs: (
          class: "font-mono text-sm text-muted md:order-first",
          "data-theme-count": "",
          "data-template": t.count,
          "aria-live": "polite",
        ),
        count_label,
      )
      #if submit-url != none {
        html.a(
          href: submit-url,
          rel: "noreferrer",
          class: "inline-flex h-11 shrink-0 items-center justify-center gap-1.5 border border-line px-4 text-sm font-medium text-heading no-underline transition-colors hover:border-[var(--accent)] hover:text-accent",
        )[
          #t.submit
          #icon("arrow-up-right", class: "size-3.5")
        ]
      }
    ]
  ]

  html.elem("aside", attrs: (class: "mt-8 bg-surface px-5 py-4"))[
    #html.p(class: "m-0 text-sm font-semibold text-heading", t.warningTitle)
    #html.p(class: "m-0 mt-1 text-sm leading-relaxed text-muted", t.warning)
  ]

  let empty-attrs = (class: "mt-6 text-sm text-muted", "data-theme-empty": "")
  if count > 0 { empty-attrs.insert("hidden", "") }
  html.elem("p", attrs: empty-attrs, t.empty)

  html.elem("div", attrs: (class: "mt-8 grid gap-x-8 gap-y-10 sm:grid-cols-2 docs:grid-cols-3"))[
    #for theme in themes {
      _theme-card(theme, t)
    }
  ]
}

/// Render this site's community themes in the requested language.
#let theme-gallery(language, interactive: true) = {
  let data = parse(site.options.theme-gallery, gallery)
  html.section(class: "not-prose-defaults")[
    #_gallery(messages.at(language), data.entries, data.submit-url, interactive)
  ]
  if interactive {
    html.script("", src: asset-url("/assets/scripts/theme-gallery.js"), defer: true)
  }
}
