#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "分享、订阅与站点地图",
  description: "设置分享卡片，生成 feed.xml 和 sitemap.xml。",
  order: 20,
))

#title()

= 生成标题和分享标签

`@tola/head` 的 `head-metadata` 生成标题、字符编码、viewport 和描述。`canonical`、`open-graph` 和 `twitter-card` 负责规范地址和分享卡片。自定义 HTML 外壳时，可以把它们返回的数组合并，再用 `.join()` 交给 `html.head`。

规范地址使用最终部署的绝对 URL。在临时站点的 `tola.toml` 中加入以下配置。已有 `[site]` 时，只填入 `origin`。

```toml
[site]
origin = "https://example.com"
```

用下面的代码替换 `site.typ`。

```typst
#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": output-url
#import "@tola/head:0.0.0": canonical, head-metadata, open-graph

#let url = output-url("index.html", origin: site.origin)
#let entries = (
  head-metadata(site, title: "我的站点")
  + canonical(url)
  + open-graph(title: "我的站点", url: url)
)

#document("index.html", format: "html")[
  #html.html[
    #html.head(entries.join())
    #html.body[欢迎访问。]
  ]
]

#document("404.html", format: "html")[找不到页面。]
```

从站点根目录运行 `tola build --minify=false`。打开 `public/index.html`，在 `<head>` 中可见以下标签。示例使用默认的 `base-path`。

```html
<title>我的站点</title>
<link rel="canonical" href="https://example.com/">
<meta property="og:title" content="我的站点">
<meta property="og:type" content="website">
<meta property="og:url" content="https://example.com/">
```

= 订阅与站点地图

沿用 #link("/docs/getting-started/first-site/")[第一个站点]。在 `tola.toml` 中加入上面的 `[site]` 配置，再把下列代码加到 `site.typ` 末尾。

```typst
#import "@tola/feed:0.0.0": feed
#import "@tola/sitemap:0.0.0": sitemap

#feed(
  title: "我的站点",
  entries: ((
    id: "urn:my-site:install-guide",
    target: "guide/install/index.html",
    title: "安装指南",
    published: datetime(year: 2026, month: 9, day: 1),
  ),),
)

#sitemap(targets: ("index.html", "guide/install/index.html"))
```

`tola build` 后会得到 `public/feed.xml` 和 `public/sitemap.xml`。RSS 条目要有目标文档和发布日期。若文章可能改地址，可用固定 `id` 让订阅客户端继续把它识别为同一篇。

要让订阅条目跳到系统要求一节，先给 `content/guide/install.typ` 加一个带 `id` 的标题。

```typst
#html.h2(id: "requirements")[系统要求]
```

把 `feed` 条目中的 `target` 改为下面的值。重新构建后，`feed.xml` 的条目链接会带上 `#requirements`。`sitemap.xml` 仍然列出整页地址。

```typst
target: (output: "guide/install/index.html", fragment: "requirements"),
```

其他参数见 #link("/docs/reference/packages/feed/")[`feed` API]和 #link("/docs/reference/packages/sitemap/")[`sitemap` API]。
