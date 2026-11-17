#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "静态资源",
  description: "区分编译期输入与浏览器资源，发布图片、样式表、脚本与字体。",
  order: 40,
))

#title()

在 Typst 代码里读取一个文件，并不会自动把它发布到网站上——`read(...)`、`json(...)` 和 `image(...)` 读取的只是编译期输入。需要由浏览器直接请求的样式表、脚本、字体、下载文件或图片原图，必须显式声明为静态资源或构建产物。

= 声明静态资源

在 `tola.toml` 的 `[assets]` 下用 `files` 映射单个文件，或用 `trees` 映射整个目录树：

```toml
[assets]
cache-busting = true
files = [{ source = "static/logo.svg", url = "/media/logo.svg" }]
trees = [{ source = "static/styles", url-prefix = "/styles" }]
```

构建后，`static/logo.svg` 发布为 `public/media/logo.svg`，`static/styles/main.css` 发布为 `public/styles/main.css`。

目录树规则：

- 可用 `include` 与 `exclude` 模式筛选目录树内的文件（路径从站点根或模块根起算）。省略 `include` 默认包含整个目录（`["."]`），设为 `[]` 则不选任何文件。
- 当同一个源文件既匹配 `files` 又落入 `trees` 时，由精确的 `files` 声明接管（即便该条目的启用开关关闭，也不会回退到重叠的 `trees` 中被意外发布）。

== 树内的文件符号链接

默认情况下目录树会跳过符号链接。需要发布指向普通文件的符号链接时，在该条目启用 `follow-file-symlinks = true`：

```toml
[[assets.trees]]
source = "static/downloads"
url-prefix = "/downloads"
follow-file-symlinks = true
```

Tola 会按链接本身的路径与名称发布目标文件的内容（`include` / `exclude` 也按链接路径匹配）。指向目录的链接或断链会直接报错；模块内的链接目标不得越出模块目录，`--pure` 构建中的链接目标不得越出站点目录。

= 在页面中引用

引用 `[assets]` 声明的文件时，使用 `@tola/address` 的 `asset-url`：

```typst
#import "@tola/address:0.0.0": asset-url

#html.link(rel: "stylesheet", href: asset-url("/styles/main.css"))
#html.img(src: asset-url("/media/logo.svg"), alt: "站点标志")
```

传入 `asset-url` 的是配置中声明的站点路径（不带部署前缀）。函数会校验资源是否存在、补上 `site.base-path`，并在开启 `cache-busting` 时附加 `?h=…` 查询串。文件内容变化后浏览器会立即拿到新 URL，而磁盘上的文件名依然保持不变。

#callout[
  Tola 不会自动打包 JavaScript，也不会改写 CSS 里的 `url(...)`。如果 `/notes/styles/main.css` 中引用了 `url("../media/logo.svg")`，浏览器会以样式表的发布地址为基准请求 `/notes/media/logo.svg`。
]

= 图片与字体

- *图片*：在排版中嵌入矢量或位图可使用 Typst 原生 `image(...)`；需要原封不动交付原图时用 `html.img(src: asset-url(...))`；如果只需要缩放裁切后的衍生图或响应式 `srcset`，请使用 `@tola/image`（见 #link("/docs/guide/page-presentation/")[图片、图标与代码]），原图放在 `[assets]` 之外即可避免泄露或冗余发布。
- *字体*：编译器字体与网页字体彼此独立。`[typst.fonts]` 仅配置 Typst 编译器在生成 `html.frame`（如 SVG 图表）时可用的字体，可通过 `tola inspect fonts` 查看（注意 `--pure` 模式会排除主机系统字体，须使用项目或模块提供的字体路径）。浏览器正文使用的 Web 字体须通过 `[assets]` 发布，再在 CSS 中用 `@font-face` 加载。

= 在代码中生成资源

如果需要在构建期用 Typst 代码直接输出静态文件（例如站内数据 JSON），可以在入口顶层调用 `asset(...)`：

```typst
#import "@tola/address:0.0.0": output-url

#asset("data/site.json", json.encode((title: "我的站点")))
```

构建会写入 `public/data/site.json`。因为它是 Bundle 输出而非 `[assets]` 配置条目，引用它时使用 `output-url("data/site.json")`。需要由外部脚本或工具生成文件时，见 #link("/docs/concepts/hooks/")[构建钩子]。

完整配置字段见 #link("/docs/reference/config/assets/")[`[assets]` 配置参考]。
