#import "@tola/source:0.0.0": tola-meta
#import "@tola/module:0.0.0": get-module

#let (repository, versions) = get-module("docs").options
#let tag = "v" + versions.tola

#tola-meta((
  title: "安装",
  description: "下载或编译指定版本的 Tola，并验证本地环境。",
  order: 10,
))

#title()

本站文档对应 #raw(tag)。可以根据系统环境选择下面任意一种方式安装。

= 预编译二进制

前往 #link(repository + "/releases")[GitHub Releases] 下载对应平台的压缩包：

- macOS（Apple Silicon）
- Linux（x86_64 / ARM64）
- Windows（x86_64）

解压后，将包含 `tola`（Windows 为 `tola.exe`）的目录添加到环境变量 `PATH`。

= 从源码编译

已检出对应版本源码时，在仓库根目录通过 Cargo 安装：

```sh
cargo install --locked --path .
```

= Nix Flake

仓库根目录提供 `flake.nix`。使用时可将 flake input 固定到目标标签或提交记录；预构建缓存托管在 #link("https://tola.cachix.org")[Cachix]。

= 验证安装

新开一个终端窗口，检查版本输出：

```sh
tola --version
```

输出第一行应为 #raw("tola " + versions.tola)，随后显示内置的 Typst 与 Nushell 版本。如果提示找不到命令，请检查可执行文件所在目录是否已加入 `PATH` 并重新打开终端。

接下来前往 #link("/docs/getting-started/first-site/")[创建第一个站点] 动手建立项目；如需查看完整命令列表，也可以查阅 #link("/docs/getting-started/cli-usage/")[命令行用法]。
