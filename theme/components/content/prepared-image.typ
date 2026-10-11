// Read a fixed image output prepared by the batch hook.

#import "@tola/address:0.0.0": output-url
#import "@tola/module:0.0.0": get-module
#import "@tola/site:0.0.0": project-path
#import "/settings.typ": options

#let _module = get-module()

/// URL, srcset and dimensions for an original selected by the batch hook.
#let prepared-image(source) = {
  assert(type(source) == path, message: "prepared-image() needs a resolved path() to the original file")
  assert(options.resize-images.enabled, message: "set modules." + _module.name + ".options.resize-images.enabled = true to prepare fixed image files")
  let manifest = json(project-path("generated/" + _module.name + "/images/manifest.json"))
  let key = manifest.keys().find(key => project-path(key) == source)
  assert(key != none, message: repr(source) + " has no batch output; check the images hook's inputs")
  let variants = manifest.at(key)
  let urls = variants.map(variant => output-url(variant.output) + "?h=" + variant.digest)
  let largest = variants.last()
  (
    url: urls.last(),
    width: largest.width,
    height: largest.height,
    srcset: variants.zip(urls).map(((variant, url)) => url + " " + str(variant.width) + "w").join(", "),
  )
}
