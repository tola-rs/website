# Tola documentation site

This repository builds [tola.build](https://tola.build) from the `docs` theme module in
[`theme/`](theme/README.md).

## Layout

| Path | Contents |
| --- | --- |
| `content/` | English and Simplified Chinese pages. |
| `theme/` | The reusable documentation theme: site program, templates, components, schemas, locales, styles, TypeScript sources, and hooks. |
| `site/gallery/` | Rendering, data schema and translations for the community theme gallery. |
| `static/web-assets/` | Site assets, including gallery screenshots and its browser script. |
| `tola.toml` | Site metadata, build settings, the theme selection, and the list of included configuration files. |
| `config/docs.toml` | Theme options, version labels and site-specific translations. |
| `config/reference.toml` | Hook that generates the bilingual reference pages. |
| `config/gallery.toml` | Community theme entries and the submission URL. |

## Build

Use a local build of Tola v0.8.2-pre.3 with TOML `include` support.

```sh
tola docs setup
tola docs check
tola build
```

Run `tola dev` for live preview, `tola docs guide` for the authoring guide, or
`tola docs check && tola check` to check both the frontend and the site.

Until a Tola release with TOML `include` support is available, add the local build
with `git add -f public/`, commit it, then run **Deploy Site** with `source = local`.
The default `release` mode builds with the GitHub release selected in `config/docs.toml`.

## Reference pages

The `reference` hook generates the English and Chinese configuration, package, and script
references from the local executable's `tola help --format json` output.
