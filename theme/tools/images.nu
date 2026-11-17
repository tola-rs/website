use tola [get-hook get-module get-site image]

def settings [module: record] {
  let options = $module.options.resize-images
  let field = $"modules.($module.name).options.resize-images"
  if not (($options | describe) | str starts-with "record") {
    error make {msg: $"($field) must be a table"}
  }
  if $options.format not-in ["webp" "png" "jpg"] {
    error make {msg: $"($field).format must be webp, png or jpg"}
  }
  if ($options.quality | describe) != "int" or $options.quality < 0 or $options.quality > 100 {
    error make {msg: $"($field).quality must be an integer from 0 to 100"}
  }
  if $options.format == "jpg" and $options.quality == 0 {
    error make {msg: $"($field).quality must be at least 1 for jpg"}
  }
  if ($options.background | describe) != "string" or ($options.background != "" and $options.background !~ '^#[0-9a-fA-F]{6}$') {
    error make {msg: $"($field).background must be empty or an opaque #RRGGBB color"}
  }
  if not (($options.widths | describe) | str starts-with "list") {
    error make {msg: $"($field).widths must be a list of positive integer widths"}
  }
  for width in $options.widths {
    if ($width | describe) != "int" or $width <= 0 {
      error make {msg: $"($field).widths must contain positive integers"}
    }
  }
  $options | update widths ($options.widths | sort | uniq)
}

def cached-image [path: path] {
  try {
    let digest = (open --raw $"($path).sha256" | str trim)
    let bytes = (open --raw $path | into binary)
    if ($bytes | hash sha256) == $digest { {bytes: $bytes, digest: $digest} } else { null }
  } catch { null }
}

def store-image [path: path encoded: record<bytes: binary, digest: string>] {
  let temp = $"($path).partial"
  $encoded.bytes | save --raw --force $temp
  $encoded.digest | save --raw --force $"($temp).sha256"
  mv --force $temp $path
  mv --force $"($temp).sha256" $"($path).sha256"
}

def encode-variant [source: binary recipe: record cache_file: path relative: path] {
  let cached = cached-image $cache_file
  if $cached != null { return ($cached | insert cached true) }

  let bytes = (try {
    $source | image resize ...$recipe | into binary
  } catch {|failure|
    error make {msg: $"images/($relative), width ($recipe.width): ($failure.msg)"}
  })
  let variant = {bytes: $bytes, digest: ($bytes | hash sha256)}
  store-image $cache_file $variant
  $variant | insert cached false
}

def recover [output: path backup: path] {
  if not ($backup | path exists) { return }
  if ($output | path exists) { rm --recursive $backup } else { mv $backup $output }
}

def "main prepare" [] {
  let module = get-module
  let options = settings $module
  let hook = get-hook
  let root = ("generated" | path join $module.name)
  let output = ($root | path join "images")
  let backup = ($root | path join ".images-previous")
  let stage = ($root | path join ".images-next")
  mkdir $root
  # A prior run may have stopped after moving the old output aside.
  recover $output $backup
  if ($stage | path exists) { rm --recursive $stage }
  mkdir $stage

  let cache = ($hook.cache-dir | path join "images")
  mkdir $cache
  let encoder = (open --raw $env.TOLA_EXECUTABLE | hash sha256)
  let resize = {op: "fit-width", format: $options.format, quality: $options.quality}
  let resize = if $options.background == "" { $resize } else { $resize | insert background $options.background }
  let source_dir = ("images" | path expand)
  let site_root = (get-site).root
  let output_prefix = (["_tola-modules" $module.name "images"] | str join "/")
  let sources = (glob 'images/**/*' --no-dir | sort)
  mut manifest = {}
  mut encoded_count = 0
  mut cached_count = 0
  for source in $sources {
    let relative = ($source | path relative-to $source_dir)
    let parts = ($relative | path parse)
    if ($parts.extension | str lowercase) not-in ["png" "jpg" "jpeg" "webp"] { continue }
    let bytes = (open --raw $source | into binary)
    let source_digest = ($bytes | hash sha256)
    let original = (try { $bytes | image metadata } catch {|failure|
      error make {msg: $"images/($relative): ($failure.msg)"}
    })
    if $original.has-alpha and $options.format == "jpg" and $options.background == "" {
      error make {msg: $"images/($relative) has transparency; set modules.($module.name).options.resize-images.background to an opaque #RRGGBB color for jpg"}
    }
    let use_original_width = ($options.widths | is-empty)
    let widths = if $use_original_width { [$original.width] } else { $options.widths }
    mut variants = []
    for width in $widths {
      let suffix = if $use_original_width { "" } else { $"-($width)" }
      let path = ([$parts.parent $"($parts.stem)($suffix).($options.format)"] | path join)
      let target = ($stage | path join $path)
      if ($target | path exists) {
        error make {msg: $"images/($relative) produces duplicate output ($path); rename one of the source images"}
      }
      let recipe = ($resize | insert width $width)
      let key = ({source: $source_digest, resize: $recipe, encoder: $encoder, revision: 1}
        | to json --raw | hash sha256)
      let cache_file = ($cache | path join $"($key).($options.format)")
      let encoded = (encode-variant $bytes $recipe $cache_file $relative)
      if $encoded.cached {
        $cached_count += 1
      } else {
        $encoded_count += 1
      }
      let dimensions = ($encoded.bytes | image metadata)
      mkdir ($target | path dirname)
      $encoded.bytes | save --raw $target
      let path = ($path | path split | str join "/")
      $variants = ($variants | append {
        path: $path,
        output: ($output_prefix + "/" + $path),
        width: $dimensions.width, height: $dimensions.height,
        digest: $encoded.digest
      })
    }
    let name = ($source | path relative-to $site_root | path split | str join "/")
    $manifest = ($manifest | merge {($name): $variants})
  }
  $manifest | to json | save --raw ($stage | path join "manifest.json")

  if ($output | path exists) { mv $output $backup }
  try { mv $stage $output } catch {|failure|
    recover $output $backup
    error make {msg: $"Could not install generated/($module.name)/images: ($failure.msg)"}
  }
  if ($backup | path exists) { rm --recursive $backup }
  print $"Images: ($encoded_count) encoded, ($cached_count) cached"
}

def "main publish" [] {
  let module = get-module
  let source = ("generated" | path join $module.name "images")
  let output = (get-hook).output-dir
  let manifest = (open ($source | path join "manifest.json"))
  mkdir ($output | path join "_tola-modules" $module.name "images")
  for variants in ($manifest | values) {
    for variant in $variants {
      let target = ($output | path join $variant.output)
      let bytes = (open --raw ($source | path join $variant.path) | into binary)
      if ($bytes | hash sha256) != $variant.digest {
        error make {msg: $"generated/($module.name)/images/($variant.path) changed after preparation; build the images again"}
      }
      mkdir ($target | path dirname)
      $bytes | save --raw $target
    }
  }
}

def main [] { help main }
