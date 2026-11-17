#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/docs:0.0.0": code-group

#tola-meta((
  title: "创建第一个站点",
  description: "初始化项目、编写两篇页面，并在本地实时预览和构建输出。",
  order: 20,
))

#title()

= 初始化项目

在工作目录运行以下命令创建站点：

```sh
tola init my-site
cd my-site
```

`tola init` 会生成 `tola.toml`、`site.typ`、`.gitignore`、`.ignore` 以及空的 `content/` 目录。默认入口 `site.typ` 会自动把 `content/` 下的 `.typ` 文件发布为 HTML，并附带一个 `404.html`。

= 添加页面内容

在 `content/` 下按标签中的路径新建两个文件（若 `content/guide` 目录不存在请先创建）：

#code-group((
  (label: "content/index.typ", body: [```typst
= 我的站点

欢迎阅读 #link("/guide/install/")[安装指南]。
```]),
  (label: "content/guide/install.typ", body: [```typst
= 安装指南

运行 `tola --version` 查看当前版本。
```]),
), label: "站点源文件")

= 本地预览 <live-preview>

启动开发服务器：

```sh
tola dev
```

用浏览器打开终端打印的本地地址，点击首页的「安装指南」即可跳转到 `/guide/install/`。现在尝试修改并保存 `content/guide/install.typ`，页面会自动重建并刷新，不用手动重启服务。

= 检查与构建

按 `Ctrl+C` 停止开发服务器后，可以先做一次全站检查，再生成最终的静态文件：

```sh
tola check
tola build
```

`tola check` 会校验编译结果、输出路径和站内链接而不改动发布目录；`tola build` 则将完整站点写入 `public/`：

- `content/index.typ` → `public/index.html`
- `content/guide/install.typ` → `public/guide/install/index.html`
- 默认 404 页面 → `public/404.html`

如果要在编辑器中获得补全、诊断和跳转支持，可以参考 #link("/docs/getting-started/cli-usage/")[命令行用法] 配置工作区；想进一步了解 `site.typ` 是如何把源文件映射到 HTML 路径的，请继续阅读 #link("/docs/concepts/build-model/")[站点如何构建]。
