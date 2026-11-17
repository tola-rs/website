#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "站点数据与内容查询",
  description: "对页面分组建索引、生成本页目录、查询反向链接，以及用 Datalog 和 tola query 抽取数据。",
  order: 10,
))

#title()

#callout[
  在页面中调用 `current-source()` 返回当前源文件信息；同一份内容被编排进多篇文档时，`current-source()` 保持不变，而在 `context` 中调用 `current-document()` 会返回各自对应的输出路径与路由。全部内置包清单见 #link("/docs/concepts/tola-packages/")[Tola 内置包]。
]

= 页面分组与索引

`@tola/collection` 适合对入口选出的页面列表做整理：

```typst
#import "@tola/collection:0.0.0": group-by

#let pages = (
  (title: "第一篇", section: "笔记"),
  (title: "第二篇", section: "笔记"),
  (title: "安装", section: "指南"),
)

#for (section, members) in group-by(pages, key: page => page.section) [
  #heading(section)
  #list(..members.map(page => page.title))
]
```

- 一对一唯一索引：用 `index-by`（遇到重复键会直接报错）。
- 按单值分组：用 `group-by`。
- 一篇文章挂多个标签（一对多分组）：用 `group-by-keys`，让回调返回键数组。
- 面包屑与树形子孙：配置父键回调后，可使用 `lineage` 与 `descendants`。

= 本页标题目录

在文档模板的 `document(...)` 正文内，使用 `@tola/document` 的 `headings()` 读取当前文档标题并生成目录：

```typst
#import "@tola/document:0.0.0": headings

#context {
  let sections = headings(depth: 2).filter(section => section.outlined)
  html.nav(aria-label: "本页目录")[
    #list(..sections.map(section => link(section.location, section.body)))
  ]
}
```

`headings(depth: 2)` 只保留实际层级不超过 2 的标题；过滤 `section.outlined` 可与 Typst 原生大纲保持一致，跳过不需要进目录的标题。把 `section.location` 传给 `link` 时，Tola 会自动在导出的 HTML 中为目标标题生成锚点。

= 反向链接（谁链接了当前页）

`references()` 可以在 `context` 中查询文档间的 Typst `link` 与 `ref`。把文章主体放进带 `<article-body>` 标签的容器内，在容器外侧即可列出引用当前页的其他文档：

```typst
#import "@tola/document:0.0.0": references

#context {
  let seen = ()
  for item in references(to: auto, from-within: <article-body>) {
    let output = item.document.output
    if output in seen { continue }
    seen.push(output)
    link(item.document.location)[#item.document.route]
  }
}
```

两点注意：

- 标题标签只选中标题本身，包住正文的容器（如 `html.main` 或 `html.article`）才适合作为 `from-within` 范围，并且要把生成反向链接的列表放在该范围之外。
- 同一来源页内若多次链接当前页，查询会返回多条记录，按 `document.output` 去重即可得到唯一的来源页列表。

= 用 Datalog 查询递归关系

当需要查询多跳链接（如 A 链接到 B、B 链接到 C，找出从 A 出发可达的所有页面）时，可以用 `@tola/datalog` 声明事实与推理规则：

```typst
#import "@tola/datalog:0.0.0": database, relation, rule, var

#let link-to = relation("link-to", 2)
#let reachable = relation("reachable", 2)
#let (x, y, z) = ("x", "y", "z").map(var)

#let db = database(
  (link-to, reachable),
  facts: (
    link-to.atom("home", "guide"),
    link-to.atom("guide", "install"),
  ),
  rules: (
    rule(reachable.atom(x, y), link-to.atom(x, y)),
    rule(reachable.atom(x, z), reachable.atom(x, y), link-to.atom(y, z)),
  ),
)

#let rows = db.query(select: (y,), where: (reachable.atom("home", y),))
#list(..rows.map(row => row.first()))
```

页面会输出 `guide` 和 `install`：`database` 的第一个参数须列出所有关系（包括仅由规则推导的关系），在关系上调用 `.atom(...)` 构造事实与条件，最后通过 `db.query(...)` 取出结果。实际站点中，可以把 `references()` 查出的站内链接填入 `facts`。

= 用 `tola query` 向脚本导出数据

不构建网页时，也可以把站点数据放入 `#metadata(...)` 交给命令行或外部脚本读取。在项目下新建 `tools/model.typ`：

```typst
#import "@tola/source:0.0.0": all-sources
#metadata(all-sources().map(source => source.path)) <model>
```

在站点根目录运行：

```sh
tola query ./tools/model.typ --label model --json --pretty
```

查询不会运行构建钩子，也不会修改发布目录。如果模块在 `tola-module.toml` 中声明了具名查询（见 #link("/docs/guide/module-publishing/")[模块查询、命令与打包发布]），则可直接运行 `tola query <别名>.<查询名>`，加 `-i` 还可在终端交互筛选记录。

完整 API 见 #link("/docs/reference/packages/collection/")[`collection`] · #link("/docs/reference/packages/document/")[`document`] · #link("/docs/reference/packages/datalog/")[`datalog`]。
