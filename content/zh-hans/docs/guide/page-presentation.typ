#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "图片、图标与代码",
  description: "按网页需要生成响应式图片、管理 SVG 图标集，以及渲染明暗双主题的高亮代码。",
  order: 20,
))

#title()

= 缩略图与响应式图片

`@tola/image` 在构建时按需生成衍生图片并输出到 `_tola/images/`（返回的 URL 已含 `base-path`），原始图片无需放进 `[assets]`。常用函数分工：

- `img`：直接生成响应式 `<img>`，按 `widths` 生成多份尺寸并由 `sizes` 指导浏览器选图。
- `image-srcset`：返回 `url`、`srcset`、`width` 和 `height`，适合在自定义 HTML 或社交分享卡片中复用。
- `resize-image`：只生成单一目标尺寸的衍生图。
- `image-metadata`：读取原图宽高、格式等元信息。

```typst
#import "@tola/image:0.0.0": img, resize-image

// 响应式图片（页面最宽 720px，窄屏占满 100vw）
#img(
  path("/images/cover.png"),
  alt: "封面照片",
  widths: (480, 960),
  sizes: "(max-width: 760px) 100vw, 720px",
)

// 单一宽度缩略图
#let thumb = resize-image(
  path("/images/cover.png"),
  width: 640,
  op: "fit-width",
  format: "webp",
)
#html.img(src: thumb.url, alt: "封面缩略图")
```

#callout[
  字符串路径默认从当前 `.typ` 文件所在目录起算；如果封装了跨文件调用的图片组件，请在原始调用处先用 `path(...)` 解析后再传参。矢量图（SVG）需要保持矢量时可直接使用 `image(...)` 或作为静态资源发布；响应式辅助函数不处理 SVG，只有 `resize-image` 在显式指定输出为 `webp` / `png` / `jpg` 时可将 SVG 栅格化。
]

= SVG 图标集

`@tola/icon` 从 `[icons.collections]` 配置的集合中读取图标（运行 `tola inspect icons` 查看当前可用集合；本站 `docs` 模块内部将 Lucide 注册为 `ui`，可用 `tola inspect icons ui --module docs` 查阅）。

例如，将一个自绘三角图标保存为 `icons/ui/mark.svg`：

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="currentColor" d="M12 3 22 21H2Z"/>
</svg>
```

在 `tola.toml` 注册该本地目录：

```toml
[icons.collections.ui]
source-type = "local-svg-dir"
path = "icons/ui"
```

在页面中有两种常用渲染方式：

```typst
#import "@tola/icon:0.0.0": icon, icon-url

// 1. 内联 SVG，通过 currentColor 自动跟随文字颜色
#icon("ui:mark") 重要提示

// 2. 作为独立图片发布并引用 URL（不会继承外部文字颜色）
#html.img(src: icon-url("ui:mark"), alt: "三角标记")
```

如果需要将 SVG 交给 Typst 原生 `image(...)` 处理，可用 `icon-bytes` 获取字节。注意无障碍语义：图标旁已有文字说明时，图标保持装饰角色（无额外标签）；纯图标按钮则须为控件提供可访问名称。

= 代码高亮与明暗配色

使用 `@tola/code` 的 `render-code` 作为 `raw` 的 `show` 规则，即可在 HTML 中输出带 token 高亮的代码块。采用自定义 `html.html` 外壳时，须在 `head` 中调用 `code-stylesheet()` 加载配色样式表：

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
```

几点说明：

- *配色切换*：`raw.theme` 决定浅色/默认主题，命名参数 `dark-theme` 决定根元素带有 `data-theme="dark"` 时的深色主题。主题切换逻辑与外框样式由站点自行负责。
- *行内代码高亮*：反引号行内代码没有语言标记，若想为行内代码也启用语法高亮，可写 `#raw("let x = 1", lang: "rust")`。
- *语法定义*：Tola 内置了常见语言语法（如 `nu`）；当站点通过 `raw.syntaxes` 为同一语言提供自定义语法文件时，站点定义优先。

完整参数见 #link("/docs/reference/packages/image/")[`image`] · #link("/docs/reference/packages/icon/")[`icon`] · #link("/docs/reference/packages/code/")[`code`]。
