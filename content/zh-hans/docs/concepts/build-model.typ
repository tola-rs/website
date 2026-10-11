#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "站点如何构建",
  description: "从 content/ 读取正文，生成 HTML 并写入 public/。",
  order: 10,
))

#title()

= 入口和源文件

`tola.toml` 的 `[build] entry` 指定要编译的入口。它可以是项目里的 `site.typ`，也可以由主题模块提供。`all-sources()` 返回 Tola 在 `content-dir` 下发现的内容源，默认目录是 `content/`。

Tola 按路径列出内容目录下扩展名为小写 `.typ` 的文件，跳过隐藏文件、隐藏目录、符号链接和入口文件。共享模板和组件可以放在内容目录之外。

= HTML 输出

`tola init` 生成的入口用下面的循环发布内容。

```typst
#import "@tola/address:0.0.0": join-route, output-of
#import "@tola/source:0.0.0": all-sources

#for source in all-sources() {
  document(output-of(join-route(source.route-segments)), format: "html")[
    #include source.file
  ]
}
```

默认入口用 `join-route` 拼出源文件的路由，再用 `output-of` 算出 HTML 文件的相对路径。`document` 在 Bundle 中声明该输出，`include` 把源文件的正文放进去。也可以在循环前筛选源文件，或在同一个 `document` 中用 `include` 合并正文。

沿用 #link("/docs/getting-started/first-site/")[第一个站点]，把下面的代码追加到 `site.typ`。`tola build` 会写入 `public/pages/index.html`，预览时访问 `/pages/` 可以看到首页和安装指南的链接。

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

索引和正文共用路径计算逻辑。在 `content/` 下添加 Typst 文件后，下次构建会写出对应的 HTML，索引也会链接到这个输出。

= 构建与检查

```mermaid
flowchart LR
  accTitle: Tola 构建流程
  accDescr: site.typ 读取 content 中的源文件，Tola 将生成的网页写到 public。
  source["content/*.typ"] --> entry["site.typ"] --> output["public/"]
```

入口编译为一个 Typst Bundle。Bundle 里的文档和资源，加上配置声明的静态资源和钩子产物，组成最终发布目录。若两个来源声明了同一个输出路径，或页面链接指向了不存在的文件、资源或锚点，Tola 会给出诊断。

`tola check` 检查构建结果。`tola build` 检查通过后会用整套产物替换 `[build].publish-dir`（默认 `public/`）。这一步叫发布（publish），已删除源文件对应的旧 HTML 也会在这一步清除。

部署（deploy）是把发布目录交给 Web 服务器或托管服务，让读者可以访问站点。
