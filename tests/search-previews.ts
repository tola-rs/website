/// <reference lib="deno.ns" />

import assert from "node:assert/strict";
import { searchPreviews } from "../scripts/search-previews.ts";
import { previewContext, previewImageUrl, type PreviewNode } from "../static/typescript-sources/shared/search-preview.ts";

type PreviewElement = Exclude<PreviewNode, string>;
const elements = (nodes: PreviewNode[]): PreviewElement[] =>
  nodes.flatMap((node) =>
    typeof node === "string" ? [] : [node, ...elements(node.children)]
  );
const content = (nodes: PreviewNode[]): string =>
  nodes.map((node) => typeof node === "string" ? node : content(node.children))
    .join("");

Deno.test("search sections use native heading IDs and stop at the next peer heading", () => {
  const preview = searchPreviews(
    `
    <main><article data-pagefind-body>
      <h1 id="page">Page title</h1><p>Page introduction.</p>
      <h2 id="typst-λ:介绍">An unrelated display title</h2><p>Section introduction.</p>
      <h3 id="shape&amp;value">A nested topic</h3><p>Nested content.</p>
      <h2 id="next-section">Next section</h2><p>Other content.</p>
    </article></main>
  `,
    "docs/guide/index.html",
  );
  assert.ok(preview);
  assert.deepEqual(Object.keys(preview.sections), [
    "",
    "page",
    "typst-λ:介绍",
    "shape&value",
    "next-section",
  ]);
  assert.equal(content(preview.sections[""]), "Page introduction.");
  assert.deepEqual(
    preview.sections["typst-λ:介绍"].map((node) =>
      typeof node === "string" ? "text" : node.tag
    ),
    ["p", "h3", "p"],
  );
  assert.match(
    content(preview.sections["typst-λ:介绍"]),
    /Section introduction\..*Nested content\./,
  );
  assert.doesNotMatch(
    content(preview.sections["typst-λ:介绍"]),
    /Other content|Next section/,
  );
  assert.equal(content(preview.sections["shape&value"]), "Nested content.");
  assert.equal(
    searchPreviews("<main><p>No indexed body.</p></main>", "index.html"),
    null,
  );
});

Deno.test("an eyebrow before the h1 does not consume the intro section", () => {
  const preview = searchPreviews(
    `
    <main><article data-pagefind-body>
      <p>Eyebrow</p><h1 id="page">Page title</h1><p>Lead.</p><p>Meta.</p>
      <h2 id="next">Next</h2><p>Other.</p>
    </article></main>
  `,
    "index.html",
  );
  assert.ok(preview);
  assert.equal(content(preview.sections[""]), "Lead.Meta.");
  assert.doesNotMatch(content(preview.sections[""]), /Eyebrow|Page title|Other/);
});

Deno.test("rich code preserves language and syntax tokens while excluding executable and hidden content", () => {
  const preview = searchPreviews(
    `
    <main><article data-pagefind-body>
      <h1>Example</h1>
      <pre class="tola-code arbitrary" onclick="alert(1)" style="position:fixed">
        <code data-lang="typst" onmouseover="alert(2)"><span class="evil" style="--tola-code-color:#aabbcc;--tola-code-dark-color:rgb(220 221 222);--tola-code-weight:700;--tola-code-style:italic;--tola-code-decoration:underline;--tola-code-dark-style:url(https://evil.invalid);position:fixed;--injected:yes">#let answer = 42</span></code>
      </pre>
      <p onclick="alert(3)" style="background:url(https://evil.invalid)">Readable text.
        <script>SECRET_SCRIPT</script><style>SECRET_STYLE</style>
        <span hidden>SECRET_HIDDEN</span><span aria-hidden="true">SECRET_ARIA</span>
        <span data-pagefind-ignore>SECRET_IGNORE</span><span style="display:none">SECRET_DISPLAY</span>
      </p>
      <iframe>SECRET_IFRAME</iframe><nav><p>SECRET_NAV</p></nav>
    </article></main>
  `,
    "docs/code/index.html",
  );
  assert.ok(preview);
  const nodes = elements(preview.sections[""]);
  assert.deepEqual(nodes.find((node) => node.tag === "pre")!.attrs, {
    class: "tola-code",
  });
  assert.deepEqual(nodes.find((node) => node.tag === "code")!.attrs, {
    "data-lang": "typst",
  });
  assert.deepEqual(nodes.find((node) => node.tag === "span")!.tokens, {
    "--tola-code-color": "#aabbcc",
    "--tola-code-dark-color": "rgb(220 221 222)",
    "--tola-code-weight": "700",
    "--tola-code-style": "italic",
    "--tola-code-decoration": "underline",
  });
  assert.match(content(preview.sections[""]), /#let answer = 42/);
  assert.match(content(preview.sections[""]), /Readable text\./);
  assert.doesNotMatch(
    JSON.stringify(preview),
    /SECRET_|onclick|onmouseover|position|evil\.invalid|--injected/,
  );
});

Deno.test("code groups preview the first tab with its label", () => {
  const preview = searchPreviews(
    `
    <main><article data-pagefind-body>
      <h1>Example</h1>
      <div class="code-group">
        <input type="radio" class="code-tab-input" checked>
        <label class="code-tab">site.typ</label>
        <div class="code-panel" data-search-preview-label="site.typ"><pre><code data-lang="typst">first sample</code></pre></div>
        <input type="radio" class="code-tab-input">
        <label class="code-tab">install.typ</label>
        <div class="code-panel" data-search-preview-ignore><pre><code data-lang="typst">second sample</code></pre></div>
      </div>
    </article></main>
  `,
    "docs/code/index.html",
  );
  assert.ok(preview);
  const text = content(preview.sections[""]);
  assert.match(text, /site\.typ/);
  assert.match(text, /first sample/);
  assert.doesNotMatch(text, /install\.typ|second sample/);
});

Deno.test("canonical-origin preview links become deployment paths and safe external links remain external", () => {
  const preview = searchPreviews(
    `
    <link rel="canonical" href="https://production.example/project/docs/guide/index.html">
    <main><article data-pagefind-body><p>
      <a href="https://production.example/project/docs/api/?q=1&amp;lang=en#native">Canonical site</a>
      <a href="../start/?q=two#install">Relative page</a>
      <a href="https://external.example/reference?q=1#part">External reference</a>
      <a href="mailto:hello@example.com">Email</a>
      <a href="javascript:alert(1)" onclick="alert(2)">Unsafe destination</a>
      <a href="data:text/html,unsafe">Unsafe data</a>
    </p></article></main>
  `,
    "docs/guide/index.html",
  );
  assert.ok(preview);
  const links = elements(preview.sections[""]).filter((node) =>
    node.tag === "a"
  );
  assert.deepEqual(links.map((node) => node.attrs?.href), [
    "/project/docs/api/?q=1&lang=en#native",
    "/project/docs/start/?q=two#install",
    "https://external.example/reference?q=1#part",
    "mailto:hello@example.com",
    undefined,
    undefined,
  ]);
  assert.match(content(preview.sections[""]), /Unsafe destination/);
});

Deno.test("preview metadata supplies the deployment base when canonical metadata is absent", () => {
  const preview = searchPreviews(
    `
    <meta data-pagefind-meta="preview[content]" content="/nested/site/assets/search-previews/docs/guide/index.html.json">
    <main><article data-pagefind-body><p>
      <a href="../next/?lang=zh#section">Next</a>
      <a href="#native-heading">This page</a>
    </p></article></main>
  `,
    "docs/guide/index.html",
  );
  assert.ok(preview);
  assert.deepEqual(
    elements(preview.sections[""]).filter((node) => node.tag === "a").map(
      (node) => node.attrs?.href,
    ),
    [
      "/nested/site/docs/next/?lang=zh#section",
      "/nested/site/docs/guide/index.html#native-heading",
    ],
  );
});

Deno.test("image-only sections and picture fallbacks retain safe media and captions", () => {
  const preview = searchPreviews(`
    <link rel="canonical" href="https://production.example/project/docs/guide/">
    <main><article data-pagefind-body>
      <h1>Images</h1>
      <figure><picture>
        <source srcset="https://external.example/unselected.webp">
        <img src="../../assets/diagram.svg?v=2" alt="Build graph" width="960" height="640" onerror="unsafe()" style="position:fixed">
      </picture><figcaption>Build stages.</figcaption></figure>
      <h2 id="image-only">Image only</h2><img src="/project/assets/photo.webp" alt="Photo">
      <h2 id="unsafe">Unsafe</h2>
      <img src="javascript:unsafe()"><img src="data:image/svg+xml,unsafe"><img src="file:///secret">
      <img src="https://user:password@example.com/private"><img src=""><img src="/hidden.png" hidden>
      <img src="/decorative.png" alt="">
    </article></main>`, "docs/guide/index.html");
  assert.ok(preview);
  const image = elements(preview.sections[""]).find(node => node.tag === "img");
  assert.deepEqual(image?.attrs, {
    src: "/project/assets/diagram.svg?v=2", alt: "Build graph", width: "960", height: "640",
  });
  assert.ok(elements(preview.sections[""]).some(node => node.tag === "figcaption"));
  assert.equal(elements(preview.sections["image-only"])[0]?.tag, "img");
  assert.deepEqual(preview.sections.unsafe, []);
  assert.doesNotMatch(JSON.stringify(preview), /onerror|position|unselected|password|hidden\.png|decorative\.png/);
  assert.equal(previewImageUrl("https://cdn.example/image.png", new URL("https://site.example/")), "https://cdn.example/image.png");
});

Deno.test("nested heading paths follow ancestry and reset at peer sections", () => {
  const preview = searchPreviews(`
    <main><article data-pagefind-body>
      <h1 id="page">Page</h1><p>Intro.</p>
      <h2 id="parent">Parent <a data-pagefind-ignore>Permalink</a></h2>
      <h3 id="child">Child</h3><h4 id="leaf">Leaf</h4><p>Content.</p>
      <h2 id="peer">Peer</h2><h3 id="other">Other child</h3><p>Other.</p>
    </article></main>`, "index.html");
  assert.deepEqual({ ...preview?.parents }, { page: [], parent: [], child: ["Parent"], leaf: ["Parent", "Child"], peer: [], other: ["Peer"] });
});

Deno.test("previews can reach late matches and retain nearby structural context", () => {
  const preview = searchPreviews(`<main><article data-pagefind-body><h1>Long section</h1>
    ${Array.from({ length: 16 }, (_, index) => `<p>Paragraph ${index}${index === 12 ? " with needle.* and 中文" : ""}.</p>`).join("")}
    </article></main>`, "index.html");
  assert.ok(preview);
  for (const query of ["needle.*", "中文", '"needle.*"']) {
    const context = previewContext(preview.sections[""], query);
    assert.match(content(context), /^Paragraph 11/);
    assert.match(content(context), /needle\.\*/);
    assert.ok(context.length <= 8);
  }
  assert.match(content(previewContext(preview.sections[""], "missing")), /^Paragraph 0/);
  assert.equal(previewContext(preview.sections[""], "").length, 8);
});

Deno.test("article callouts survive as structured content while unrelated asides stay excluded", () => {
  const preview = searchPreviews(`<main><article data-pagefind-body>
    <aside class="callout"><strong>Note</strong><p>Useful detail.</p></aside>
    <aside><p>Navigation clutter.</p></aside>
    </article></main>`, "index.html");
  assert.ok(preview);
  assert.equal(elements(preview.sections[""])[0].tag, "blockquote");
  assert.match(content(preview.sections[""]), /NoteUseful detail/);
  assert.doesNotMatch(content(preview.sections[""]), /Navigation clutter/);
});

Deno.test("formulas preserve MathML structure without executable annotations or arbitrary styles", () => {
  const preview = searchPreviews(`<main><article data-pagefind-body>
    <p>Inline <math><msup><mi>x</mi><mn>2</mn></msup></math> stays in its paragraph.</p>
    <math display="block" style="position:fixed" onclick="unsafe()"><semantics>
      <mfrac linethickness="1px"><mn>1</mn><mi>x</mi></mfrac>
      <annotation encoding="application/x-tex">SECRET_TEX</annotation>
      <annotation-xml encoding="text/html"><p>SECRET_HTML</p></annotation-xml>
    </semantics></math>
    </article></main>`, "index.html");
  assert.ok(preview);
  const nodes = elements(preview.sections[""]);
  assert.equal(nodes.filter(node => node.tag === "math").length, 2);
  assert.deepEqual(nodes.find(node => node.tag === "mfrac")?.attrs, { linethickness: "1px" });
  assert.ok(nodes.some(node => node.tag === "msup"));
  assert.doesNotMatch(JSON.stringify(preview), /SECRET_|onclick|position/);
});
