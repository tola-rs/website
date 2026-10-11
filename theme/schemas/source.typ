// Published sources must belong to one of the site's locales.

#import "@tola/schema:0.0.0": check, issue, schema
#import "/site/locales/lib.typ": locales, source-location

#let language-directories = locales.values().map(locale => locale.directory)

/// Source with a configured locale; other fields pass through.
#let source-schema = check(
  schema((path: str), unknown: "keep"),
  source => {
    if source-location(source.path) != none { return () }

    let expected = language-directories.map(name => "`" + name + "/`").join(", ")
    let message = "source `" + source.path + "` must be inside a configured language directory: " + expected
    (issue(message, path: ("path",)),)
  },
  on: ("path",),
)
