#import "@tola/source:0.0.0": tola-meta
#import "/site/pages.typ": current-page
#import "/site/themes.typ": themes
#import "/components/content/themes.typ": themes-gallery

#tola-meta((
  title: "Themes",
  description: "Community themes for Tola.",
  neighbors: false,
))

#context {
  let page = current-page()
  themes-gallery(page, themes)
}
