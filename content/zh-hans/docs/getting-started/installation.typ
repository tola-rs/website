#import "@tola/source:0.0.0": tola-meta
#import "@tola/module:0.0.0": get-module

#let (repository, versions) = get-module("docs").options
#let tag = "v" + versions.tola

#tola-meta((
  title: "安装",
  description: "获取指定版本的 Tola 并验证安装。",
  order: 10,
))

#title()

= 预编译版本

本站文档对应 #raw(tag)。发布后，可从 #link(repository + "/releases")[GitHub Releases] 下载 macOS（Apple Silicon）、Linux（x86_64 或 ARM64）或 Windows（x86_64）的构建。解压后，把 `tola`（Windows 上是 `tola.exe`）所在的目录加入 `PATH`。

= 源码安装

已检出对应版本的源代码时，在仓库根目录运行：

```sh
cargo install --locked --path .
```

= Nix Flake

仓库提供 `flake.nix`。将 flake 输入固定到所需的标签或提交。可从 #link("https://tola.cachix.org")[Cachix] 获取缓存的构建结果。

= 验证

打开一个新终端，确认能运行 Tola。

```sh
tola --version
```

第一行应为 #raw("tola " + versions.tola)，后两行会显示内置的 Typst 和 Nushell 版本。若找不到命令，检查 Tola 所在的目录是否已经加入 `PATH`。

安装完成后，可以先看 #link("/docs/getting-started/cli-usage/")[命令行用法]，或直接 #link("/docs/getting-started/first-site/")[创建第一个站点]。
