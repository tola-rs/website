#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "主题",
  description: "社区用 Tola 制作的主题。",
  layout: "wide",
  neighbors: false,
))

#import "/site/gallery/lib.typ": theme-gallery
#theme-gallery("zh-Hans")
