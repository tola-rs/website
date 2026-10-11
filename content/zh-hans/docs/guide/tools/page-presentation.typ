#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "图片、图标与代码",
  description: "按网页需要生成响应式图片、SVG 图标和高亮代码。",
  order: 10,
))

#title()

= 生成缩略图

`@tola/image` 的 `image-metadata` 读取尺寸等信息，`resize-image` 发布单一尺寸的衍生图，`image-srcset` 和 `img` 用于响应式图片。原图可以留在资产目录之外，浏览器只会收到所生成的尺寸。

把一张 PNG 保存为站点根目录下的 `images/cover.png`，再把下面的代码放入 `content/index.typ`：

```typst
#import "@tola/image:0.0.0": resize-image

#let cover = resize-image(
  path("/images/cover.png"),
  width: 640,
  op: "fit-width",
  format: "webp",
)
#html.img(src: cover.url, alt: "封面照片")
```

从站点根目录运行 `tola build`。默认会把缩图放到 `public/_tola/images/`，首页引用宽 640 像素的 WebP。返回的 URL 已包含站点的部署前缀。要在窄屏和宽屏上分别提供不同尺寸，用 `img` 并设置适合布局的 `sizes`，让浏览器选择下载哪个文件。

= 添加 SVG 图标

`@tola/icon` 从 `[icons.collections]` 配置的集合中读取图标。用 `tola inspect icons` 查看集合。本站的 `docs` 模块将 Lucide 注册为 `ui`。用 `tola inspect icons ui --module docs` 查看其中的图标，用 `icon("ui:rocket", module: "docs")` 渲染图标。

也可以从本地文件开始。把下面的小三角图标存为 `icons/ui/mark.svg`。

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="currentColor" d="M12 3 22 21H2Z"/>
</svg>
```

在 `tola.toml` 注册这个目录：

```toml
[icons.collections.ui]
source-type = "local-svg-dir"
path = "icons/ui"
```

在内容页使用 `ui:mark`。第一个例子内联 SVG，跟随周围文字颜色；第二个发布独立的 SVG，并生成图片 URL。

```typst
#import "@tola/icon:0.0.0": icon, icon-url

#icon("ui:mark") 重要提示

#html.img(src: icon-url("ui:mark"), alt: "三角标记")
```

`icon-bytes` 还可以取得原始 SVG 字节，交给 Typst 的 `image`。图标旁已有文字时可以将图标作为装饰；仅图标的按钮应为控件提供可读名称。

= 设置代码高亮

原生的反引号代码块可直接用于 HTML。定制主题时，用 `@tola/code` 的 `render-code` 将原生 `raw` 按指定主题渲染为高亮代码。自定义 HTML 外壳可在 `head` 中加入 `code-stylesheet()`。

Tola 会为匹配的代码块加载随附语法，例如 `nu`。通过 `raw.syntaxes` 提供同一语言的语法时，优先使用站点的定义。

在临时站点把下面的代码存为 `site.typ`。运行 `tola dev`，再把根元素的 `data-theme` 改为 `"light"`，可以看到同一代码块采用的两套配色。

```typst
#import "@tola/code:0.0.0": code-stylesheet, code-themes, render-code

#document("index.html", format: "html", title: "代码示例")[
  #html.elem("html", attrs: (lang: "zh-Hans", "data-theme": "dark"))[
    #html.head[
      #html.title[代码示例]
      #code-stylesheet()
    ]
    #html.body[
      #set raw(theme: code-themes.github)
      #show raw: render-code.with(dark-theme: code-themes.github-dark)
      #raw("let answer = 42;", lang: "rust", block: true)
    ]
  ]
]

#document("404.html", format: "html")[找不到页面。]
```

`raw.theme` 用于主配色，`dark-theme` 用于深色配色。`render-code` 作为 show 规则接收已经准备好高亮信息的 `raw` 元素。

#link("/docs/reference/packages/image/")[`image`] · #link("/docs/reference/packages/icon/")[`icon`] · #link("/docs/reference/packages/code/")[`code`]
