import { mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import { join, resolve } from "node:path";
import postcss from "postcss";
import postcssImport from "postcss-import";
import MagicString from "magic-string";
import { createGenerator, expandVariantGroup, transformerDirectives, type UnocssPluginContext } from "unocss";
import { transform } from "lightningcss";
import config from "../uno.config.ts";

async function htmlFiles(directory: string): Promise<string[]> {
  const entries = await readdir(directory, { withFileTypes: true });
  const paths = await Promise.all(entries.map((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? htmlFiles(path) : entry.name.endsWith(".html") ? [path] : [];
  }));
  return paths.flat().sort();
}

// One generator shares theme/property dependencies between @apply and HTML.
export async function compileStyles(from: string, pages: string[]): Promise<Uint8Array> {
  const imported = await postcss([postcssImport()]).process(await readFile(from, "utf8"), { from });
  if (imported.warnings().length) throw new Error(imported.warnings().join("\n"));
  const uno = await createGenerator(config);
  const applications: { token: string; error: (message: string) => Error }[] = [];
  imported.root.walkAtRules((rule) => {
    if (/^(theme|custom-variant|variant|source|utility|tailwind)$/.test(rule.name)) {
      throw rule.error(`Unsupported Tailwind directive @${rule.name}`);
    }
    if (rule.name === "apply") {
      for (const token of expandVariantGroup(rule.params).split(/\s+/).filter(Boolean)) {
        applications.push({ token, error: (message) => rule.error(message) });
      }
    }
  });
  for (const value of Object.values(config.shortcuts ?? {})) {
    if (typeof value !== "string") continue;
    for (const token of expandVariantGroup(value).split(/\s+/).filter(Boolean)) {
      applications.push({ token, error: (message) => new Error(`uno.config.ts: ${message}`) });
    }
  }
  for (const { token, error } of applications) {
    if (!(await uno.parseToken(token))?.length) throw error(`Unknown UnoCSS utility: ${token}`);
  }

  const source = new MagicString(imported.css);
  // This official transformer uses only ctx.uno. It hoists @property out of
  // @apply rules; the experimental PostCSS integration does not preserve them.
  await transformerDirectives().transform!(source, from, { uno } as UnocssPluginContext);
  const tokens = new Set<string>();
  for (const page of pages) await uno.applyExtractors(await readFile(page, "utf8"), page, tokens);
  const generated = await uno.generate(tokens);
  const result = postcss.parse(source.toString(), { from });
  let placeholders = 0;
  result.walkAtRules("unocss", (rule) => {
    if (rule.params) throw rule.error("Use a single @unocss placeholder without layer arguments");
    rule.replaceWith(postcss.parse(generated.css).nodes);
    placeholders++;
  });
  if (placeholders !== 1) throw new Error(`${from}: expected one @unocss placeholder`);
  result.walkAtRules((rule) => {
    if (/^(apply|screen|unocss|import)$/.test(rule.name)) throw rule.error(`Unresolved @${rule.name}`);
  });
  const { code, warnings } = transform({
    filename: from, code: new TextEncoder().encode(result.toString()), minify: true,
    targets: { chrome: 120 << 16, firefox: 128 << 16, safari: (17 << 16) | (4 << 8) },
  });
  if (warnings.length) throw new Error(JSON.stringify(warnings));
  return code;
}

if (import.meta.main) {
  const input = Deno.env.get("TOLA_HOOK_INPUT_DIR") ?? Deno.args[0];
  const output = Deno.env.get("TOLA_HOOK_OUTPUT_DIR") ?? Deno.args[1];
  if (!input || !output) throw new Error("Run tola build, or: just css <rendered-html-directory> <output-directory>");
  const pages = await htmlFiles(resolve(input));
  if (!pages.length) throw new Error(`No rendered HTML found in ${input}`);
  const code = await compileStyles(resolve("static/styles/site.css"), pages);
  const destination = join(output, "assets/styles/site.css");
  await mkdir(join(output, "assets/styles"), { recursive: true });
  await writeFile(destination, code);
  console.log(`UnoCSS: ${pages.length} pages, ${code.byteLength} bytes`);
}
