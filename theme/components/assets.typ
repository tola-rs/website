// Browser asset URLs. Scripts come from the before-build hook and are published
// by a generate-outputs hook.

#import "@tola/address:0.0.0": output-url
#import "@tola/hash:0.0.0": blake3, bytes-to-hex
#import "@tola/module:0.0.0": get-module
#import "@tola/site:0.0.0": project-path

#let _module = get-module()

#let _generated(name) = project-path(
  "generated/" + _module.name + "/" + name,
)

/// Logical output path for files this module generates.
#let output-name(name) = "_tola-modules/" + _module.name + "/" + name

// The generated file supplies the exact bytes published by the Bundle or hook.
#let _generated-url(source, output) = {
  let bytes = read(_generated(source), encoding: none)
  let hash = bytes-to-hex(blake3(bytes))
  output-url(output-name(output)) + "?h=" + hash
}

/// Stylesheet URL published by the site bundle.
#let stylesheet-url() = _generated-url("styles/site.css", "styles/site.css")

/// Compiled script URL; `name` is the basename without `.js`.
#let script-url(name) = _generated-url("typescript-output/" + name + ".js", "scripts/" + name + ".js")

/// Compiled script body for inline initialization.
#let inline-script(name) = read(_generated("typescript-output/" + name + ".js"))

/// Pagefind module URL.
#let pagefind-url() = output-url(output-name("pagefind/pagefind.js"))

/// Search preview URL for one page's output filename.
#let search-preview-url(output) = output-url(output-name("search-previews/" + output + ".json"))
