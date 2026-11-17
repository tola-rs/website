#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "分享、订阅与站点地图",
  description: "生成 <head> 元标签与社交分享卡片，并输出 feed.xml 和 sitemap.xml。",
  order: 30,
))

#title()

规范地址、Open Graph 卡片、RSS 订阅与站点地图都需要最终部署的绝对 URL，因此应先在 `tola.toml` 中设置 `[site].origin`：

```toml
[site]
origin = "https://example.com"
```

= 生成 `<head>` 与分享标签

`@tola/head` 提供 `head-metadata`（标题、字符编码、viewport、描述）以及 `canonical`、`open-graph`、`twitter-card`。在自定义 `html.html` 外壳中，把它们返回的数组拼接并用 `.join()` 放进 `html.head`：

```typst
#import "@tola/site:0.0.0": site
#import "@tola/address:0.0.0": output-url
#import "@tola/document:0.0.0": plain-text
#import "@tola/head:0.0.0": canonical, head-metadata, open-graph

#let url = output-url("index.html", origin: site.origin)
#let page-title = plain-text([我的站点])
#let entries = (
  head-metadata(site, title: page-title)
  + canonical(url)
  + open-graph(title: page-title, url: url)
)

#document("index.html", format: "html")[
  #html.html[
    #html.head(entries.join())
    #html.body[欢迎访问。]
  ]
]
```

开启 `origin` 后构建，`public/index.html` 的 `<head>` 中会输出 `<title>`、`<link rel="canonical" ...>` 以及 `og:title` / `og:type` / `og:url` 等元标签。

#callout[
  两处易忽略的细节：1) 若文章标题是带格式的 Typst `content`，先用 `@tola/document` 的 `plain-text` 提取纯文本再传入标签函数；2) 分享卡片里的封面图片地址不会自动发布图片，请确认该图片已通过 `[assets]` 或 `@tola/image` 实际输出。
]

= 发布订阅与站点地图

在 `site.typ` 末尾调用 `@tola/feed` 与 `@tola/sitemap` 即可生成 `feed.xml` 与 `sitemap.xml`：

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

关于订阅条目与全文输出：

- *稳定 `id` 与时间戳*：给文章设置不随 URL 变化的 `id`，避免订阅器重复推送；若由 `@tola/schema` 解析 `timestamp`，可直接传 `.rfc3339`。
- *只含摘要还是包含正文*：只填 `summary` 时条目只有摘要；若要附带文章正文并排除页头和导航栏，给正文容器加上唯一 ID（如 `id: "article"`），再把 `content: (document: page.output, id: "article")` 传给条目。
- *跳转到页内小节*：如果希望订阅条目跳到特定标题，用 `#html.h2(id: "requirements")[系统要求]` 声明固定锚点，再将条目的 `target` 写为 `(output: "guide/install/index.html", fragment: "requirements")`。
- *站点地图*：`sitemap` 面向整页文档（不支持片段），接受日期或时间戳作为更新日期；若站点尚未配置 `origin`，应跳过生成。

完整参数见 #link("/docs/reference/packages/head/")[`head`] · #link("/docs/reference/packages/feed/")[`feed`] · #link("/docs/reference/packages/sitemap/")[`sitemap`]。
