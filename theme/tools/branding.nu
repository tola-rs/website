use tola [get-hook get-module get-site image]

def read-art [module: record key: string] {
  let file = ($module.options | get --optional $key)
  if $file == null { return null }
  let field = $"modules.($module.name).options.($key)"
  if ($file | describe) != "string" or ($file | str trim | is-empty) {
    error make {msg: $"($field) must name an image relative to the site root"}
  }
  let root = (get-site).root
  let path = ($root | path join ($file | str trim --left --char '/') | path expand --no-symlink)
  if not ($path | str starts-with ($root + (char path_sep))) {
    error make {msg: $"($field) must stay inside the site"}
  }
  try {
    let bytes = (open --raw $path | into binary)
    {path: $path, bytes: $bytes, size: ($bytes | image metadata)}
  } catch {|failure|
    error make {msg: $"($field), ($file): ($failure.msg)"}
  }
}

def square [source: any] {
  $source != null and $source.size.width == $source.size.height
}

def save-art [stage: path name: string bytes: binary] {
  $bytes | save --raw ($stage | path join $name)
  {file: $name, digest: ($bytes | hash sha256), size: ($bytes | image metadata)}
}

def recover [output: path backup: path] {
  if ($backup | path exists) {
    if ($output | path exists) { rm --recursive $backup } else { mv $backup $output }
  }
}

def "main prepare" [] {
  let module = get-module
  let root = ((get-site).root | path join generated $module.name)
  let output = ($root | path join brand)
  let backup = ($root | path join .brand-previous)
  let stage = ((get-hook).temp-dir | path join brand)
  mkdir $root $stage
  recover $output $backup
  let logo = read-art $module logo
  let explicit = read-art $module favicon
  let favicon = if $explicit != null {
    if $logo != null and $explicit.path == $logo.path { $logo } else { $explicit }
  } else if (square $logo) { $logo } else { null }
  mut manifest = {}
  if $logo != null {
    let art = if $logo.size.format == "svg" {
      save-art $stage logo.svg $logo.bytes
    } else {
      let bytes = ($logo.bytes | image resize --width 960 --height 640 --op fit --format webp | into binary)
      save-art $stage logo.webp $bytes
    }
    $manifest = ($manifest | insert logo $art)
  }
  if $favicon != null {
    if $favicon.size.format == "svg" and (square $favicon) {
      let art = if $logo != null and $logo.path == $favicon.path {
        $manifest.logo
      } else { save-art $stage favicon.svg $favicon.bytes }
      $manifest = ($manifest | insert favicon $art)
    }
    for size in [32 180 512] {
      let bytes = ($favicon.bytes | image resize --width $size --height $size --op fill --format png | into binary)
      $manifest = ($manifest | insert $"favicon-($size)" (save-art $stage $"favicon-($size).png" $bytes))
    }
  }
  $manifest | to json | save --raw ($stage | path join manifest.json)
  if ($output | path exists) { mv $output $backup }
  try { mv $stage $output } catch {|failure|
    recover $output $backup
    error make {msg: $"Could not install generated/($module.name)/brand: ($failure.msg)"}
  }
  if ($backup | path exists) { rm --recursive $backup }
}

def "main publish" [] {
  let module = get-module
  let source = ((get-site).root | path join generated $module.name brand)
  let manifest = open ($source | path join manifest.json)
  let output = ((get-hook).output-dir | path join _tola-modules $module.name brand)
  mkdir $output
  for art in ($manifest | values | uniq-by file) {
    let bytes = (open --raw ($source | path join $art.file) | into binary)
    if ($bytes | hash sha256) != $art.digest {
      error make {msg: $"generated/($module.name)/brand/($art.file) changed after preparation; rebuild the branding"}
    }
    $bytes | save --raw ($output | path join $art.file)
  }
}

def main [] { help main }
