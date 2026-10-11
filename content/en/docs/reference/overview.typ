#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Reference",
  description: "Look up settings, package signatures, and built-in script options.",
  order: 0,
))

#title()

= Offline help

#table(
  columns: (auto, 1fr),
  table.header([What], [Command]),
  [CLI flags], [`tola build --help`],
  [Configuration], [`tola help config`],
  [Packages], [`tola help package`],
  [Scripts], [`tola help scripts`],
  [Build settings], [`tola help "[build]"`],
  [Functions], [`tola help "@tola/address" output-of output-url`],
  [Script options], [`tola help "@tola-scripts/image" resize`],
)

Use `tola help -i` to browse. Right arrow expands a section, `/` searches, and Enter opens a result. Add `--lang zh` for Simplified Chinese. Use `--no-pager` for direct terminal output or `--format markdown` to copy the page.

`tola help --format json --pretty "@tola/image"` returns structured signatures, parameters, examples, and related entries.

= Agent Skill

== Terminal use

```sh
tola skill --list
tola skill writing math --all
tola skill site assets files
tola skill modules theme customization
```

`--list` lists topics. Give the topic path after `tola skill`. `--all` includes its children.

== Export a guide

```sh
tola skill --output tola-authoring.md
tola skill modules --all --output module-authoring.md
```

The first command exports the whole guide. The second exports the module chapters. Tola creates missing directories and preserves existing files.

= Online reference

Browse #link("/docs/reference/config/")[Configuration], #link("/docs/reference/packages/")[Built-in packages], and #link("/docs/reference/scripts/")[Built-in scripts].
