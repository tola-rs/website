#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "路由与 URL",
  description: "理清源路径、站点路由、Bundle 输出路径与浏览器 URL 的转换关系。",
  order: 30,
))

#title()

Tola 严格区分「源文件在哪」「生成到哪个文件」和「浏览器访问什么地址」。理清这几个概念，能避免部署到子路径或跨模块引用时路径出错。

= 路径层次对照

假设站点部署在 `https://example.com/notes/`（即 `base-path = "/notes/"`），`content/guide/install.typ` 在默认入口中对应以下路径：

#table(
  columns: (auto, 1fr),
  table.header([概念], [示例值]),
  [源路径（`source.path`）], [`guide/install.typ`（相对于 `content-dir`）],
  [路由分段（`source.route-segments`）], [`("guide", "install")`],
  [站点路由（route）], [`/guide/install/`],
  [Bundle 输出路径（output）], [`guide/install/index.html`（相对于发布目录）],
  [磁盘发布文件], [`public/guide/install/index.html`],
  [浏览器完整地址], [`https://example.com/notes/guide/install/`],
)

`source.path` 适合在脚本或入口里判断源文件归属；`source.file` 是原生 Typst 路径，直接传给 `include`。`source.route-segments` 只是文件布局给出的默认分段，你可以按需要加前缀、替换成 `permalink`，或先对每段调用 `slugify`。

= 路由与输出路径转换

`join-route` 把分段数组拼成首尾带 `/` 的路由，`output-of` 把路由转换为 Bundle 输出路径，供 `document(...)` 或 `asset(...)` 使用；`route-of` 则执行逆向转换：

#table(
  columns: (1fr, 1fr),
  table.header([传给 `output-of` 的路由], [Bundle 输出路径]),
  [`/`], [`index.html`],
  [`/guide/`], [`guide/index.html`],
  [`/guide`], [`guide`],
  [`/sitemap.xml`], [`sitemap.xml`],
)

注意结尾斜杠的区别：`/guide/` 代表目录页 `guide/index.html`，而没有尾斜杠的 `/guide` 代表名为 `guide` 的文件。此外，`content/about.typ` 与 `content/about/index.typ` 默认都会算出 `("about",)` 分段并映射到 `about/index.html`；同时存在这两份文件会触发输出冲突，移走其一或在入口中为它指定不同输出路径即可解决。

= 生成浏览器 URL

当站点部署在子路径或需要生成带域名的绝对地址时，在 `tola.toml` 中配置 `origin` 和 `base-path`：

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

`origin` 填写协议、域名和可选端口；`base-path` 必须首尾带 `/`（部署在根域名时为 `"/"`）。在代码里不要手动拼接部署前缀，而是使用 `@tola/address`：

```typst
#import "@tola/address:0.0.0": output-url, route-url
#import "@tola/site:0.0.0": site

#let output = "guide/install/index.html"
#let browser-path = output-url(output) // /notes/guide/install/
#let full-url = output-url(output, origin: site.origin)

#assert.eq(browser-path, route-url("/guide/install/"))
#assert.eq(full-url, "https://example.com/notes/guide/install/")
#link(browser-path)[安装指南]
```

使用原则：

- *已知 Bundle 输出路径*（如 `page.output` 或钩子生成的文件）：用 `output-url`。
- *已知解码后的站点路由*（如 `"/guide/install/"`）：用 `route-url`。
- 两者都会自动加上 `site.base-path` 并对特殊字符做百分号编码（例如路由 `/Hello World/` 生成 `/notes/Hello%20World/`），而磁盘文件名仍保持未编码状态。
- 片段锚点（如 `#intro`）应拼接在函数返回的 URL 之后。
- 如果拿到的是一个已做过百分号编码的站内路径，去掉部署前缀后可用 `decode-url-path` 解码一次，再交回给 `output-of`。

= 静态资源 URL

引用 `[assets]` 中声明的静态文件时，使用 `asset-url`（如 `asset-url("/media/logo.svg")`）：

- 它会检查该路径是否确实在 `[assets]` 中声明启用，然后加上 `base-path`，并在开启 `assets.cache-busting` 时附带 `?h=…` 查询参数。
- 与 `output-url` 不同，即使静态文件恰好叫 `index.html`，`asset-url` 也会保留完整文件名而不会折叠成目录地址。
- 通过 `site.typ` 顶层 `asset(...)` 或 `[[hooks.generate-outputs]]` 产生的文件属于 Bundle / 构建输出而非 `[assets]` 静态配置，引用它们请使用 `output-url`。

= 站点根目录与模块路径

Typst 代码中以 `/` 开头的路径含义取决于所在位置：

- *站点入口或内容文件*：`/` 指向站点根目录；模块若需读取站点下的文件（如 `data/menu.json`），使用 `@tola/site` 的 `project-path("data/menu.json")`。
- *模块内部*：`/` 指向该模块包根目录；插入站点内容源文件必须使用 `source.file`。

模块声明的静态资源在发布时会自动挂载到 `/_tola-modules/<模块别名>/` 下（加上 `base-path` 后如 `/notes/_tola-modules/blog/theme.css`）。在模块代码中，用 `get-module().assets.files` 获取编译期输入路径，用 `get-module().assets.urls` 获取已附带部署前缀的浏览器 URL。

完整函数签名与参数说明见 #link("/docs/reference/packages/address/")[`@tola/address` 参考]，或运行 `tola help --lang zh "@tola/address"`。
