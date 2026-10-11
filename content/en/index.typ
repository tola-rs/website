#import "@tola/source:0.0.0": tola-meta
#import "/components/content/lib.typ": home-features, home-hero, home-typst, logo-url
#import "/site/info.typ": license, repository, version

#let title = "Your whole site is one Typst program"

#tola-meta((
  title: title,
  description: "A programmable static site generator built on Typst Bundles. One Typst program selects every page, feed, and asset.",
))

#home-hero(
  [Your whole site is \ #html.span(class: "home-title-accent")[one Typst program]],
  "A Typst-based static site generator",
  (href: "/docs/getting-started/overview/", label: "Start building"),
  (href: repository, label: "View on GitHub"),
  [v#version.tola · Typst #version.typst · #link(license.url)[#license.name licensed]],
  logo-url(),
)

#home-typst("Typst capabilities", (
  (
    icon: "file-pen-line",
    title: "Content and templates",
    body: [Write content, templates, and components in one language. Reuse them through functions, data, and style rules.],
  ),
  (
    icon: "square-function",
    title: "Math and diagrams",
    body: [Write equations directly in your text. Use Typst drawing packages for charts and commutative diagrams.],
  ),
  (
    icon: "split",
    title: "One source, many outputs",
    body: [Use the same content in several pages. Your root program decides how pages are composed and where they go.],
  ),
  (
    icon: "blocks",
    title: "Typst packages",
    body: [Reuse existing functions and packages for drawing, data processing, and content components.],
  ),
))


#home-features(
  "Extensions for static sites",
  (
    (
      icon: "monitor-play",
      title: "Preview and hot reload",
      body: [Changes appear instantly: automatic rebuilds, in-place updates where possible, without interrupting your editing flow.],
      link: "Local preview",
    ),
    (
      icon: "square-code",
      title: "Editor support",
      body: [Completion, hover documentation, go-to-definition, live diagnostics, syntax highlighting, and site preview.],
      link: "Set up your editor",
    ),
    (
      icon: "notebook-tabs",
      title: "Content and navigation",
      body: [Write templates and components; define route hierarchies, previous/next navigation, tables of contents, and backlinks.],
      link: "Organize your site",
    ),
    (
      icon: "images",
      title: "Images and icons",
      body: [Resize, crop, and convert images at build time; generate responsive sizes; use polished icon collections.],
      link: "Work with images and icons",
    ),
    (
      icon: "plug",
      title: "Build hooks",
      body: [A multi-stage hook system that plugs external tools into the build chain and extends what the site can do.],
      link: "Build hooks",
    ),
    (
      icon: "list-checks",
      title: "Broken links and conflicts",
      body: [Check local links, resources, and page anchors; catch missing targets and output path conflicts.],
      link: "Check and build",
    ),
    (
      icon: "rss",
      title: "Sharing and feeds",
      body: [Configure social previews and generate RSS, Atom, and a sitemap.],
      link: "Feeds and site metadata",
    ),
    (
      icon: "file-check",
      title: "Metadata validation",
      body: [Parse the metadata declared by each page, avoiding missing fields, type errors, and tedious conversions.],
      link: "Metadata validation",
    ),
  ),
  (),
)
