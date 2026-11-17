use tola [get-hook get-module get-site]

def generated-path [name: string] {
  (get-site).root | path join "generated" (get-module).name $name
}

def install-if-changed [staged: path output: path] {
  if ($output | path exists) and (open --raw $staged) == (open --raw $output) { return }
  mv --force $staged $output
}

def "main bundle" [] {
  let root = (get-module).root
  let output = (generated-path "typescript-output")
  let stage = ((get-hook).temp-dir | path join "typescript-output")
  cd $root
  let entries = (glob 'typescript-sources/*.ts' --no-dir --no-symlink | sort)
  if ($entries | is-empty) {
    error make {msg: "No browser entry points in typescript-sources/"}
  }

  do --capture-errors {
    (^npm run --silent bundle -- ...$entries --bundle --minify --format=iife --platform=browser
      --target=chrome120,firefox128,safari17.4 $"--outdir=($stage)")
  } | ignore

  # Keep unchanged scripts in place and remove obsolete entry points.
  let names = ($entries | each {|entry| $"($entry | path parse | get stem).js" })
  mkdir $output
  for name in $names {
    install-if-changed ($stage | path join $name) ($output | path join $name)
  }
  cd $output
  let stale = (glob '*.js' --no-dir --no-symlink
    | where {|file| ($file | path basename) not-in $names })
  if ($stale | is-not-empty) { rm ...$stale }
}

def "main styles" [] {
  let module = get-module
  let site = get-site
  let output = (generated-path "styles" | path join "site.css")
  let entry = ($module.root | path join "styles" "site.css" | str replace --all '\' '/' | to json --raw)
  let temp = (get-hook).temp-dir
  let input = ($temp | path join "site.css")
  let staged = ($temp | path join "compiled.css")
  cd $site.root
  let excluded = ['.git/**' '.jj/**' '.tola/**' 'public/**' 'vendor/**' '**/node_modules/**' $"generated/($module.name)/brand/**"]
  let files = (glob '**/*.typ' --no-dir --exclude $excluded | sort)
  let sources = ($files | prepend ($site.content-root | path join '**/*.typ') | each {|file|
    let path = ($file | str replace --all '\' '/' | to json --raw)
    $'@source ($path);'
  })
  $sources | prepend $'@import ($entry);' | str join "\n" | save --raw $input

  do --capture-errors {
    ^npm --prefix $module.root run --silent styles -- --input $input --output $staged --minify
  } | ignore
  mkdir ($output | path dirname)
  install-if-changed $staged $output
}

def "main publish" [] {
  let output = ((get-hook).output-dir | path join "_tola-modules" (get-module).name "scripts")
  cd (generated-path "typescript-output")
  let scripts = (glob '*.js' --no-dir --no-symlink)
  if ($scripts | is-empty) {
    error make {msg: "No compiled browser scripts in typescript-output/"}
  }
  mkdir $output
  cp ...$scripts $output
}

def "main search" [] {
  let module = get-module
  let hook = get-hook
  let output = ($hook.output-dir | path join "_tola-modules" $module.name)
  let previews = ($module.root | path join "tools" "search-previews.ts")
  do --capture-errors {
    ^node $previews $hook.input-dir ($output | path join "search-previews")
  } | ignore
  do --capture-errors {
    ^npm --prefix $module.root run --silent index -- --site $hook.input-dir --output-path ($output | path join "pagefind")
  } | ignore
}

def main [] { help main }
