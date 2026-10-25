// Themes shown on /themes/. Entries are English-only; page copy lives in
// site/locales and is translated there.
//
// To add a theme:
// 1. Put a 16:10 WebP screenshot in static/web-assets/themes/.
// 2. Add a record below.
// 3. Keep repository and demo public.

/// Where the "Submit a theme" actions point.
#let submit-url = "https://github.com/tola-rs/website/issues/new?template=theme.yml"

/// Gallery entries.
#let themes = (
  (
    name: "NASAPunk",
    description: "A NASApunk-style blog theme for Tola. Posts are written in Typst; figures, diagrams and math render as inline SVG in the theme colours, by day and by night.",
    repo: "https://github.com/KKKZOZ/tola-theme-nasapunk",
    demo: "https://kkkzoz.github.io/tola-theme-nasapunk/",
    tags: ("blog", "dark mode", "diagrams", "search"),
    screenshot: "nasapunk.webp",
    alt: "NASAPunk home page split between light and dark themes",
  ),
)
