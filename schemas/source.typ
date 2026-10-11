// Published sources must sit inside a configured language directory.

#import "@tola/schema:0.0.0": check, issue, schema
#import "/site/locales/lib.typ": locales, source-directory

#let language-directories = locales.values().map(locale => locale.directory)

/// Source path in a configured language directory; other fields pass through.
#let source-schema = check(
  schema((path: str), unknown: "keep"),
  source => {
    let directory = source-directory(source)
    if directory in language-directories { return () }

    let expected = language-directories.map(name => "`" + name + "/`").join(", ")
    let message = "source `" + source.path + "` must be inside a configured language directory: " + expected
    (issue(message, path: ("path",)),)
  },
  on: ("path",),
)
