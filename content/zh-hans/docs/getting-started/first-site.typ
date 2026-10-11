#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "创建第一个站点",
  description: "用默认模板构建和预览静态站点。",
  order: 30,
))

#title()

= 创建项目

```sh
tola init my-site
cd my-site
```

`tola.toml` 选定 `site.typ` 为入口。默认入口会把 `content/` 中的 Typst 文件发布为 HTML。初始化时 `content/` 是空的。

= 编写文章

运行 `mkdir -p content/guide`，按标签上的路径保存文件。

#code-group((
  (label: "content/index.typ", body: [```typst
= 我的站点

欢迎来读 #link("/guide/install/")[安装指南]。
```]),
  (label: "content/guide/install.typ", body: [```typst
= 安装指南

运行 `tola --version` 查看版本。
```]),
), label: "站点源文件")

= 预览并构建

```sh
tola dev
```

打开终端打印的地址。点击首页的「安装指南」会进入 `/guide/install/`。修改并保存 `content/guide/install.typ`，预览会自动更新。

按 Ctrl+C 停止预览，再构建站点。

```sh
tola build
```

首页是 `public/index.html`，安装指南是 `public/guide/install/index.html`。默认入口还会生成 `public/404.html`。

#link("/docs/concepts/build-model/")[站点如何构建]介绍入口如何为内容源指定 HTML 输出路径。
