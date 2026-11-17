#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "内置包",
  description: "按名称查询每个 @tola 包的导出成员、参数、返回值与示例。",
  order: 10,
))

#title()

`@tola/*` 是随 Tola 提供的 Typst 包，构建站点时可以直接导入，无需另行安装。

这些包提供模板常用的工具，例如校验 metadata、给页面分组，也能读取站点配置、生成 URL、发布缩放后的图片。图片处理和递归 Datalog 查询计算量较大，内置时也考虑了性能。

= 包目录

#table(
  columns: (auto, 1fr),
  table.header([内置包], [用途]),
  [#link("/docs/reference/packages/site/")[`site`]], [读取站点配置，定位站点根目录下的文件。],
  [#link("/docs/reference/packages/module/")[`module`]], [读取模块实例的选项和静态资源。],
  [#link("/docs/reference/packages/source/")[`source`]], [列出内容源，读取当前源，声明和检查源文件的元数据。],
  [#link("/docs/reference/packages/schema/")[`schema`]], [定义数据规则，校验并转换字典、数组等值。],
  [#link("/docs/reference/packages/address/")[`address`]], [生成 slug，在路由、输出路径和浏览器 URL 之间转换。],
  [#link("/docs/reference/packages/collection/")[`collection`]], [按键索引、分组和筛选数组，查找相邻成员或父子节点。],
  [#link("/docs/reference/packages/document/")[`document`]], [读取当前输出文档，查询标题和链接引用。],
  [#link("/docs/reference/packages/datalog/")[`datalog`]], [用事实和规则查询关系，例如沿页面链接查找可达页面。],
  [#link("/docs/reference/packages/image/")[`image`]], [读取图片信息，缩放并发布图片，生成响应式 HTML 图片。],
  [#link("/docs/reference/packages/icon/")[`icon`]], [将已配置的图标用作内联 SVG、SVG 字节或图标 URL。],
  [#link("/docs/reference/packages/code/")[`code`]], [渲染语法高亮的代码，提供语法、主题和代码样式表。],
  [#link("/docs/reference/packages/head/")[`head`]], [生成 HTML 头部元数据、规范链接和社交分享卡片。],
  [#link("/docs/reference/packages/feed/")[`feed`]], [生成 RSS、Atom 或 JSON Feed。],
  [#link("/docs/reference/packages/sitemap/")[`sitemap`]], [为指定页面生成 XML 站点地图。],
  [#link("/docs/reference/packages/hash/")[`hash`]], [计算 BLAKE3 摘要，将字节转换为十六进制文本。],
  [#link("/docs/reference/packages/uuid/")[`uuid`]], [生成 UUID v5，或将已有 UUID 转为标准格式。],
  [#link("/docs/reference/packages/diagnostic/")[`diagnostic`]], [在 Typst 中报告警告和错误，附上源码位置和修复提示。],
)

= 查找 API

在终端把函数名放在包名后，就能查看签名、参数和示例。例如：

```sh
tola help --lang zh "@tola/address" output-url
```

在用 `tola init` 创建的站点中，把下面两行写入 `content/index.typ`。从站点根目录运行 `tola build`，打开 `public/index.html`。使用默认配置时，链接指向 `/404.html`，即默认模板生成的 404 页。

```typst
#import "@tola/address:0.0.0": output-url
#link(output-url("404.html"))[查看 404 页]
```

更多用法见 #link("/docs/guide/site-data/")[站点数据与内容查询] 与 #link("/docs/guide/page-presentation/")[图片、图标与代码]。
