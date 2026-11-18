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

Pull requests build and check the site in GitHub Actions. Pushes to `main` also
publish a successful build to GitHub Pages. To redeploy manually, run **Deploy Site**
from `main` with **Publish the verified build to GitHub Pages** enabled.

## Theme submissions

After reviewing a theme, comment `/accept-theme` on its issue. The bot prepares
the gallery changes and replies with a link to open a PR. Add a short description
after the command to set the screenshot’s alt text. If needed, attach the screenshot
on a new line in the comment. Merge the PR to publish the entry.

## Reference pages

The `reference` hook generates the English and Chinese configuration, package, and script
references from the local executable's `tola help --format json` output.
