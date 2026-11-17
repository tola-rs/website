# Docs theme for Tola

A theme for writing documentation sites in Typst. It builds a sidebar and reading
order from the source tree and provides a table of contents, search, code highlighting,
and light and dark modes. Blog pages are available when the site uses them.

## Start a documentation site

Put the module in `theme/` and add this configuration to `tola.toml`.

```toml
[site]
title = "Acme documentation"

[build]
entry = { module = "docs" }

[modules.docs]
path = "theme"
```

Use `content/docs/getting-started.typ` for your first document.

```typst
#import "@tola/source:0.0.0": tola-meta
#tola-meta((title: "Getting started"))

#title()

Install the tools your project needs, then run your first build.
```

Put the home page at `content/index.typ`. Use ordinary Typst content and link to
`/docs/getting-started/`. Pages under `content/docs/` appear in the documentation
sidebar. Siblings without `order` sort by path. Pages with explicit `order` values
appear first. Give those pages unique positions within their group.

Run `tola docs setup` once to install the browser tools, then run `tola dev` or
`tola build`. The theme declares its Lucide interface collection in the module
manifest. Tola downloads and locks it with the site's dependencies. To use additional icon
collections in your own pages, declare them in the site's `[icons]` settings.

The alias `docs` determines both the command prefix and the Typst import
`@tola-modules/docs:0.0.0`. The site owns its content, configuration, artwork and
project hooks. The module owns routing, templates, and components. Use the public
module entry when importing components into content.

The default compiler font is Libertinus Serif. To use the bundled Noto Sans SC
font in Typst-rendered frames, select the module's font directory.

```toml
[typst.fonts]
modules = ["docs"]

[modules.docs.options]
font = "Noto Sans SC"
```

Run `tola docs check` to type-check the browser tools or `tola docs guide` to read
this guide.

## Options

Set project values under `[modules.docs.options]`:

| Option | Type | Default | Meaning |
| --- | --- | --- | --- |
| `repository` | string or absent | absent | Source repository linked from the header. |
| `site-repository` | string or absent | absent | Repository that owns the site, linked from the footer. |
| `logo` | path or absent | absent | Homepage logo source, relative to the site root. |
| `favicon` | path or absent | square `logo`, if supplied | Browser and home-screen icon source, relative to the site root. |
| `versions` | table of strings | `{}` | Tool versions shown in the footer. |
| `version-labels` | table of strings | `{}` | Display names for keys in `versions`. |
| `copyright` | table of strings | `{}` | Footer copyright: `years`, `holder`, `url`, `contributors`. |
| `docs-section` | string | `"docs"` | Top-level source directory and route for documentation. |
| `docs-groups` | array of strings | `[]` | Documentation group order. Unlisted groups sort last. |
| `nav-pages` | array of routes | `[]` | Additional header links, using page titles as labels. |
| `blog-feed` | `"auto"`, `"always"`, or `"off"` | `"auto"` | RSS per language with eligible posts, even when empty, or disabled. RSS needs a site origin. |
| `font` | string | `"Libertinus Serif"` | Compiler font for Typst-rendered content. |
| `typescript` | boolean | `true` | Run the TypeScript before-build hook. |
| `styles` | boolean | `true` | Compile Tailwind CSS from theme and content sources. |
| `search` | boolean | `true` | Run the Pagefind and search-preview generate-outputs hook. |
| `resize-images` | table | See below | Native image defaults and optional batch conversion. |
| `messages` | table | `{}` | Locale message overrides keyed by canonical language tag. |
| `locales` | table | `{}` | Per-language display name, source directory, and route overrides. |

```toml
[modules.docs.options]
repository = "https://github.com/example/site"
site-repository = "https://github.com/example/site-source"
versions = { Acme = "2.4" }
docs-section = "manual"
docs-groups = ["tutorials", "api"]
nav-pages = ["/about/"]
copyright = { years = "2025–2026", holder = "Example", url = "https://example.com" }

[modules.docs.options.messages.en.blog]
feed-description = "News from the example project."
```

## Languages

For one language, write directly under `content/` or use a language directory such
as `content/en/`. To enable several languages, list their tags in `[site]`.

```toml
[site]
language = "en"
languages = ["en", "zh-Hans", "fr"]

[modules.docs.options.locales.fr]
name = "Français"

[modules.docs.options.messages.fr.navigation]
docs = "Documentation"
```

With this config, `content/en/docs/setup.typ` publishes to `/docs/setup/`,
`content/zh-hans/docs/setup.typ` to `/zh-hans/docs/setup/`, and
`content/fr/docs/setup.typ` to `/fr/docs/setup/`. Matching paths are translations.
The language menu uses published translations or their nearest published parent.
Body links use the current translation when available, then the default language
or the first published translation.

English and Simplified Chinese interface messages ship with the theme. Other
languages use the English messages with any overrides you supply. Set `directory`
or `route` in a language's options to customize its source directory or URL prefix.
Set `directory = ""` for one language to keep its existing files directly under
`content/`. `messages.<tag>.docs.groups` and `messages.<tag>.docs.sidebar-titles`
can name grouping directories and shorten individual sidebar titles.

## Public writing API

Content imports the theme's public entry:

```typst
#import "@tola-modules/docs:0.0.0": (
  callout, code-group, current-page, docs-index, home-capabilities, home-features,
  home-hero, icon, image-srcset, img, logo-url, post-list, prepared-image, sections,
)
```

Page metadata is still declared with `@tola/source:0.0.0`'s `tola-meta`. The theme's
schema accepts `order`, `layout`, `title`, `description`, `link-previews`, `authors`, `tags`, `draft`,
`permalink`, `feed`, `sitemap`, `neighbors`, `feed-id`, `published`, `updated`,
`feed-summary`, and `feed-content`.

Use `current-page()`, `sections(language)`, and `posts(language)` inside `context`
to read the page data prepared by the site entry.

For a home or standalone page, `layout` defaults to `"reading"`. Use `"wide"` for
a wider page or `"landing"` for components such as `home-hero`. Documentation and
blog entries use their respective reading templates.

`icon`, `home-capabilities`, and `home-features` use the module's `ui` icons by default.
Each item's `icon` is a name such as `"book-open"`. Both components accept an
`icon:` function to select a different renderer. For a site-owned `brand`
collection declared in `[icons.collections.brand]`, bind the public icon helper.

```typst
#let brand-icon = icon.with(collection: "brand")
#home-capabilities("Features", (
  (icon: "book", title: "Documentation", body: [Read the project guide.]),
), icon: brand-icon)
```

The renderer receives the icon name and a named `class` argument for layout.

Body links to another published page preview its title and description. A
`link-previews` entry keyed by fragment ID supplies a title and can include a
description and signature. Set `same-page: true` on an entry to preview it from
its own page. Generated API member previews use this option.

## Build hooks

The theme declares these module hooks:

| Stage | Hook | Output |
| --- | --- | --- |
| `before-build` | `branding` | `generated/<alias>/brand` |
| `generate-outputs` | `branding` | `_tola-modules/<alias>/brand` |
| `before-build` | `images` | `generated/<alias>/images` |
| `before-build` | `typescript` | `generated/<alias>/typescript-output` |
| `generate-outputs` | `images` | `_tola-modules/<alias>/images` |
| `before-build` | `styles` | `generated/<alias>/styles/site.css` |
| `generate-outputs` | `search` | `_tola-modules/<alias>/pagefind`, `_tola-modules/<alias>/search-previews` |
| `generate-outputs` | `scripts` | `_tola-modules/<alias>/scripts` |

Tola's embedded Nushell runs the browser asset and search hooks. These hooks
need Node.js 24.2 or later and npm on `PATH`.
Install the locked dependencies with `tola docs setup`. `generated/` is a
build product and should be ignored.

## Assets

Set branding under `[modules.docs.options]`:

```toml
[modules.docs.options]
logo = "brand/logo.svg"
favicon = "brand/icon.svg"
```

Both paths are relative to the site root. The theme publishes the selected artwork
and derivatives. You can reuse one square image by setting `logo` alone. For a wide
or tall logo, supply a separate square `favicon` to get browser icons. An explicit
non-square `favicon` is center-cropped for the PNGs.

The homepage keeps SVG logos as vectors and fits raster logos within 960×640 pixels
as WebP. The branding hooks use Nu's native image commands to prepare and publish
the 32×32 favicon, 180×180 Apple touch icon, and 512×512 PNG,
plus the vector favicon if the source is a square SVG. `logo-url()`, `favicon-url()`,
and `favicon-png-url(px)` return URLs with the deployment base path. The PNG helper
accepts 32, 180, or 512. These helpers return `none` when
their artwork is absent. Pass `logo-url()` to `home-hero`. A `none` value renders a
text-only hero.

The hooks prepare a complete directory before replacing the previous generation.
Removing the options clears the generated artwork on the next successful build.
Keep `generated/` and the site's publish directory ignored by version control.

The module's `ui` icon collection is independent of site icon collections. To
replace it for this instance, supply a complete collection source in the site config.

```toml
[modules.docs.icons.collections.ui]
source-type = "local-svg-dir"
path = "icons/docs-ui"
```

This path starts at the site root. Supply the icon names used by the theme's
controls. Run `tola inspect icons ui --module docs` to inspect the selected collection.

Other project assets use the site's `[assets]` declarations. Theme assets publish
under `/_tola-modules/<alias>/`. The site bundle publishes the generated stylesheet.

## Images

`img` and `image-srcset` bind the native `@tola/image` functions to this module's
defaults. A literal source string resolves where the function is called. Each call
can override the defaults. Tola generates, caches and publishes the requested
derivatives under `_tola/images/`.

```typst
#import "@tola-modules/docs:0.0.0": img

#img("cover.png", alt: "Cover", widths: (480, 960),
  sizes: "(max-width: 720px) 100vw, 720px")
```

`cover.png` is beside the content file containing the call. Project-root strings,
resolved `path()` values and raw bytes are also accepted. When a custom wrapper
passes a source to another file, resolve it with `path()` at the original call
site first. `image-srcset` returns `url`, `srcset`, `width` and `height`.

Configure defaults for this module instance:

```toml
[modules.docs.options.resize-images]
format = "webp"
quality = 80
widths = []
background = ""
```

`format` accepts `webp`, `png` and `jpg`. Quality is 0–100 for WebP, 1–100 for
JPEG; PNG uses lossless encoding. An empty width list preserves dimensions.
Explicit widths preserve aspect ratios and can enlarge the source.
`background = ""` preserves transparency. An opaque `#RRGGBB` color composites
the image onto that background. JPEG needs a background for transparent originals.
A native call can use `quality: none` for lossless WebP or pass a Typst color as
`background`.

### Fixed batch outputs

Set `resize-images.enabled = true` to additionally convert the PNG, JPEG and
WebP originals under the site's `images/`. The batch hooks use the same format,
quality, widths and background settings.

```toml
[modules.docs.options.resize-images]
enabled = true
widths = [480, 960, 1280]
```

For `images/posts/cover.png`, this prepares `posts/cover-480.webp`,
`posts/cover-960.webp` and `posts/cover-1280.webp` under
`generated/docs/images/`. With an empty width list the filename is `posts/cover.webp`.
The module publishes these files under `/_tola-modules/docs/images/`.

Use `prepared-image` when a page needs those fixed outputs:

```typst
#import "@tola-modules/docs:0.0.0": prepared-image

#let photo = prepared-image(path("/images/posts/cover.png"))
#html.elem("img", attrs: (
  src: photo.url, srcset: photo.srcset, sizes: "100vw",
  width: str(photo.width), height: str(photo.height), alt: "Cover",
))
```

It reads the batch manifest and returns URL, srcset and dimensions. A selected
module resource can also use a generated file through `assets.replace`.

The batch defaults to disabled. Disabling it removes batch outputs from the next
publication. Calls to `prepared-image` and replacements using those files must
be removed or disabled with it. Native `img` calls request their own derivatives.

The cache keys include original bytes, conversion settings and the Tola executable's
digest. Cached bytes are verified before reuse. Preparation replaces the complete
generated directory, removes outputs for deleted originals, and recovers an
interrupted directory replacement on the next run.

## Theme source

`components/partials/` contains page-shell fragments such as the header, footer
and sidebar. `components/content/` contains body components. `templates/` combines
them with the selected source body. `lib.typ` exports the writing API; `site.typ`
chooses documents, feeds and the sitemap.
