#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": callout

#tola-meta((
  title: "站点如何构建",
  description: "了解入口程序如何扫描 content/、组织 Bundle 文档并写入发布目录。",
  order: 0,
))

#title()

= 入口与源文件发现

`tola.toml` 中的 `[build] entry` 指定站点编译入口，可以是项目内的 `site.typ`，也可以由主题模块提供。

入口程序通过 `@tola/source` 的 `all-sources()` 扫描 `content-dir`（默认 `content/`）下的所有内容源文件。扫描规则如下：

- 只收集扩展名为小写 `.typ` 的文件，结果按完整源路径排序（而非编辑顺序）。
- 自动跳过隐藏文件、隐藏目录、符号链接以及站点入口文件本身。
- 共享模板、样式与工具函数建议放在 `content/` 之外，避免被当成独立页面扫描。

= 从源文件到 HTML 输出

`tola init` 生成的默认 `site.typ` 用下面这段循环把所有源文件发布为 HTML：

```typst
#import "@tola/address:0.0.0": join-route, output-of
#import "@tola/source:0.0.0": all-sources

#for source in all-sources() {
  document(output-of(join-route(source.route-segments)), format: "html")[
    #include source.file
  ]
}
```

这里做了三件事：

1. `join-route(source.route-segments)` 根据文件所在目录生成默认路由（如 `guide/install.typ` → `/guide/install/`）。
2. `output-of(...)` 将路由转为相对于发布目录的文件路径（如 `guide/install/index.html`）。
3. `document(...)` 在 Typst Bundle 中声明一个输出文档，并用 `#include source.file` 嵌入源文件正文。

因为控制权完全在入口程序手里，你可以先筛选或排序 `all-sources()` 再生成页面，也可以把同一份源文件放进多个输出文档，或者用循环额外生成索引页。例如，在 `site.typ` 中追加一个站内页面列表：

```typst
#import "@tola/address:0.0.0": output-url

#document("pages/index.html", format: "html", title: "页面列表")[
  = 页面列表
  #for source in all-sources() [
    #let output = output-of(join-route(source.route-segments))
    - #link(output-url(output))[#raw(source.path)]
  ]
]
```

索引页与正文共用同一套路径逻辑：在 `content/` 下增删 `.typ` 文件后，下次构建会自动更新对应的 HTML 和索引链接。

= 编译、检查与发布

```mermaid
flowchart LR
  accTitle: Tola 构建流程
  accDescr: site.typ 读取 content 中的源文件，Tola 检查后将网页与资源写到 public。
  source["content/*.typ"] --> entry["site.typ (Bundle)"] --> check["tola check / 校验"] --> output["public/"]
```

站点入口最终编译为一个 Typst Bundle。Bundle 中声明的文档与生成资源，加上 `[assets]` 中的静态资源以及钩子产物，共同构成最终站点。

- *检查阶段（`tola check`）*：校验所有输出路径是否冲突，检查站内页面链接、静态资源引用与锚点是否存在，但不改写发布目录。
- *发布阶段（`tola build`）*：检查通过后，用整套新产物原子替换 `[build].publish-dir`（默认 `public/`），已删除源文件对应的旧 HTML 也会一并清除。
- *部署（deploy）*：将发布目录上传至 Web 服务器或静态托管平台即可。

#callout(title: "不要直接编辑 public/")[
  `tola build` 会整体替换发布目录。需要随站点一起分发的额外文件（如 `robots.txt`、`CNAME`），请放在项目目录中并通过 `[assets]` 声明，以免在构建时被覆盖清除。
]

= 拆分配置与多语言

当站点配置变多时，可以在 `tola.toml` 首个表头之前写上 `include = ["config/docs.toml", { path = "config/local.toml", optional = true }]` 来拆分配置。被引入文件中的配置按顺序合并：表逐键覆盖，标量与普通数组由后者替换，而 `[assets]` 和 `[[hooks.*]]` 会按顺序追加。

如果站点提供多语言内容，可以在 `[site]` 中配置默认语言 `language` 与语言列表 `languages = ["en", "zh-Hans"]`。Tola 会将这些语言标签提供给入口与主题（通过 `@tola/site` 的 `site.language` 与 `site.languages`），具体的目录划分和语言切换链接则由站点入口或主题负责实现。配置细节见 #link("/docs/reference/config/include/")[`include` 参考]与 #link("/docs/reference/config/site/")[`[site]` 参考]。
