#import "@tola/source:0.0.0": tola-meta
#import "@tola/module:0.0.0": get-module

#let (repository, versions) = get-module("docs").options
#let tag = "v" + versions.tola

#tola-meta((
  title: "Installation",
  description: "Install Tola and check its version.",
  order: 10,
))

#title()

= Release binaries

These docs cover #raw(tag). Once released, download the archive for macOS (Apple Silicon), Linux (x86_64 or ARM64), or Windows (x86_64) from #link(repository + "/releases")[GitHub Releases]. Extract it and add the directory containing `tola` (`tola.exe` on Windows) to `PATH`.

= From source

Check out the version you want and run this from the source repository root.

```sh
cargo install --locked --path .
```

= Nix flake

Pin the repository flake to the tag or commit you want. Cached builds are available from #link("https://tola.cachix.org")[Cachix].

= Verify

Run `tola --version` in a new terminal. The first line should read #raw("tola " + versions.tola), followed by the bundled Typst and Nushell versions.

#link("/docs/getting-started/cli-usage/")[Command line] · #link("/docs/getting-started/first-site/")[Your first site]
