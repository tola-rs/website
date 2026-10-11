#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "查询站点内容",
  description: "从配置、源文件和当前文档取数据，再按需求分组。",
  order: 0,
))

#title()

= 从哪里读数据

#table(
  columns: (auto, 1fr),
  table.header([包], [常用场景]),
  [`@tola/site`], [读站点配置和 `site.options`，从模块访问项目路径。],
  [`@tola/module`], [读模块实例的别名、选项和资产。],
  [`@tola/source`], [发现源文件，声明和解析源元数据。],
  [`@tola/schema`], [校验字典、日期和路径，为缺少的字段设默认值。],
  [`@tola/address`], [从路由算输出路径，从输出算浏览器地址。],
  [`@tola/collection`], [对已选页面分组、建立索引、找相邻项或遍历层级。],
  [`@tola/datalog`], [将记录组织成事实和规则，查询递归关系。],
  [`@tola/document`], [查询当前文档、标题与引用。],
)

源文件的身份由 `current-source()` 给出。同一个源被放进两份文档时，源保持相同，`current-document()` 会随输出而变。后者在 `context` 中调用。

= 页面分组

把下面的代码放到 `content/index.typ`，然后从站点根目录运行 `tola build`。`public/index.html` 会显示「笔记」和「指南」两组。在模板中使用时，可以把 `pages` 换成入口选出的页面。

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

`group-by` 为每个成员选一个分组键。若一篇文章要出现在它的每个标签下，用 `group-by-keys`，让回调返回一组键。若按唯一键找单页，用 `index-by`，重复键会报错。

= 查询本页标题

把下面这段放在 `content/index.typ` 中的正文标题前。运行 `tola build` 后，`public/index.html` 会显示指向这些标题的目录。`headings` 只读取包含此调用的文档，`location` 可以直接传给 `link`。

```typst
#import "@tola/document:0.0.0": headings

#context {
  let sections = headings(depth: 2).filter(section => section.outlined)
  list(..sections.map(section => link(section.location, section.text)))
}
```

= 查询可达页面

如果 A 链接到 B，B 又链接到 C，想列出从 A 能到达的所有页面，可以用 `@tola/datalog`。把下面的代码放在 `content/index.typ`，从站点根目录运行 `tola build`。示例先记录直接链接，再用两条规则查找可达页面。

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

页面会列出 `guide` 和 `install`。第一条规则记录一步能到的页面，第二条把已经可达的页面再延长一跳。`select` 决定返回的列。实际站点可以从 `references()` 取链接，再填入事实表。

`database` 的第一个参数声明要用到的关系，包括还没有事实的关系。在关系值上调用 `atom`，例如 `link-to.atom("home", "guide")`。在 `database(...)` 返回的值上调用 `query`。

#link("/docs/reference/packages/collection/")[`collection`] · #link("/docs/reference/packages/document/")[`document`] · #link("/docs/reference/packages/datalog/")[`datalog`]
