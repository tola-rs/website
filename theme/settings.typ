// The project's validated configuration for this theme.

#import "@tola/module:0.0.0": get-module
#import "@tola/schema:0.0.0": parse
#import "options.typ": schema

#let options = parse(get-module().options, schema)

#let repository = options.repository
#let site-repository = options.site-repository
#let versions = options.versions
#let copyright = options.copyright
#let docs-groups = options.docs-groups
#let docs-section = options.docs-section
#let font = options.font
