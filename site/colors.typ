// The site's background colours, mirrored from the page themes, and the single
// ink that artwork drawn at build time can use on either theme.

#import "contrast.typ": balanced-grey

/// Page backgrounds, mirrored from `--bg` in `theme.css` and `components/docs.css`.
///
/// Chosen for comfort: light is not pure white; dark is lifted from black.
/// Equal contrast requires ink luminance = geometric mean of the backgrounds:
/// `sqrt((L_light + 0.05)(L_dark + 0.05)) - 0.05`.
/// `#f7f8f7` / `#1b1e1d` give `#7b7b7b` at 3.97:1. This passes 3:1 for
/// graphics, not 4.5:1 for text; SVG labels need per-theme inks.
#let background = (
  light: rgb("#f7f8f7"),
  dark: rgb("#1b1e1d"),
)

/// Balanced grey for one-colour artwork.
#let shared-ink = balanced-grey(background.light, background.dark).to-hex()
