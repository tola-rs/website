// Locale loading and source-to-locale lookup.

#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": join-route
#import "@tola/collection:0.0.0": index-by
#import "@tola/schema:0.0.0": dictionary-of, parse
#import "/schemas/locale.typ": locale-schema
#import "../../settings.typ": options
#import "en.typ" as english
#import "zh-Hans.typ" as simplified-chinese

#let _built-in = (en: english, "zh-Hans": simplified-chinese)

// Deep merge the project's message overrides into a locale's defaults.
#let _merge(base, override) = {
  if type(base) != dictionary or type(override) != dictionary { return override }
  let merged = (:)
  for (key, value) in base { merged.insert(key, value) }
  for (key, value) in override {
    merged.insert(key, if key in base { _merge(base.at(key), value) } else { value })
  }
  merged
}

/// Default route: root for the default language, lowercase tag otherwise.
#let default-route(language) = if language.tag == site.language.tag { "/" } else {
  join-route((lower(language.tag),))
}

// Apply project overrides to the closest available interface catalog.
#let load-locale(language) = {
  let script = language.script
  let family = if type(script) == str { language.lang + "-" + script } else { language.lang }
  let catalog = _built-in.at(language.tag, default: _built-in.at(family, default: none))
  let configured = options.locales.at(language.tag, default: (:))
  let overrides = options.messages.at(language.tag, default: (:))
  let translated = if catalog == none { (:) } else { catalog.messages }
  (
    ..language,
    name: configured.at("name", default: if catalog == none { language.tag } else { catalog.name }),
    directory: configured.at("directory", default: lower(language.tag)),
    route: configured.at("route", default: default-route(language)),
    messages: _merge(_merge(english.messages, translated), overrides),
  )
}

#let configured-languages = if site.languages.len() == 0 { (site.language,) } else { site.languages }

/// Configured locales by canonical tag; `directory` is physical, `route` is decoded.
#let locales = {
  let definitions = index-by(configured-languages.map(load-locale), key: locale => locale.tag)
  parse(definitions, dictionary-of(locale-schema(english.messages)))
}
#let _by-directory = index-by(locales.values(), key: locale => locale.directory)
#let _flat = if locales.len() == 1 { locales.values().first() } else { _by-directory.at("", default: none) }

/// Resolve a content-relative path's locale and directory prefix length.
#let source-location(path) = {
  let parts = path.split("/")
  let locale = if parts.len() > 1 { _by-directory.at(parts.first(), default: none) }
  if locale != none { return (locale: locale, prefix-length: 1) }
  if _flat != none { (locale: _flat, prefix-length: 0) }
}
