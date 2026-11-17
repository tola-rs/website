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

Install the [Tola release](https://github.com/tola-rs/tola-ssg/releases) named in
`config/docs.toml` and use Node.js 24.2 or later.

```sh
tola docs setup
tola docs check
tola build
```

Run `tola dev` for live preview, `tola docs guide` for the authoring guide, or
`tola docs check && tola check` to check both the frontend and the site.

Pull requests and pushes to `main` build the site in GitHub Actions using the same
Tola release. Run **Deploy Site** from `main` with **Publish the verified build to
GitHub Pages** enabled to update the website.

## Reference pages

The `reference` hook generates the English and Chinese configuration, package, and script
references from the local executable's `tola help --format json` output.
