#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Built-in scripts",
  description: "Options and inputs for the bundled Nushell scripts.",
  order: 20,
))

#title()

- #link("/docs/reference/scripts/context/")[`context`] reads paths and settings supplied to a hook, module command, or initializer. Use `--json` from external scripts.
- #link("/docs/reference/scripts/image/")[`image`] reads image metadata and resizes images.
- #link("/docs/reference/scripts/diagnostic/")[`diagnostic`] renders diagnostics from JSON, including the output of `tola check --json`.

See #link("/docs/guide/tools/nushell/")[Nushell scripts] to write your own.
