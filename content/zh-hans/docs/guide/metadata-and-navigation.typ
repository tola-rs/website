#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout, code-group

#tola-meta((
  title: "元数据、排序与导航",
  description: "过滤草稿、按权重排序，并生成全站导航菜单与上下篇链接。",
  order: 0,
))

#title()

基于 #link("/docs/getting-started/first-site/")[第一个站点] 的目录结构，下面展示如何用 `tola-meta` 声明元数据、排除草稿页，并用同一份有序页面列表同时生成顶栏导航与上下篇链接。

= 声明文章元数据

更新首页和安装指南，并新增一篇标记为草稿的源文件。每个文件在顶层调用一次 `tola-meta`：

#code-group((
  (label: "content/index.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "我的站点", order: 1))
#title()

欢迎访问。
```]),
  (label: "content/guide/install.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "安装指南", order: 2))
#title()

运行 `tola --version` 查看版本。
```]),
  (label: "content/draft.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "待完成的文章", draft: true))
#title()
```]),
), label: "内容源文件")

= 校验、排序并生成导航

更新站点入口 `site.typ`：先通过 `parse-sources` 校验全部源文件的字段，再过滤掉草稿、按 `(order, id)` 排序，最后在渲染每个页面时用 `@tola/collection` 的 `adjacent` 计算上一篇和下一篇。

```typst
#import "@tola/address:0.0.0": join-route, output-of, output-url
#import "@tola/collection:0.0.0": adjacent
#import "@tola/schema:0.0.0": non-empty, optional, schema, trim
#import "@tola/source:0.0.0": all-sources, parse-sources

#let fields = schema((
  title: non-empty(trim(str)),
  order: optional(int, default: 0),
  draft: optional(bool, default: false),
))

#let pages = {
  parse-sources(all-sources(), fields)
    .filter(source => not source.meta.draft)
    .sorted(key: source => (source.meta.order, source.id))
    .map(source => (
      source: source,
      output: output-of(join-route(source.route-segments)),
    ))
}

#for page in pages {
  let neighbors = adjacent(pages, page.output, key: item => item.output)
  document(page.output, format: "html", title: page.source.meta.title)[
    #html.nav[
      #list(..pages.map(target => link(output-url(target.output))[
        #target.source.meta.title
      ]))
    ]
    #include page.source.file
    #html.nav[
      #if "before" in neighbors [
        上一篇：#link(output-url(neighbors.before.output))[#neighbors.before.source.meta.title]
      ]
      #if "after" in neighbors [
        下一篇：#link(output-url(neighbors.after.output))[#neighbors.after.source.meta.title]
      ]
    ]
  ]
}

#document("404.html", format: "html")[找不到页面。]
```

说明：

- *用同一个 `pages` 驱动导航与相邻页*：菜单顺序与「上一篇 / 下一篇」顺序完全来自同一份排序结果，而不是靠文件名猜顺序；当 `order` 相同时，用 `source.id` 稳定打破平局。
- *校验先于过滤*：草稿源文件同样需要符合 schema（例如把 `draft: true` 写成字符串 `"true"` 时，`tola check` 会直接报错）。

#callout[
  运行 `tola dev` 后，顶栏菜单只会显示「我的站点」和「安装指南」，访问 `/draft/` 会返回 404；把 `draft` 改为 `false` 后，该页面和导航项会一同发布。
]

如果需要按栏目分组、提取页面标题目录或查询反向链接，可以继续阅读 #link("/docs/guide/site-data/")[站点数据与内容查询]。
