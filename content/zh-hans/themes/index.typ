#import "@tola/source:0.0.0": tola-meta
#import "/site/pages.typ": current-page
#import "/site/themes.typ": themes
#import "/components/content/themes.typ": themes-gallery

#tola-meta((
  title: "主题",
  description: "社区用 Tola 制作的主题。",
  neighbors: false,
))

#context {
  let page = current-page()
  themes-gallery(page, themes)
}