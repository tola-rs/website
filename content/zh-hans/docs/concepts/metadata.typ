#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "内容元数据",
  description: "用 tola-meta 声明页面字段，在入口中通过 @tola/schema 校验并使用。",
  order: 20,
))

#title()

在站点开发中，源文件通常需要附带标题、发布日期、排序权重或草稿标记供入口程序读取。Tola 通过 `tola-meta` 声明这些字段，但不内置固定含义——所有字段规则都由你的站点或主题 schema 决定。

= 在源文件中声明

在每个内容源文件的顶层调用一次 `tola-meta`，或调用一个从外部导入的包装函数（例如主题提供的元数据函数）：

```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "安装指南",
  draft: true,
))

#title()
```

#callout[
  `tola-meta` 必须放在顶层普通代码中。`context` 块和带选择器的 `show` 规则要到文档排版阶段才求值，写在里面的元数据不会被入口扫描到。另外，通过 `import` 引入的文件如果在自身顶层写了 `tola-meta`，那份元数据属于被导入的文件本身。
]

= 用 `@tola/schema` 校验与筛选

入口程序通过 `all-sources()` 获取所有源文件记录，再用 `@tola/source` 的 `parse-sources` 结合 `@tola/schema` 统一校验。`parse-sources` 会检查字段类型、填充默认值，并在校验失败时精确指出出错的源文件：

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
```

这里有两点需要注意：

- *默认拒绝未知字段*：`schema((...))` 默认会报错拦截未声明的字段，如需透传扩展字段可加上 `unknown: "keep"`。
- *草稿也会参与读取与校验*：`parse-sources` 先于 `filter` 执行，如果把 `draft: true` 错写成字符串 `"true"`，`tola check` 会直接报类型错误；草稿源文件中的 Typst 语法错误同样会使构建失败。

= 常用字段类型与日期

除了基础类型，`@tola/schema` 还提供以下常用组合：

- `optional(type, default: ...)`：允许字段缺失并提供默认值；若字段存在但类型不合法，不会回退到默认值，而是直接报错。
- `nullable(type)`：允许字段显式传入 `none`。
- *日期与时间*：日历日期用 `date`，带时间的日期用 `timestamp`，只含年份或年月用 `partial-date`；若想同时接受日期和时间戳，可用 `union(date, timestamp)`。校验后的 `timestamp` 提供 `.rfc3339` 字段，可直接传给 `@tola/feed` 或 `@tola/sitemap`。

= 主题字段约定

`draft`、`order`、`permalink`、`description` 等字段并不是 Tola 引擎硬编码的关键词，而是主题与站点入口自己的约定。例如本站主题会在校验后跳过草稿，按 `order` 排序同级文档，并用 `permalink` 覆盖默认路由。切换主题前，先确认目标主题的 schema 接受哪些字段。

同一份经过校验和筛选的页面列表，除了驱动正文输出，也可以直接复用在菜单、订阅源和站点地图中。具体写法见 #link("/docs/guide/metadata-and-navigation/")[元数据与导航] 与 #link("/docs/reference/packages/schema/")[`@tola/schema` 参考]。
