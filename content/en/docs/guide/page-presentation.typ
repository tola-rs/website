#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Images, icons, and code",
  description: "Generate responsive images on demand, manage SVG icon sets, and render highlighted code in light and dark themes.",
  order: 20,
))

#title()

= Thumbnails and responsive images

`@tola/image` generates derivative images on demand at build time and publishes them under `_tola/images/` (the returned URLs already include `base-path`), so the originals do not need to be declared in `[assets]`. The functions divide the work like this:

- `img` renders a responsive `<img>` directly, generating one file per entry in `widths` and letting `sizes` guide the browser.
- `image-srcset` returns `url`, `srcset`, `width`, and `height` for reuse in custom HTML or social sharing cards.
- `resize-image` generates a single derivative at one target size.
- `image-metadata` reads the width, height, format, and other metadata of the original.

```typst
#import "@tola/image:0.0.0": img, resize-image

// Responsive image (the page is 720px wide, 100vw on narrow screens)
#img(
  path("/images/cover.png"),
  alt: "Cover photo",
  widths: (480, 960),
  sizes: "(max-width: 760px) 100vw, 720px",
)

// Single-width thumbnail
#let thumb = resize-image(
  path("/images/cover.png"),
  width: 640,
  op: "fit-width",
  format: "webp",
)
#html.img(src: thumb.url, alt: "Cover thumbnail")
```

#callout[
  A string path is resolved from the directory of the current `.typ` file. If you wrap an image component that is called from other files, resolve the path at the original call site with `path(...)` before passing it in. To keep a vector image as a vector, use `image(...)` or publish the SVG as a static asset; the responsive helpers do not handle SVG, and only `resize-image` rasterises one when you explicitly request `webp`, `png`, or `jpg` output.
]

= SVG icon sets

`@tola/icon` reads icons from the collections configured under `[icons.collections]` (run `tola inspect icons` to list the available collections; this site's `docs` module registers Lucide as `ui`, browsable with `tola inspect icons ui --module docs`).

For example, save a hand-drawn triangle icon as `icons/ui/mark.svg`:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="currentColor" d="M12 3 22 21H2Z"/>
</svg>
```

Register that local directory in `tola.toml`:

```toml
[icons.collections.ui]
source-type = "local-svg-dir"
path = "icons/ui"
```

There are two common ways to render an icon in a page:

```typst
#import "@tola/icon:0.0.0": icon, icon-url

// 1. Inline SVG, following the text colour through currentColor
#icon("ui:mark") Important note

// 2. Published as a standalone image and referenced by URL (inherits no text colour)
#html.img(src: icon-url("ui:mark"), alt: "Triangle marker")
```

Use `icon-bytes` when the SVG should go through Typst's native `image(...)`. Mind the accessibility semantics: an icon that sits next to text keeps its decorative role with no extra label, while an icon-only button needs an accessible name for the control.

= Code highlighting with light and dark themes

Use `render-code` from `@tola/code` as a `show` rule for `raw` to emit token-highlighted code blocks in HTML. With a custom `html.html` shell, call `code-stylesheet()` in the `head` to load the theme stylesheet:

```typst
#import "@tola/code:0.0.0": code-stylesheet, code-themes, render-code

#document("index.html", format: "html", title: "Code sample")[
  #html.elem("html", attrs: (lang: "en", "data-theme": "dark"))[
    #html.head[
      #html.title[Code sample]
      #code-stylesheet()
    ]
    #html.body[
      #set raw(theme: code-themes.github)
      #show raw: render-code.with(dark-theme: code-themes.github-dark)
      #raw("let answer = 42;", lang: "rust", block: true)
    ]
  ]
]
```

A few notes:

- *Switching themes*: `raw.theme` sets the light or default theme, and the named argument `dark-theme` sets the theme used when the root element carries `data-theme="dark"`. The site owns the theme toggle and the wrapper styling.
- *Inline code highlighting*: backtick inline code carries no language tag. To highlight it too, write `#raw("let x = 1", lang: "rust")`.
- *Syntax definitions*: Tola bundles syntaxes for common languages such as `nu`. When a site supplies its own syntax file for the same language through `raw.syntaxes`, the site definition wins.

Full parameters: #link("/docs/reference/packages/image/")[`image`] · #link("/docs/reference/packages/icon/")[`icon`] · #link("/docs/reference/packages/code/")[`code`].
