// Browser asset URLs. Raster favicons exist at 32, 180, and 512 px.

#import "@tola/address:0.0.0": asset-url, output-url

/// Stylesheet URL.
#let stylesheet-url() = output-url("assets/styles/site.css")

/// Compiled script URL; `name` is the basename without `.js`.
#let script-url(name) = asset-url("/assets/typescript-output/" + name + ".js")

/// Compiled script body for inline initialization.
#let inline-script(name) = read("/static/web-assets/typescript-output/" + name + ".js")

/// Pagefind module URL.
#let pagefind-url() = output-url("assets/pagefind-search/pagefind.js")

/// Transparent logo URL.
#let logo-url() = asset-url("/assets/logo/logo.svg")

/// Square favicon URL.
#let favicon-url() = asset-url("/assets/logo/favicon.svg")

/// Square favicon PNG at `px`.
#let favicon-png-url(px) = asset-url("/assets/logo/favicon-" + str(px) + ".png")
