#import "@tola/source:0.0.0": tola-meta
#import "@tola/address:0.0.0": output-url

#tola-meta((
  title: "站点路径",
  description: "区分 Typst 输入路径、Bundle 输出、站点路由和浏览器地址。",
  order: 40,
))

#title()

#let address-reference = output-url("zh-hans/docs/reference/packages/address/index.html")

= 路径对照

假设站点部署在 `https://example.com/notes/`。默认入口按下面的方式处理 `content/guide/install.typ`。

#table(
  columns: (auto, 1fr),
  table.header([值], [例子]),
  [相对内容目录的源路径], [`guide/install.typ`],
  [文件布局给出的路由分段], [`("guide", "install")`],
  [站点路由], [`/guide/install/`],
  [Bundle 输出路径], [`guide/install/index.html`],
  [发布目录中的文件], [`public/guide/install/index.html`],
  [浏览器地址], [`https://example.com/notes/guide/install/`],
)

`source.path` 适合判断源文件归属，`source.file` 是可传给 `include` 的 Typst 路径。`source.route-segments` 只是文件布局提供的默认分段，可以替换、加前缀，或先对每段调用 `slugify`。

= 路由与输出

`join-route` 把分段拼成以 `/` 开头和结尾的路由。`output-of` 将路由转换成 Bundle 输出路径，供 `document` 写文档。`asset` 也直接接收输出路径。输出相对于发布目录，省去开头的 `/` 和部署前缀。

#table(
  columns: (1fr, 1fr),
  table.header([传给 `output-of` 的路由], [结果]),
  [`/`], [`index.html`],
  [`/guide/`], [`guide/index.html`],
  [`/guide`], [`guide`],
  [`/sitemap.xml`], [`sitemap.xml`],
)

`route-of("guide/index.html")` 返回规范路由 `/guide/`。`content/about.typ` 和 `content/about/index.typ` 都给出 `("about",)`，因此默认入口会为它们声明同一个输出。把其中一份源移到别处，或在入口里为它选一个独立输出，即可解决冲突。

= 生成 URL

把以下配置加到 #link("/docs/getting-started/first-site/")[第一个站点]的 `tola.toml`。已有 `[site]` 时，把两项写入现有表。

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

`origin` 写协议和域名，可以带端口。`base-path` 写部署路径，首尾都有 `/`。部署到域名根目录时用 `"/"`。`@tola/site` 的 `site.url` 是由两者得出的站点地址。把首页原来的链接换成下面这段代码，避免旧链接继续指向没有部署前缀的地址。

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

运行 `tola build` 后，`public/index.html` 中的链接指向 `/notes/guide/install/`。文件仍写到 `public/guide/install/index.html`。

手上有输出路径用 #link(address-reference + "#ref-packages-address-output-url-function")[`output-url`]，已有路由用 #link(address-reference + "#ref-packages-address-route-url-function")[`route-url`]。两者都在生成 URL 时加前缀并编码。比如路由 `/Hello World/` 生成 `/notes/Hello%20World/`，输出文件名仍保留空格。已有百分号编码的站内路径，可以在去掉部署前缀后用 `decode-url-path` 解码一次，再作为路由处理。片段 `#intro` 应加在生成的 URL 后面。

= 资源 URL

`asset-url` 接收 `[assets]` 里声明的地址，例如 `/media/logo.svg`。它检查声明，加部署前缀，并在配置启用时附上缓存标识。Bundle 的 `asset` 和 `generate-outputs` 钩子生成的文件，已知输出路径时用 `output-url`。如静态资产的文件名恰好叫 `index.html`，`asset-url` 也会保留完整文件名。

= 模块路径

在站点入口，Typst 的 `/…` 输入路径从项目根起算。在模块的 Typst 包里，`/…` 从包根起算。模块要插入站点内容时用 `source.file`。要读取项目中的 `data/menu.json`，可以用 `json(project-path("data/menu.json"))`，其中 `project-path` 来自 `@tola/site`。

模块静态资源的 `source` 相对于模块目录。发布时会加模块别名，例如 `/notes/_tola-modules/blog/theme.css`。该模块中用 `get-module().assets.files` 取编译输入，用 `get-module().assets.urls` 取最终浏览器地址。后者已经包含部署前缀，可直接使用。

参见 #link(address-reference)[`@tola/address` 参考]。在命令行中也可以运行 `tola help "@tola/address"`。
