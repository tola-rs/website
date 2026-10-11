#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "用元数据生成菜单",
  description: "筛掉草稿，为发布的页面生成菜单。",
  order: 0,
))

#title()

继续修改 #link("/docs/getting-started/first-site/")[第一个站点]。菜单会列出首页和安装指南，草稿页先留在本地。

= 声明元数据

用下面的内容替换首页和安装指南，再添加一份草稿。每个文件在顶层调用一次 `tola-meta`。

#code-group((
  (label: "content/index.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "我的站点"))
#title()

欢迎访问。
```]),
  (label: "content/guide/install.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "安装指南"))
#title()

运行 `tola --version` 查看版本。
```]),
  (label: "content/draft.typ", body: [```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((title: "待完成的文章", draft: true))
#title()
```]),
))

= 筛选页面

将下面的导入合并到 `site.typ` 开头，再用页面列表和新循环替换原来的 `for source in all-sources()` 循环。保留 `#set text(...)` 和 404 页。

```typst
#import "@tola/address:0.0.0": join-route, output-of, output-url
#import "@tola/schema:0.0.0": optional, schema
#import "@tola/source:0.0.0": all-sources, parse-sources

#let fields = schema((
  title: str,
  draft: optional(bool, default: false),
))

#let pages = {
  parse-sources(all-sources(), fields)
    .filter(source => not source.meta.draft)
    .map(source => (
      source: source,
      output: output-of(join-route(source.route-segments)),
    ))
}

#for page in pages {
  document(page.output, format: "html", title: page.source.meta.title)[
    #html.nav[
      #list(..pages.map(target => link(output-url(target.output))[
        #target.source.meta.title
      ]))
    ]
    #include page.source.file
  ]
}
```

`parse-sources` 按规则检查每个源，并为省略的 `draft` 填入 `false`。`filter` 决定是否发布草稿。因为校验在筛选之前，草稿也要符合 schema。把 `draft: true` 写成 `draft: "true"` 时，`tola check` 会报类型错误。

运行 `tola dev`。菜单链接到首页和安装指南，访问 `/draft/` 会返回 404。把草稿的 `draft` 改成 `false` 后，`/draft/` 及其菜单链接就会一同发布。
