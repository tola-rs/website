/// <reference lib="deno.ns" />

import assert from "node:assert/strict";
import { join } from "node:path";
import postcss from "postcss";
import { createGenerator } from "unocss";
import config from "../uno.config.ts";
import { htmlExtractor } from "../scripts/html-extractor.ts";
import { compileStyles } from "../scripts/styles.ts";

async function extract(code: string): Promise<Set<string>> {
  const tokens = await htmlExtractor.extract!({
    code,
    original: code,
    id: "page.html",
    extracted: new Set<string>(),
  });
  return new Set(tokens || []);
}

Deno.test("rendered attributes preserve computed classes, prefixed utilities and entities", async () => {
  const variant = "docs";
  const direction = "after";
  const tokens = await extract(`
    <main class="layout-${variant} neighbor ${direction} hover&#58;text-accent">
      <span un-text="sm muted" un-bg="accent&#47;10" un-flex></span>
      <template><a class="ui-control">Created later</a></template>
    </main>
  `);
  assert.deepEqual(
    tokens,
    new Set([
      "layout-docs",
      "neighbor",
      "after",
      "hover:text-accent",
      '[un-text~="sm"]',
      '[un-text~="muted"]',
      '[un-bg~="accent/10"]',
      '[un-flex=""]',
      "ui-control",
    ]),
  );
});

Deno.test("prose, comments, script strings and escaped examples do not become utilities", async () => {
  const tokens = await extract(`
    <p class="prose" hidden width="96" text="red-500">grid flex table p-96</p>
    <!-- <div class="p-88" un-bg="red-500"></div> -->
    <script>const example = '<div class="p-77" un-text="green-500"></div>';</script>
    <style>.example::before { content: '<i class="p-66" un-m="55">'; }</style>
    <code>&lt;div class="p-44" un-p="33"&gt;escaped&lt;/div&gt;</code>
  `);
  assert.deepEqual(tokens, new Set(["prose"]));
});

Deno.test("the configured generator uses only actual HTML utility attributes", async () => {
  const uno = await createGenerator(config);
  const { css, matched } = await uno.generate(
    `
    <main class="max-w-reading" un-flex="col" un-bg="accent&#47;10">
      <p hidden width="96" text="red-500">grid flex p-96</p>
      <!-- <i class="p-88" un-text="green-500"></i> -->
      <script>const x = '<i class="p-77" un-bg="red-500"></i>';</script>
      <code>&lt;i class="p-66" un-p="55"&gt;</code>
    </main>
  `,
    { id: "rendered.html" },
  );
  assert.deepEqual(
    matched,
    new Set([
      "max-w-reading",
      '[un-flex~="col"]',
      '[un-bg~="accent/10"]',
    ]),
  );
  assert.match(css, /flex-direction:\s*column/);
  assert.match(css, /var\(--accent\)/);
  assert.doesNotMatch(css, /\.p-(?:96|88|77|66)|red-500|green-500/);
});

Deno.test("dark utilities follow saved preferences and the system fallback", async () => {
  const uno = await createGenerator(config);
  const { css } = await uno.generate(new Set(["dark:bg-ink"]));
  assert.match(css, /:root\[data-theme="dark"\]/);
  assert.match(css, /@media\s*\(prefers-color-scheme:\s*dark\)/);
  assert.match(css, /:root:not\(\[data-theme\]\)/);
  assert.doesNotMatch(css, /data-preference/);
  assert.doesNotMatch(css, /\.dark\s+\.dark\\:/);
});

Deno.test("the final CSS pipeline preserves global registrations from component @apply", async () => {
  const directory = await Deno.makeTempDir();
  try {
    const from = join(directory, "site.css");
    const page = join(directory, "page.html");
    await Deno.writeTextFile(from, `
      @layer properties, theme, base, shortcuts, components, utilities;
      @import "./component.css";
      @unocss;
    `);
    await Deno.writeTextFile(join(directory, "component.css"), `
      @layer components {
        .card {
          @apply border border-solid border-line shadow-sm font-sans;
          @apply docs:(p-8) motion-reduce:transition-none;
        }
        .card:focus-visible { @apply outline-3 outline-accent; }
        .prose hr { @apply my-8 border-x-0 border-b-0 border-t border-solid border-line; }
      }
    `);
    // All affected properties originate in @apply, not matching HTML utilities.
    await Deno.writeTextFile(page, '<main class="card prose"><hr></main>');
    const css = new TextDecoder().decode(await compileStyles(from, [page]));
    const root = postcss.parse(css);
    for (const layer of ["reset", "typography"]) {
      assert.match(css, new RegExp(`@layer\\s+${layer}\\s*\\{`));
    }
    assert.match(css, /--un-prose-body:var\(--text\)/);
    assert.match(css, /--un-prose-invert-body:var\(--text\)/);
    const properties = new Map<string, Map<string, string>>();
    root.walkAtRules("property", (rule) => {
      let ancestor: postcss.Node | undefined = rule.parent;
      while (ancestor) {
        assert.notEqual(ancestor.type, "rule", `${rule.params} must be global`);
        ancestor = ancestor.parent;
      }
      const descriptors = new Map<string, string>();
      rule.walkDecls((decl) => { descriptors.set(decl.prop, decl.value); });
      properties.set(rule.params, descriptors);
    });
    for (const name of ["--un-border-opacity", "--un-outline-style", "--un-shadow"]) {
      assert.ok(properties.has(name), `${name} registration must survive final minification`);
      assert.equal(properties.get(name)!.get("inherits"), "false");
      assert.ok(properties.get(name)!.has("syntax"));
      assert.ok(properties.get(name)!.has("initial-value"));
    }
    root.walkDecls((decl) => {
      if (["syntax", "inherits", "initial-value"].includes(decl.prop)) {
        assert.equal(decl.parent!.type, "atrule", `${decl.prop} leaked into an ordinary style rule`);
        assert.equal((decl.parent as postcss.AtRule).name, "property");
      }
    });
    assert.doesNotMatch(css, /@(apply|screen|unocss|import)\b/);
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});

Deno.test("the final CSS pipeline rejects an unknown imported @apply utility with its location", async () => {
  const directory = await Deno.makeTempDir();
  try {
    const from = join(directory, "site.css");
    const page = join(directory, "page.html");
    await Deno.writeTextFile(from, '@import "./component.css"; @unocss;');
    await Deno.writeTextFile(join(directory, "component.css"), ".card { @apply p-4 misspelled-site-utility; }");
    await Deno.writeTextFile(page, '<main class="card"></main>');
    await assert.rejects(
      () => compileStyles(from, [page]),
      /component\.css:1:\d+: Unknown UnoCSS utility: misspelled-site-utility/,
    );
  } finally {
    await Deno.remove(directory, { recursive: true });
  }
});
