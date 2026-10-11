# Commands run from the repository root. Deno owns dependencies; Just owns tasks.

# Install the pinned site tools.
setup:
    deno install

# Called after Typst renders HTML; paths normally come from Tola's hook environment.
css *args:
    deno run -A scripts/styles.ts {{args}}

# Compile the browser entry points before Typst embeds preference initialization.
# Bundles are overwritten in place and stale ones removed afterwards, so the generated
# directory never disappears while an editor compiles the site.
scripts:
    deno bundle --check --minify --format=iife --platform=browser --outdir=static/web-assets/typescript-output static/typescript-sources/*.ts
    @for out in static/web-assets/typescript-output/*.js; do base=$(basename "$out" .js); test -f "static/typescript-sources/$base.ts" || rm "$out"; done

# Index the candidate site without exposing a partially built publication.
search:
    deno run -A scripts/search-previews.ts
    deno run -A npm:pagefind@1.5.2 --site "$TOLA_HOOK_INPUT_DIR" --output-path "$TOLA_HOOK_OUTPUT_DIR/assets/pagefind-search"

# Check the stylesheet toolchain and the complete site, including references.
# Local checks read the package cache and host tools; `--pure` belongs to CI, where the
# vendored inputs and the font set are the ones a clean machine gets.
check:
    deno check uno.config.ts scripts/*.ts static/typescript-sources/*.ts tests/*.ts
    tola check

# Check build invariants; optional arguments go directly to Deno (for example --filter headings).
[positional-arguments]
test *args:
    deno test -A "$@" tests/*.ts
