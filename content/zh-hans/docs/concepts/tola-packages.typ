#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "Tola 内置包",
  description: "了解 @tola/* 内置包、@tola-modules/* 模块包与 @preview/* 社区包的导入方式与分工。",
  order: 50,
))

#title()

Tola 随附一组 `@tola/*` 内置 Typst 包，用于读取站点配置、校验元数据、计算路由、处理图片与生成订阅，无需额外安装即可导入。

= 包命名空间与导入版本

Typst 代码中常见的三种包前缀分别对应不同来源：

- `@tola/<名称>:0.0.0`：Tola 内置包，导入版本固定为 `0.0.0`。
- `@tola-modules/<别名>:0.0.0`：在站点 `tola.toml` 中注册的本地或远程模块（版本同样为 `0.0.0`）。
- `@preview/<名称>:<版本>`：来自 Typst Universe 的第三方社区包。

```typst
#import "@tola/address:0.0.0": join-route, route-url
#import "@tola/source:0.0.0": all-sources

#let guide = all-sources().find(source => source.path == "guide/install.typ")
#let route = join-route(guide.route-segments)
#link(route-url(route))[阅读安装指南]
```

如果入口程序为某个页面覆写了输出路径，请改用 `output-url(page.output)` 生成链接，避免和源文件默认路由脱节。

#callout[
  如果同一文件里既需要调用 Typst 原生的 `document(...)` 函数来生成页面，又要用到 `@tola/document` 的查询函数，请按需导入具体成员（如 `#import "@tola/document:0.0.0": current-document, headings`）或给模块起别名（`as doc`），避免模块名遮蔽全局的 `document` 函数。
]

= 内置包一览

#table(
  columns: (auto, 1fr),
  table.header([包名], [主要用途]),
  [`@tola/source`], [发现 `content/` 下的源文件，声明（`tola-meta`）并批量解析源元数据。],
  [`@tola/schema`], [定义字段类型与默认值，校验元数据、日期格式与站内路径。],
  [`@tola/address`], [生成 slug，在路由、Bundle 输出路径与浏览器 URL 之间转换。],
  [`@tola/site`], [读取 `[site]` 与 `[options]` 配置，通过 `project-path` 定位项目文件。],
  [`@tola/module`], [在模块或站点内通过 `get-module` 读取模块别名、选项与资产。],
  [`@tola/document`], [在 `context` 中查询当前文档、标题列表（`headings`）与链接引用（`references`）。],
  [`@tola/collection`], [对页面列表进行分组、建索引、查找上下篇（`adjacent`）与层级关系。],
  [`@tola/datalog`], [通过事实与规则查询递归关系（如页面可达性）。],
  [`@tola/image`], [获取图片信息、按需缩放裁剪，并生成响应式 `img` / `srcset`。],
  [`@tola/icon`], [渲染配置或模块声明的 SVG 图标或生成图标 URL。],
  [`@tola/code`], [结合明暗配色主题高亮 `raw` 代码块，提供内置语言语法与样式表。],
  [`@tola/head`], [生成 `<head>` 元标签、规范链接（`canonical`）、Open Graph 与 Twitter 卡片。],
  [`@tola/feed`], [生成 RSS / Atom 订阅文件（`feed.xml`）。],
  [`@tola/sitemap`], [生成包含绝对 URL 的 `sitemap.xml`。],
  [`@tola/diagnostic`], [在 Typst 代码中直接触发结构化诊断信息。],
  [`@tola/hash` / `@tola/uuid`], [计算 BLAKE3 摘要以及生成规范化 UUID v5。],
)

本地运行 `tola help --lang zh "@tola/address"` 可以直接查看任意内置包与成员的完整签名；具体写法与完整示例见 #link("/docs/guide/site-data/")[站点数据与内容查询]、#link("/docs/guide/page-presentation/")[图片、图标与代码] 与 #link("/docs/reference/packages/")[内置包参考]。
