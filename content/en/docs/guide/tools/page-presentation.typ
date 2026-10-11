#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Images, icons, and code",
  description: "Generate responsive images, SVG icons, and highlighted code.",
  order: 10,
))

#title()

= Images

`image-metadata` reads dimensions and format. `resize-image` publishes one derivative. Use `image-srcset` or `img` for responsive images. The original can stay outside the asset directory.

Save an image as `images/cover.png` and put this in a content page.

```typst
#import "@tola/image:0.0.0": resize-image

#let cover = resize-image(
  path("/images/cover.png"),
  width: 640,
  op: "fit-width",
  format: "webp",
)
#html.img(src: cover.url, alt: "Cover photo")
```

The returned URL includes the deployment prefix. Use `img` with suitable `sizes` to let the browser pick a width.

= Icons

`@tola/icon` reads collections in `[icons.collections]`. Run `tola inspect icons` to list collections. This site's `docs` module provides Lucide as `ui`. List its icons with `tola inspect icons ui --module docs` and render one with `icon("ui:rocket", module: "docs")`.

For a local collection, save this as `icons/ui/mark.svg`.

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="currentColor" d="M12 3 22 21H2Z"/>
</svg>
```

Register the directory in `tola.toml`.

```toml
[icons.collections.ui]
source-type = "local-svg-dir"
path = "icons/ui"
```

The first call inlines the SVG so it can inherit text color. The second publishes it as a separate image.

```typst
#import "@tola/icon:0.0.0": icon, icon-url

#icon("ui:mark") Important

#html.img(src: icon-url("ui:mark"), alt: "Triangle marker")
```

`icon-bytes` returns SVG bytes for Typst's `image`. Give an icon-only control an accessible name.

= Code

Typst exports raw code blocks to HTML. Tola loads bundled syntax definitions for matching languages, including `nu`. A matching definition in `raw.syntaxes` takes precedence.

Use `render-code` for theme-specific colors. In a custom HTML shell, add `code-stylesheet()` to the head.

Use this as `site.typ` in a test site. Run `tola dev`, then change `data-theme` to `"light"` to compare the colors.

```typst
#import "@tola/code:0.0.0": code-stylesheet, code-themes, render-code

#document("index.html", format: "html", title: "Code example")[
  #html.elem("html", attrs: (lang: "en", "data-theme": "dark"))[
    #html.head[
      #html.title[Code example]
      #code-stylesheet()
    ]
    #html.body[
      #set raw(theme: code-themes.github)
      #show raw: render-code.with(dark-theme: code-themes.github-dark)
      #raw("let answer = 42;", lang: "rust", block: true)
    ]
  ]
]

#document("404.html", format: "html")[Page not found.]
```

`raw.theme` sets the primary palette. `dark-theme` sets the dark palette. The show rule passes the highlighted `raw` element to `render-code`.

#link("/docs/reference/packages/image/")[`image`] · #link("/docs/reference/packages/icon/")[`icon`] · #link("/docs/reference/packages/code/")[`code`]
