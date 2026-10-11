// Public writing API for pages that import `@tola-modules/docs:0.0.0`.
//
// The theme's own site program imports these modules directly; content should use this
// entry so the file layout inside the theme can change without touching content.

#import "components/assets.typ": (
  inline-script, pagefind-url, script-url, stylesheet-url,
)
#import "components/branding.typ": favicon-png-url, favicon-url, logo-url
#import "components/icon.typ": icon
#import "components/content/lib.typ": (
  callout, code-group, docs-index, heading-permalink, home-capabilities, home-features, home-hero, math-svg, post-byline,
  post-list, render-raw, image-srcset, img, prepared-image,
)
#import "site/blog.typ": posts
#import "components/content/reference.typ": reference-page
#import "site/docs.typ": sections
#import "site/pages.typ": current-page
