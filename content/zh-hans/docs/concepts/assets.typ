#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "静态资源",
  description: "发布图片、CSS、脚本和字体，并在页面中引用它们。",
  order: 30,
))

#title()

= 声明资源

把标志图片保存为 `static/logo.svg`，把样式表放到 `static/styles/main.css`。在站点根目录的 `tola.toml` 加入下列声明。

```toml
[assets]
cache-busting = true
files = [{ source = "static/logo.svg", url = "/media/logo.svg" }]
trees = [{ source = "static/styles", url-prefix = "/styles" }]
```

从站点根目录运行 `tola build`。默认发布目录中会出现 `public/media/logo.svg` 和 `public/styles/main.css`。`files` 为单个文件指定地址，`trees` 保留目录内的相对路径。可以用 `include`、`exclude` 筛选树里的文件，模式从站点根或模块根算起。同一源文件同时匹配两种声明时，以 `files` 为准。

= 文件符号链接

在支持 `ln -s` 的终端，从站点根目录创建文件和链接。

```sh
mkdir -p shared static/downloads
printf '%s\n' 'Project notes' > shared/notes.txt
ln -s ../../shared/notes.txt static/downloads/guide.txt
```

在 `tola.toml` 加入下列声明。若已有 `trees = [...]`，把这三个字段写进数组中的一项。

```toml
[[assets.trees]]
source = "static/downloads"
url-prefix = "/downloads"
follow-file-symlinks = true
```

运行 `tola build` 后，`public/downloads/guide.txt` 是普通文件，内容来自 `shared/notes.txt`。使用默认部署路径时，浏览器访问 `/downloads/guide.txt`。

`include` 和 `exclude` 按链接本身的路径匹配。断链和指向目录的链接会报错。模块中的链接目标必须在模块内，`--pure` 构建的链接目标也必须在站点内。

= 引用资源

把下面两行加入 `content/index.typ`，重新运行 `tola build`。首页会显示前面发布的标志图片。

```typst
#import "@tola/address:0.0.0": asset-url

#html.img(src: asset-url("/media/logo.svg"), alt: "站点标志")
```

传给 `asset-url` 的是声明中的地址。函数加上部署前缀，并在启用 `cache-busting` 时附加 `?h=…`。文件内容更改后，浏览器会看到新 URL，发布文件仍叫 `media/logo.svg`。

样式表也用 `asset-url`，在网页的 `head` 里用 `html.link(rel: "stylesheet", ...)` 加载。CSS 的 `url(...)` 由浏览器以发布后的样式表地址为基准解析。比如 `/notes/styles/main.css` 里写 `url("../media/logo.svg")`，浏览器会请求 `/notes/media/logo.svg`。

= 资源发布

`read(...)`、`json(...)`、`image(...)` 读取的是编译输入。把原图交给 `image` 可以在文档中显示图像。要让浏览器另外访问原始文件，则为它声明发布地址。需要缩略图或响应式尺寸时，可以用 `@tola/image` 生成衍生文件。

`[typst.fonts]` 为 Typst 指定构建时使用的字体，例如 `html.frame` 排版 SVG 时用到的字体。运行 `tola inspect fonts` 可以查看它们。网页文字使用的字体要作为静态资源发布，再用 CSS 的 `@font-face` 加载。

= 生成资源

要发布程序生成的数据，在 `site.typ` 顶层加一条 `asset` 声明。

```typst
#asset("data/site.json", json.encode((title: "我的站点")))
```

这样会得到 `public/data/site.json`。引用它时用 `output-url("data/site.json")`。`asset-url` 对应配置声明的静态资产。外部工具也能生成文件，见 #link("/docs/concepts/hooks/")[构建钩子与外部工具]。
