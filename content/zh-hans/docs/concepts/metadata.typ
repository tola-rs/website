#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "内容元数据",
  description: "用 tola-meta 声明字段，由入口或主题校验并使用。",
  order: 20,
))

#title()

= 声明字段

元数据是入口要读取的字段，例如标题、发布日期和草稿状态。每份源可以用 `tola-meta` 声明一次。在新站点里，把下面的内容保存为 `content/install.typ`。

```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "安装指南",
  draft: true,
))

= 安装指南
```

把声明写在正文顶层，或调用一个导入的函数来声明。`context` 和选择器式的 `show` 规则在文档排版期间才求值，里面的调用无法登记源元数据。导入文件里直接写的顶层声明属于那个文件。

= 校验字段

入口通过 `all-sources()` 取得各份源的 `meta`。`parse-sources` 检查字段类型、补默认值，报错时指出源文件。用下面的代码替换新站点的 `site.typ`。

```typst
#import "@tola/address:0.0.0": join-route, output-of
#import "@tola/schema:0.0.0": non-empty, optional, schema, trim
#import "@tola/source:0.0.0": all-sources, parse-sources

#let fields = schema((
  title: non-empty(trim(str)),
  draft: optional(bool, default: false),
))

#let pages = {
  parse-sources(all-sources(), fields)
    .filter(source => not source.meta.draft)
}

#for source in pages {
  document(
    output-of(join-route(source.route-segments)),
    format: "html",
    title: source.meta.title,
  )[
    #include source.file
  ]
}

#document("404.html", format: "html")[找不到页面。]
```

从站点根目录运行 `tola build`。`filter` 会排除草稿，因此输出只有 `public/404.html`。删掉 `draft: true` 后再构建，`public/install/index.html` 就会出现。

标题必须是非空字符串。省略 `draft` 时取 `false`，写成 `"true"` 会报类型错误。草稿也要通过校验，因为 `filter` 在 `parse-sources` 之后执行。

= 字段约定

`tola-meta` 接收字典。`draft`、`order`、`permalink` 的含义由站点入口或主题决定。比如官网主题在校验后筛掉草稿，用 `order` 排同组文档，并用 `permalink` 覆盖默认路由。更换主题时，查一下新主题接受哪些字段。

同一份已选页面列表还可以用来生成菜单、站点地图或订阅。#link("/docs/guide/metadata-and-navigation/")[草稿与导航教程]有完整示例。
