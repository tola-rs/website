#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "内置脚本",
  description: "查询内置 Nushell 脚本的子命令、参数和输入输出。",
  order: 20,
))

#title()

用 `tola nu` 运行这些脚本。脚本随 Tola 提供。

- #link("/docs/reference/scripts/context/")[`@tola-scripts/context`]：读取 Tola 传给当前 hook、模块命令或初始化脚本的路径和设置。
- #link("/docs/reference/scripts/image/")[`@tola-scripts/image`]：查看图片尺寸和格式，或缩放、转换图片。
- #link("/docs/reference/scripts/diagnostic/")[`@tola-scripts/diagnostic`]：将 JSON 诊断显示在终端。

= 查看图片尺寸

把图片保存为 `photo.png`，在该文件所在目录运行下面的命令。终端会输出包含宽度、高度和格式的 JSON。

```sh
tola nu @tola-scripts/image metadata photo.png
```

需要编写自己的脚本时，见 #link("/docs/guide/tools/nushell/")[用 Nushell 写站点脚本]。
