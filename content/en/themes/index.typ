#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Themes",
  description: "Community themes for Tola.",
  layout: "wide",
  neighbors: false,
))

#import "/site/gallery/lib.typ": theme-gallery
#theme-gallery("en")
