// Locale loading and source-to-locale lookup.

#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": join-route
#import "@tola/collection:0.0.0": index-by
#import "@tola/schema:0.0.0": dictionary-of, parse
#import "/schemas/locale.typ": locale-schema

/// Default route: root for the default language, lowercase tag otherwise.
#let default-route(language) = if language.tag == site.language.tag { "/" } else {
  join-route((lower(language.tag),))
}

// Load a locale module and apply directory/route defaults.
#let load-locale(language) = {
  import (language.tag + ".typ") as locale
  let definition = dictionary(locale)
  let directory = definition.at("directory", default: lower(language.tag))
  let route = definition.at("route", default: default-route(language))
  (
    ..language,
    name: definition.at("name", default: none),
    directory: directory,
    route: route,
    messages: definition.messages,
  )
}

#let configured-languages = if site.languages.len() == 0 { (site.language,) } else { site.languages }
#let definitions = index-by(configured-languages.map(load-locale), key: locale => locale.tag)
#let default-messages = definitions.at(site.language.tag).messages

/// Configured locales by canonical tag; `directory` is physical, `route` is decoded.
#let locales = parse(definitions, dictionary-of(locale-schema(default-messages)))
#let locales-by-directory = index-by(locales.values(), key: locale => locale.directory)

/// First physical directory of a content path.
#let source-directory(source) = {
  let parts = source.path.split("/")
  if parts.len() == 1 { none } else { parts.first() }
}

/// Locale for a source whose directory was validated.
#let source-locale(source) = locales-by-directory.at(source-directory(source))
