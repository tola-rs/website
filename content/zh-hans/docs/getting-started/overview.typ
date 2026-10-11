#import "@tola/source:0.0.0": tola-meta
#import "/components/content/lib.typ": callout, code-group
#import "/site/info.typ": version

#tola-meta((
  title: "概览",
  description: "Tola 的基础介绍与一个最小示例",
  order: 0,
))

#title()

= 关于

Tola 是一个开源的静态站点生成器，建立在 #link("https://typst.app/")[Typst] 上。

Typst 是一门现代且强大的排版语言，在其 0.13 版本添加了初步的 html 导出支持，0.14 拥有了类型化的 HTML 元素（#link("https://typst.app/docs/reference/html/typed/")[Typed HTML]），0.15 版本添加了实验性的 Bundle 功能，为数学公式增添了 #link("https://developer.mozilla.org/en-US/docs/Web/MathML")[MathML] 支持......这些使得利用 Typst 编写自己的站点成为可能，并且能利用上其作为现代标记语言所拥有的强大编程能力与丰富生态。

Tola 基于 Typst 的基础上，以静态站点的视角去进行实验性的扩展，提供一组以 `@tola` 为命名空间的内置包。这些功能全部交由用户自行组合。Tola 把整个站点/根程序当作一个 Typst Bundle，进行构建，检查，发布。

如果你不太了解 Typst 的话，简单来说，相比 Markdown，Typst 的表达上限更高：既能完成复杂排版、生成 PDF，也能当高级的 HTML 生成器使用。

= 最小示例

让我们举个例子：

```
tola-demo/
├── content/
│   ├── index.typ
│   ├── about.typ
│   └── guide/
│       └── install.typ
├── site.typ
└── tola.toml
```

#code-group((
  (label: "site.typ", body: [```typst
#import "@tola/source:0.0.0": all-sources
#import "@tola/address:0.0.0": join-route, output-of
    
#for source in all-sources() {
  document(
    output-of(join-route(source.route-segments)),
    title: source.meta.title,
  )[
    #include source.file
  ]
}
```]),
  (label: "install.typ", body: [````typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Install",
  description: "How to install Tola?",
))
    
#title()

Install Tola with Cargo:
    
```sh
cargo install --locked tola
```
    
Verify the install:
    
```sh
tola --version 
```
````]),
  (label: "tola.toml", body: [```toml
[site]
title = "Tola demo"
description = "A minimal Tola site"
language = "en"

[build]
entry = "site.typ"
content-dir = "content"
publish-dir = "public"
```])
))

*入口*: `site.typ` 是站点的入口程序。Tola 以 Bundle 为目标编译它：根程序用 `document` 声明文档，用 `asset` 声明资产，一次编译产出构成整个站点的多个文件。

*内容源*: `content/` 下被发现的小写 `.typ` 文件都是内容源。源里的 `tola-meta((...))` 声明自己的元数据；`title`、`draft`、`permalink`、`order`、`pin` 这些字段没有内置含义，全部由用户处理。`all-sources()` 读取所有内容源，每个 source 除了 `source.meta`，还带有 `path`、`route-segments` 等字段，方便用户自定义逻辑。以 `content/guide/install.typ` 为例：
- `source.meta.title`：源里声明的标题
- `source.path`：`"guide/install.typ"`
- `source.route-segments`：`("guide", "install")`

*路由*: `join-route` 是纯函数，只把 `route-segments` 拼成 site-root route：

#table(
  columns: 2,
  table.header([步骤], [结果]),
  [`source.route-segments`], [`("guide", "install")`],
  [`join-route(...)`], [`"/guide/install/"`],
  [`output-of(...)`], [`"guide/install/index.html"`],
)

`document` 在 bundle 中声明这个输出路径，Tola 最终发布到 `public/guide/install/index.html`，因此可以通过 `https://tola-demo.com/guide/install/` 访问。

Tola 提供 `route-segments` 而非 `route`，使得用户可以方便地编程路由，例如添加前缀后缀，或对每段做 `slugify`：

```typst
#import "@tola/address:0.0.0": slugify
#for source in all-sources() {
  let segments = source.route-segments.map(segment => slugify(segment))
  let output = output-of(join-route(segments))
  document(output, title: source.meta.title)[
    #include source.file
  ]
}
```

让我们再次总结下从例子中发现的事实：

- *源文件不等于页面*。一个源可以被 `document` 发布一次，也可以进入多个文档，甚至在不同前缀下发布，或者被 `source.meta.draft` 等自定义逻辑过滤掉，选择权在根程序（`site.typ`）。
- *文件路径只提供默认路由*。`content/guide/install.typ` 只建议了 `("guide", "install")`，根程序可以换成别的地址，也可以用 `source.meta.permalink` 等自定义逻辑进行覆盖。

= 编译流程

```mermaid
flowchart LR
  source["content/*.typ"] --> root["site.typ"] --> bundle["Typst Bundle"] --> output["public/"]
```

= 注意
- Typst 截至目前版本（#version.typst）的 HTML 特性仍处于积极开发中。
- Typst 截至目前版本（#version.typst）的 Bundle 导出仍属于实验特性。
- Typst 进行静态编程，生成内容与组织结构，网页的动态需求仍需 JS 脚本。
- Tola 仍处于激进开发迭代阶段。

= 接下来

- #link("/docs/getting-started/installation/")[安装]：安装 Tola 并验证命令。
