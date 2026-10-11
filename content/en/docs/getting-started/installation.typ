// Installation: obtaining and verifying the executable.

#import "@tola/source:0.0.0": tola-meta
#import "/site/info.typ": repository, version

#tola-meta((
  title: "Installation",
  description: "Install Tola.",
  order: 10,
))

#title()

Tola provides prebuilt binaries for macOS (Apple Silicon), Linux (x86_64 / aarch64), and Windows (x86_64) on GitHub Releases. Choose one of the three routes below.

= With Cargo

This needs a Rust toolchain on the machine:

```sh
cargo install --locked tola
```

`--locked` uses the dependencies resolved at release time instead of resolving new ones locally.

= From a release binary

Download the archive for your platform from the #link(repository + "/releases")[release page], unpack it, and add its directory to `PATH`. The current release is #raw("v" + version.tola).

== Windows

Download #raw("tola-" + version.tola + "-x86_64-pc-windows-msvc.zip"), unpack it, add its directory to `PATH`, and open a new terminal:

```sh
tola --version
```

= From the Nix flake

The repository provides a `flake.nix`, and prebuilt binaries are published at #link("https://tola.cachix.org")[tola.cachix.org]. Pin the input to the release you use, for example #raw("v" + version.tola).

= Verify

#raw(
  "$ tola --version\ntola " + version.tola + "\ntypst " + version.typst,
  lang: "sh",
  block: true,
)
