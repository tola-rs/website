// Define the English language name and interface messages consumed by locale loading.
// Other language files must provide the same message fields; directory/route use defaults.

#let name = "English"

#let messages = (
  navigation: (
    label: "Main navigation",
    docs: "Docs",
    blog: "Blog",
    skip: "Skip to content",
  ),
  footer: (
    source: "Website source",
    versions: "Documentation for",
    contributors-join: " and ",
    contributors: "contributors",
  ),
  languages: "Languages",
  repository: "GitHub",
  on-this-page: "On this page",
  search: (
    button: "Search",
    title: "Search this site",
    label: "Search in English",
    hint: "Search the English documentation and blog. Use the arrow keys to move through results.",
    placeholder: "Search documentation…",
    empty: "Type to search.",
    searching: "Searching…",
    count: "Matches in {count} pages",
    "none": "No results. Try another word.",
    error: "Search could not load. Check your connection and try again.",
    close: "Close",
    clear: "Clear search",
    details: "Details",
    navigate: "Navigate",
    select: "Select",
  ),
  heading: (permalink: "Link to {title}"),
  code: (
    label: "Code block",
    copy: "Copy code",
    copied: "Copied",
    error: "Could not copy. Select the code and copy it manually.",
  ),
  appearance: (
    switch-to-light: "Switch to light theme",
    switch-to-dark: "Switch to dark theme",
  ),
  docs: (
    navigation: "Documentation",
    previous: "Previous",
    next: "Next",
    index-separator: ": ",
    groups: (
      getting-started: "Getting started",
      concepts: "Concepts",
      guide: "Guide",
      reference: "Reference",
    ),
  ),
  blog: (
    title: "Blog",
    empty: "No blog pages yet.",
    published: "Published",
    updated: "Updated",
    rss: "Subscribe via RSS",
    back: "All blog posts",
    feed-description: "News and development notes from Tola.",
  ),
  not-found: (
    title: "Page not found",
    description: "The page you requested could not be found.",
  ),
)
