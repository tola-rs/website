#import "@tola/source:0.0.0": tola-meta
#import "@tola/module:0.0.0": get-module
#import "@tola/site:0.0.0": site
#import "@tola-modules/docs:0.0.0": home-capabilities, home-features, home-hero, logo-url

#let (repository, versions) = get-module("docs").options
#let license = site.options.license
#let title = "Your whole site is one Typst program"

#tola-meta((
  title: title,
  layout: "landing",
  description: "A programmable static site generator built on Typst Bundles. One Typst program organizes pages, feeds, and assets.",
))

#home-hero(
  [Your whole site is \ #html.span(class: "home-title-accent")[one Typst program]],
  "A Typst-based static site generator",
  (href: "/docs/getting-started/overview/", label: "Get started"),
  (href: repository, label: "View on GitHub"),
  [v#versions.tola · Typst #versions.typst · #link(license.url)[#license.name licensed]],
  logo-url(),
)

#home-capabilities("Typst capabilities", (
  (
    icon: "file-pen-line",
    title: "Content and templates",
    body: [Content, templates, and components share one language, so you reuse structure through functions, data, and style rules.],
  ),
  (
    icon: "square-function",
    title: "Math and diagrams",
    body: [Write equations directly in your text and build charts and commutative diagrams with Typst drawing packages.],
  ),
  (
    icon: "split",
    title: "One source, many outputs",
    body: [Arrange the same source file into several pages and let the root program decide the composition and output paths.],
  ),
  (
    icon: "blocks",
    title: "Typst package ecosystem",
    body: [Reuse community packages and built-in functions, combining drawing, data processing, and content components as needed.],
  ),
))


#home-features(
  "Extensions for static sites",
  (
    (
      icon: "monitor-play",
      title: "Preview and hot reload",
      body: [Saving a change rebuilds the site and prefers in-place browser updates, so your writing flow keeps going.],
      link: "Local preview",
      href: "/docs/getting-started/first-site/",
    ),
    (
      icon: "square-code",
      title: "Editor support",
      body: [Completion, hover documentation, go-to-definition, live diagnostics, syntax highlighting, and site preview.],
      link: "Set up your editor",
      href: "/docs/getting-started/cli-usage/",
    ),
    (
      icon: "notebook-tabs",
      title: "Content and navigation",
      body: [Write templates and components, and generate route hierarchies, previous/next navigation, page tables of contents, and backlinks.],
      link: "Organize your site",
      href: "/docs/guide/metadata-and-navigation/",
    ),
    (
      icon: "images",
      title: "Images and icons",
      body: [Resize, crop, and convert images at build time and generate responsive sizes, with a built-in customisable icon set.],
      link: "Work with images and icons",
      href: "/docs/guide/page-presentation/",
    ),
    (
      icon: "plug",
      title: "Build hooks",
      body: [Attach external tools to multi-stage build hooks and extend the site pipeline before compilation or after publication.],
      link: "Build hooks",
      href: "/docs/concepts/hooks/",
    ),
    (
      icon: "list-checks",
      title: "Broken-link and conflict checks",
      body: [Check local links, static resources, and page anchors, and stop missing targets and path conflicts before they ship.],
      link: "Check and build",
      href: "/docs/getting-started/cli-usage/",
    ),
    (
      icon: "rss",
      title: "Sharing and feeds",
      body: [Generate social sharing metadata along with standards-compliant RSS, Atom feeds, and a sitemap.],
      link: "Feeds and site metadata",
      href: "/docs/guide/publication/",
    ),
    (
      icon: "file-check",
      title: "Metadata validation",
      body: [Parse and validate page metadata with a schema, and catch missing fields and type errors early.],
      link: "Metadata validation",
      href: "/docs/concepts/metadata/",
    ),
  ),
  (),
)
