#import "@tola/source:0.0.0": tola-meta
#import "@tola/module:0.0.0": get-module

#let (repository, versions) = get-module("docs").options
#let tag = "v" + versions.tola

#tola-meta((
  title: "Installation",
  description: "Download or compile a specific Tola release and verify your local setup.",
  order: 10,
))

#title()

These docs cover #raw(tag). Pick whichever method matches your environment.

= Prebuilt binaries

Download the archive for your platform from #link(repository + "/releases")[GitHub Releases]:

- macOS (Apple Silicon)
- Linux (x86_64 / ARM64)
- Windows (x86_64)

Extract it and add the directory containing `tola` (`tola.exe` on Windows) to `PATH`.

= Building from source

If you have checked out the matching source, install it from the repository root with Cargo:

```sh
cargo install --locked --path .
```

= Nix flake

The repository root provides a `flake.nix`. Pin the flake input to the tag or commit you want; prebuilt caches are hosted on #link("https://tola.cachix.org")[Cachix].

= Verifying the installation

Open a new terminal window and check the version output:

```sh
tola --version
```

The first line should read #raw("tola " + versions.tola), followed by the bundled Typst and Nushell versions. If the command is not found, check that the directory holding the executable is on `PATH` and reopen the terminal.

Next, go to #link("/docs/getting-started/first-site/")[Your first site] and create a project; for the complete command list, see the #link("/docs/getting-started/cli-usage/")[Command line] reference.
