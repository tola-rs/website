// Native image functions bound to this module instance's defaults.

#import "@tola/image:0.0.0" as images
#import "/settings.typ": options

#let defaults = (
  format: options.resize-images.format,
  quality: options.resize-images.quality,
  widths: if options.resize-images.widths.len() == 0 { auto } else { options.resize-images.widths },
  background: if options.resize-images.background == "" { none } else { rgb(options.resize-images.background) },
)

// Binding arguments preserves the native function's caller-relative source paths.
#let img = images.img.with(..defaults)
#let image-srcset = images.image-srcset.with(..defaults)
