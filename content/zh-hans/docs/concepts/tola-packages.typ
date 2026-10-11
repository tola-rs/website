#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Tola 内置包",
  description: "导入 @tola 包，用内容源查路由并生成链接。",
  order: 50,
))

#title()

= 导入包

Tola 内置 `@tola/*` 包，导入版本固定为 `0.0.0`。

```typst
#import "@tola/source:0.0.0": all-sources
#import "@tola/address:0.0.0": join-route, output-of
```

`tola help "@tola/address" output-of` 会显示本机 Tola 的函数签名。

`@preview/…` 来自 Typst Universe。`@tola-modules/…` 中的包名对应 `tola.toml` 里注册的模块别名。

= 选包与示例

沿用 #link("/docs/getting-started/first-site/")[第一个站点]，把下面的代码加到 `content/index.typ`。从站点根目录运行 `tola build`，首页会多一个指向 `/guide/install/` 的链接。

```typst
#import "@tola/address:0.0.0": join-route, route-url
#import "@tola/source:0.0.0": all-sources

#let guide = all-sources().find(source => source.path == "guide/install.typ")
#let route = join-route(guide.route-segments)
#link(route-url(route))[读安装指南]
```

如果入口为页面指定了其他地址，用 `output-url` 从实际输出路径生成链接。用 `@tola/collection` 可以为页面分组或建立索引。

= 示例与参考

#link("/docs/guide/tools/")[内置包与脚本示例] · #link("/docs/reference/packages/")[内置包参考]
