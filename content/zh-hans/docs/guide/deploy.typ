#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "部署站点",
  description: "检查缺页和断链，预览部署路径，再上传站点。",
  order: 10,
))

#title()

= 检查缺页和断链

从站点根目录运行：

```sh
tola inspect sources
tola check --json --pretty
```

先在 `inspect sources` 的输出里找源文件。找不到时，检查 `[build].content-dir`、文件扩展名和隐藏目录。找得到源时，再看检查报告的 `pages` 和 `routes`，确认入口是否选中了它，以及把它发布到了哪个路由。若报告里有构建错误，先按诊断定位到源文件。

`tola check` 会构建站点并检查输出路径与站内引用，发布目录保持原样。配置了构建前钩子或输出生成钩子时，检查也会运行这两个阶段。

= 预览部署前缀

假设正式地址是 `https://example.com/notes/`。在 `tola.toml` 里指定域名和部署前缀。

```toml
[site]
origin = "https://example.com"
base-path = "/notes/"
```

部署到域名根目录时，把 `base-path` 设为 `"/"`。如果你保留了入门示例首页的手写链接，改为用 #link("/docs/concepts/routes-and-urls/")[`output-url` 生成链接]。

```sh
tola preview
```

打开命令打印的地址，点一下首页链接，确认页面和资源都能加载。`preview` 用生产构建设置生成一次预览。修改文件后，重新运行它查看结果。

= 构建并上传

按 Ctrl+C 停止预览，然后构建。

```sh
tola build
```

上传 `public/` 的全部内容。如果配置了 `[build].publish-dir`，上传该目录。构建会替换这个目录，请把手工维护的文件放在项目里，通过 `[assets]` 等方式纳入构建。

在托管服务上把发布目录挂载到 `base-path` 对应的位置。确认服务会把 `/notes/guide/install/` 映射到 `guide/install/index.html`，并按需配置 `404.html`。
