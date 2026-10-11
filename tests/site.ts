import assert from "node:assert/strict";
import { cp } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { type DefaultTreeAdapterMap, parse } from "parse5";

type Node = DefaultTreeAdapterMap["node"];
type Element = DefaultTreeAdapterMap["element"];
const repository = fileURLToPath(new URL("../", import.meta.url));

const docsIndex = `#context {
  import "/site/pages.typ": current-page
  import "/site/docs.typ": sections
  import "/components/content/lib.typ": docs-index
  let page = current-page()
  docs-index(sections(page.locale.tag, omit: page.key), page.locale.messages.docs.index-separator)
}`;
const blogList = `#context {
  import "/site/pages.typ": current-page
  import "/site/blog.typ": posts
  import "/components/content/lib.typ": post-list
  let page = current-page()
  post-list(posts(page.locale.tag), page.locale.messages.blog.empty)
}`;

function attr(element: Element, name: string): string | undefined {
  return element.attrs.find((attribute) => attribute.name === name)?.value;
}

function elements(node: Node, tag: string, attrs: Record<string, string> = {}): Element[] {
  const result: Element[] = [];
  const visit = (node: Node) => {
    if (
      "tagName" in node && node.tagName === tag &&
      Object.entries(attrs).every(([name, value]) => attr(node, name) === value)
    ) result.push(node);
    if ("childNodes" in node) node.childNodes.forEach(visit);
  };
  visit(node);
  return result;
}

function text(node: Node): string {
  if ("value" in node) return node.value;
  return "childNodes" in node ? node.childNodes.map(text).join("") : "";
}

async function createSite() {
  const workspace = join(repository, ".tola", "tests");
  await Deno.mkdir(workspace, { recursive: true });
  const root = await Deno.makeTempDir({ dir: workspace, prefix: "site-" });

  const write = async (relative: string, content: string) => {
    const path = join(root, relative);
    await Deno.mkdir(dirname(path), { recursive: true });
    await Deno.writeTextFile(path, content);
  };

  const source = async (
    path: string,
    title: string,
    { meta = "", body = "Body.", imports = "" }: { meta?: string; body?: string; imports?: string } = {},
  ) => {
    await write(
      "content/" + path,
      `#import "@tola/source:0.0.0": tola-meta
${imports}
#tola-meta((title: ${JSON.stringify(title)}, description: "Test page", ${meta}))
#title()
${body}
`,
    );
  };

  const build = async (base = "/") => {
    const child = new Deno.Command("tola", {
      args: ["build", "--pure", "--no-log-file", "--color", "never", "--base-path", base],
      cwd: root,
      stdout: "piped",
      stderr: "piped",
    }).spawn();
    let timedOut = false;
    const timeout = setTimeout(() => {
      timedOut = true;
      child.kill("SIGKILL");
    }, 60_000);
    try {
      const result = await child.output();
      const log = new TextDecoder().decode(result.stdout) + new TextDecoder().decode(result.stderr);
      assert.ok(
        result.success && !timedOut,
        `Tola ${timedOut ? "timed out" : `exited ${result.code}`} in ${root}\n${log}`,
      );
    } finally {
      clearTimeout(timeout);
    }
  };

  const output = (path: string) => Deno.readTextFile(join(root, "public", path));
  const page = async (path: string) => parse(await output(path));
  const close = () => Deno.remove(root, { recursive: true });

  try {
    const shared = [
      "schemas", "site", "templates", "components", "icons", "vendor/icons", "site.typ", "static/web-assets/logo",
    ];
    for (const path of shared) await cp(join(repository, path), join(root, path), { recursive: true });
    for await (const entry of Deno.readDir(join(repository, "static/typescript-sources"))) {
      if (entry.isFile && entry.name.endsWith(".ts")) {
        await write(`static/web-assets/typescript-output/${entry.name.replace(/\.ts$/, ".js")}`, "/* stub */");
      }
    }
    await write("static/web-assets/styles/site.css", "/* stub */");
    await write(
      "tola.toml",
      `[site]
origin = "https://example.test"
title = "Tola"
language = "en"
languages = ["en", "zh-Hans"]
[build]
entry = "site.typ"
content-dir = "content"
publish-dir = "public"
[assets]
cache-busting = true
trees = [{ source = "static/web-assets", url-prefix = "/assets" }]
[icons.collections.lucide]
source-type = "remote-json"
preset = "lucide"
[icons.collections.simple-icons]
source-type = "local-json"
path = "icons/simple-icons.json"
[vendor]
path = "vendor"
`,
    );
    for (const locale of ["en", "zh-hans"]) {
      await source(`${locale}/index.typ`, "Home");
      await source(`${locale}/docs/getting-started/overview.typ`, locale === "en" ? "Overview" : "概览", {
        body: docsIndex,
      });
      await source(`${locale}/blog/index.typ`, "Blog", { body: blogList });
    }
    return { root, write, source, build, output, page, close };
  } catch (error) {
    await close();
    throw error;
  }
}

Deno.test("translations follow logical identity, permalinks and the deployment mount", async () => {
  const site = await createSite();
  try {
    await site.source("en/docs/guide/topic.typ", "English topic");
    await site.source("zh-hans/docs/guide/topic/index.typ", "中文主题", {
      meta: 'permalink: "/renamed%20space/%25%23/",',
    });
    await site.source("en/solo.typ", "English only");
    await site.source("zh-hans/solo.typ", "Draft translation", { meta: "draft: true," });
    for (const locale of ["en", "zh-hans"]) {
      await site.source(`${locale}/index.typ`, "Home", {
        body: `#link("/docs/guide/topic")[Local topic]
#link("/docs/guide/topic/")[Trailing slash]
#context {
  import "@tola/document:0.0.0": references
  let target = label("${locale}/docs/guide/topic")
  assert.eq(references(from: auto, to: target).len(), 2)
}`,
      });
    }
    await site.build("/preview/");
    const translated = "https://example.test/preview/renamed%20space/%25%23/";
    const english = await site.page("docs/guide/topic/index.html");
    const chinese = await site.page("renamed space/%#/index.html");
    assert.equal(attr(elements(english, "link", { hreflang: "zh-Hans" })[0], "href"), translated);
    assert.equal(attr(elements(chinese, "link", { rel: "canonical" })[0], "href"), translated);
    assert.equal(attr(elements(chinese, "html")[0], "lang"), "zh-Hans");
    for (
      const [output, expected] of [["index.html", "/preview/docs/guide/topic/"], [
        "zh-hans/index.html",
        new URL(translated).pathname,
      ]]
    ) {
      const page = await site.page(output);
      const links = elements(page, "a").filter((link) => ["Local topic", "Trailing slash"].includes(text(link)));
      assert.equal(links.length, 2);
      assert.ok(
        links.every((link) =>
          new URL(attr(link, "href")!, `https://example.test/preview/${output}`).pathname.replace(
            /index\.html$/,
            "",
          ) === expected
        ),
      );
    }
    assert.equal(elements(await site.page("solo/index.html"), "link", { hreflang: "zh-Hans" }).length, 0);
    assert.doesNotMatch(await site.output("sitemap.xml"), /zh-hans\/solo/);
    assert.ok(
      elements(english, "script").filter((script) => attr(script, "src")).every((script) =>
        attr(script, "src")!.startsWith("/preview/assets/") && attr(script, "src")!.includes("?")
      ),
    );
  } finally {
    await site.close();
  }
});

Deno.test("logical link shorthand leaves native targets and explicit URL syntax intact", async () => {
  const site = await createSite();
  try {
    await site.source("en/target.typ", "English target", { body: "= Part <part>" });
    await site.source("zh-hans/target.typ", "Localized target", { meta: 'permalink: "/本地/",' });
    await site.source("zh-hans/preview/target.typ", "Different logical page", {
      meta: 'permalink: "/wrong-logical/",',
    });
    await site.source("en/feed.xml.typ", "Feed-named page", { meta: 'permalink: "/special/",' });
    await site.source("zh-hans/index.typ", "Home", {
      body: `#import "@tola/address:0.0.0": output-url
#link("/target")[Logical]
#link(output-url("target/index.html"))[Mounted URL]
#link("/preview/t%61rget/")[Encoded URL]
#link("/preview/target/?view=full#part")[Query and fragment]
#link(output-url("feed.xml"))[Feed filename]
#link(label("en"))[Native document]
#link(<local-detail>)[Native label]
#context link(query(<local-detail>).first().location())[Native location]
#link("https://typst.app/")[External]
#link("mailto:hello@example.test")[Email]
= Detail <local-detail>`,
    });
    await site.build("/preview/");
    const page = await site.page("zh-hans/index.html");
    const links = new Map(elements(page, "a").map((link) => [text(link), attr(link, "href")!]));
    assert.equal(
      new URL(links.get("Logical")!, "https://example.test/preview/zh-hans/").pathname.replace(/index\.html$/, ""),
      "/preview/%E6%9C%AC%E5%9C%B0/",
    );
    for (
      const [label, expected] of [
        ["Mounted URL", "/preview/target/"],
        ["Encoded URL", "/preview/t%61rget/"],
        ["Query and fragment", "/preview/target/?view=full#part"],
        ["Feed filename", "/preview/feed.xml"],
        ["Native label", "#local-detail"],
        ["Native location", "#local-detail"],
        ["External", "https://typst.app/"],
        ["Email", "mailto:hello@example.test"],
      ]
    ) assert.equal(links.get(label), expected, label);
    assert.equal(
      new URL(links.get("Native document")!, "https://example.test/preview/zh-hans/").pathname.replace(
        /index\.html$/,
        "",
      ),
      "/preview/",
    );
  } finally {
    await site.close();
  }
});

Deno.test("documentation navigation, index and search breadcrumb share the localized tree", async () => {
  const site = await createSite();
  try {
    for (
      const [locale, handbook, route] of [["en", "Handbook", "/help/topic/"], ["zh-hans", "中文手册", "/帮助/主题/"]]
    ) {
      await site.source(`${locale}/docs/index.typ`, "Docs root", { body: docsIndex });
      await site.source(`${locale}/docs/guide/index.typ`, handbook, { meta: "order: -10," });
      await site.source(`${locale}/docs/guide/early.typ`, "Early", { meta: "order: -2," });
      await site.source(`${locale}/docs/guide/deep/b.typ`, "Deep B", { meta: "order: 1," });
      await site.source(`${locale}/docs/guide/deep/a.typ`, "Deep A", { meta: `order: 2, permalink: "${route}",` });
      await site.source(`${locale}/docs/reference/commands.typ`, "Commands");
    }
    await site.build("/preview/");
    for (
      const [prefix, handbook, route, navigation, previous, next, breadcrumb] of [
        ["", "Handbook", "/help/topic/", "Documentation", "Previous", "Next", "Breadcrumb"],
        ["zh-hans/", "中文手册", "/帮助/主题/", "文档导航", "上一篇", "下一篇", "当前位置"],
      ]
    ) {
      const page = await site.page(`${prefix}docs/guide/deep/b/index.html`);
      const sidebar = elements(page, "nav", { "aria-label": navigation })[0];
      const targets = elements(sidebar, "a").map((link) => attr(link, "href"));
      assert.deepEqual(
        targets,
        ["docs/", "docs/getting-started/overview/", "docs/guide/", "docs/guide/early/", "docs/guide/deep/b/"].map((
          path,
        ) => "/preview/" + prefix + path).concat(
          "/preview" + encodeURI(route),
          `/preview/${prefix}docs/reference/commands/`,
        ),
      );
      assert.ok(!targets.includes(`/preview/${prefix}docs/guide/deep/`));
      assert.equal(
        attr(elements(sidebar, "a", { "aria-current": "page" })[0], "href"),
        `/preview/${prefix}docs/guide/deep/b/`,
      );
      assert.equal(
        attr(elements(page, "a").find((link) => text(link).startsWith(previous))!, "href"),
        `/preview/${prefix}docs/guide/early/`,
      );
      assert.equal(
        attr(elements(page, "a").find((link) => text(link).startsWith(next))!, "href"),
        "/preview" + encodeURI(route),
      );
      const topic = await site.page(route.slice(1) + "index.html");
      assert.equal(
        attr(
          elements(topic, "span", { "data-pagefind-meta": "breadcrumb[data-search-breadcrumb]" })[0],
          "data-search-breadcrumb",
        ),
        `Docs root › ${handbook} › deep`,
      );
      assert.equal(attr(elements(topic, "meta", { name: "page-kind" })[0], "content"), "doc");
      const overview = await site.page(`${prefix}docs/getting-started/overview/index.html`);
      const index = elements(overview, "div", { "data-pagefind-body": "" })[0];
      const titles = elements(index, "a").map(text).filter(Boolean);
      assert.deepEqual(titles, ["Docs root", handbook, "Early", "Deep B", "Deep A", "Commands"]);
      assert.ok(text(elements(topic, "nav", { "aria-label": breadcrumb })[0]).includes(handbook));
      const root = await site.page(`${prefix}docs/index.html`);
      assert.equal(
        attr(elements(root, "a").find((link) => text(link).startsWith(next))!, "href"),
        `/preview/${prefix}docs/getting-started/overview/`,
      );
    }
  } finally {
    await site.close();
  }
});

Deno.test("heading permalinks retain native records, numbering, labels and location links", async () => {
  const site = await createSite();
  try {
    await site.source("en/docs/guide/headings.typ", "Headings", {
      meta: "order: 1,",
      body: `#set heading(numbering: "1.1")
= Explicit <content-transformations>
== Automatic
#heading(level: 2, outlined: false)[Not outlined] <not-outlined>
= Hello World
= Hello World
= Explicit later <hello-world>
= Explicit suffix <hello-world-2>
= 中文 标题
= Café
= Cafe
= 🐋
= !!!
See @content-transformations.
#link(<not-outlined>)[Existing non-outlined target]
#context {
  import "@tola/document:0.0.0": headings, references
  let found = headings()
  assert.eq(found.map(it => it.level), (1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1))
  assert.eq(found.map(it => it.nesting), (1, 2, none, 1, 1, 1, 1, 1, 1, 1, 1, 1))
  assert.eq(found.map(it => it.label), (<content-transformations>, none, <not-outlined>, none, none, <hello-world>, <hello-world-2>, none, none, none, none, none))
  assert.eq(found.map(it => it.number), ("1", "1.1", "1.2", "2", "3", "4", "5", "6", "7", "8", "9", "10"))
  assert(references(to: found.first().location).all(it => it.target.fragment == "content-transformations"))
}`,
    });
    await site.source("en/docs/guide/other.typ", "Other", { meta: "order: 2,", body: "= Hello World" });
    await site.build();
    const page = await site.page("docs/guide/headings/index.html");
    const ids = [
      "content-transformations",
      "automatic",
      "hello-world-3",
      "hello-world-4",
      "hello-world",
      "hello-world-2",
      "zhong-wen-biao-ti",
      "cafe",
      "cafe-2",
      "section",
      "section-2",
    ];
    const headings = ["h2", "h3"].flatMap((tag) => elements(page, tag));
    for (const id of ids) {
      const heading = headings.find((heading) => attr(heading, "id") === id);
      assert.ok(heading, `Missing heading target ${id}`);
      assert.equal(attr(elements(heading, "a")[0], "href"), "#" + id);
    }
    const toc = elements(page, "nav", { "aria-label": "On this page" })[0];
    assert.deepEqual(elements(toc, "a").map((link) => attr(link, "href")), ids.map((id) => "#" + id));
    assert.equal(text(headings.find((heading) => attr(heading, "id") === "content-transformations")!), "1 Explicit");
    assert.equal(text(headings.find((heading) => attr(heading, "id") === "hello-world-3")!), "2 Hello World");
    const other = await site.page("docs/guide/other/index.html");
    assert.equal(attr(elements(other, "h2").find((heading) => text(heading) === "Hello World")!, "id"), "hello-world");
  } finally {
    await site.close();
  }
});

Deno.test("shared content keeps its enclosing document and generated listings select a language explicitly", async () => {
  const site = await createSite();
  try {
    await site.source("en/shared.typ", "Source title", {
      meta: "draft: true,",
      imports: `#import "@tola/document:0.0.0": current-document
#let note(body) = html.article(body)
#show: note`,
      body: "SHARED_BODY\n#context [Output: #current-document().output]",
    });
    for (
      const [locale, slug, title, tag] of [["en", "included", "Selected", "typst"], [
        "en",
        "excluded",
        "Excluded",
        "other",
      ], ["zh-hans", "translated", "Other language", "typst"]]
    ) {
      await site.source(`${locale}/blog/${slug}.typ`, title, {
        meta: `published: "2026-10-15T00:00:00Z", tags: "${tag}",`,
      });
    }
    const entry = await Deno.readTextFile(join(site.root, "site.typ"));
    await site.write(
      "site.typ",
      entry + `
#let shared = include "/content/en/shared.typ"
#for name in ("standalone", "collection") {
  let output = name + "/index.html"
  let page = (key: "/" + name + "/", kind: "page", meta: (title: name, description: none), output: output, locale: locales.en)
  let navigation = (home: none, documentation: none, blog-index: none)
  document(output, title: name)[
    #show: base.page.with(page, navigation, ())
    #shared
    #if name == "collection" [= Collection appendix]
  ]
}
#document("listing.html")[
  #context {
    import "/site/pages.typ": current-page
    import "/site/blog.typ": posts
    import "/components/content/lib.typ": post-list
    assert.eq(current-page(), none)
    post-list(posts("en").filter(post => "typst" in post.meta.tags), "Empty")
  }
]
`,
    );
    await site.build();
    for (const name of ["standalone", "collection"]) {
      const page = await site.page(`${name}/index.html`);
      for (const tag of ["html", "body", "main"]) assert.equal(elements(page, tag).length, 1, `${name}: ${tag}`);
      assert.equal(text(page).split("SHARED_BODY").length - 1, 1);
      assert.ok(text(page).includes(`Output: ${name}/index.html`));
      assert.deepEqual(elements(page, "h1").map(text), [name]);
      assert.equal(text(page).includes("Collection appendix"), name === "collection");
    }
    const listing = text(await site.page("listing.html"));
    assert.match(listing, /Selected/);
    assert.doesNotMatch(listing, /Excluded|Other language/);
  } finally {
    await site.close();
  }
});

Deno.test("blog publication, feeds and sitemap share the selected posts without leaking the page shell", async () => {
  const site = await createSite();
  try {
    await site.source("en/blog/index.typ", "Blog", { meta: 'permalink: "/journal/",', body: blogList });
    for (
      const [slug, title, date, extra] of [
        ["older", "Older", "2026-10-10T00:00:00Z", ""],
        ["newer", "Newer", "2026-10-11T00:00:00.001Z", ""],
        ["newest", "Newest", "2026-10-11T00:00:00.002Z", "updated: datetime(year: 2026, month: 10, day: 12),"],
        ["no-feed", "No feed", "2026-10-12T00:00:00Z", "feed: false,"],
      ]
    ) await site.source(`en/blog/${slug}.typ`, title, { meta: `published: "${date}", ${extra}`, body: "ARTICLE_BODY" });
    await site.source("zh-hans/blog/local.typ", "中文文章", { meta: 'published: "2026-10-11T00:00:00Z",' });
    await site.source("en/blog/draft.typ", "Draft post", { meta: "draft: true," });
    await site.build();
    const rss = await site.output("feed.xml");
    assert.deepEqual([...rss.matchAll(/<item>\s*<title>([^<]*)<\/title>/g)].map((match) => match[1]), [
      "Newest",
      "Newer",
      "Older",
    ]);
    const bodies = [...rss.matchAll(/<content:encoded\b[^>]*>([\s\S]*?)<\/content:encoded>/g)].map((match) => match[1]);
    assert.equal(bodies.length, 3);
    for (const body of bodies) {
      assert.match(body, /ARTICLE_BODY/);
      assert.doesNotMatch(body, /(?:<|&lt;)(?:header|footer|nav)\b/);
    }
    assert.match(await site.output("zh-hans/feed.xml"), /<item>\s*<title>中文文章<\/title>/);
    const listing = await site.page("journal/index.html");
    const listedTitles = elements(listing, "h2").flatMap((heading) => elements(heading, "a")).map(text).filter(Boolean);
    assert.deepEqual(listedTitles, ["No feed", "Newest", "Newer", "Older"]);
    assert.ok(
      elements(await site.page("blog/newest/index.html"), "a").some((link) => attr(link, "href") === "/journal/"),
    );
    const sitemap = await site.output("sitemap.xml");
    assert.match(sitemap, /<loc>https:\/\/example\.test\/blog\/newest\/<\/loc>\s*<lastmod>2026-10-12<\/lastmod>/);
    assert.match(sitemap, /\/blog\/no-feed\//);
    assert.doesNotMatch(sitemap, /\/blog\/draft\//);
  } finally {
    await site.close();
  }
});
