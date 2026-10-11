// 安装：可执行文件的获取方式与验证。

#import "@tola/source:0.0.0": tola-meta
#import "/site/info.typ": repository, version

#tola-meta((
  title: "安装",
  description: "安装 Tola。",
  order: 10,
))

#title()

Tola 在 GitHub Releases 上提供 macOS（Apple Silicon）、Linux（x86_64 / aarch64）和 Windows（x86_64）的预编译二进制。下面三种方式选一种。

= 使用 Cargo

需要本机的 Rust 工具链：

```sh
cargo install --locked tola
```

`--locked` 使用发布时锁定的依赖，避免本地解析出不同版本。

= 下载发布二进制

从#link(repository + "/releases")[发布页面]下载对应平台的压缩包，解压后把目录加入 `PATH`；当前最新发布是 #raw("v" + version.tola)。

== Windows

下载 #raw("tola-" + version.tola + "-x86_64-pc-windows-msvc.zip")，解压后把目录加入 `PATH`，新开一个终端运行：

```sh
tola --version
```

= 使用 Nix Flake

仓库提供 `flake.nix`，预编译二进制发布在#link("https://tola.cachix.org")[tola.cachix.org]。把 input 固定到要使用的发布标签，例如 #raw("v" + version.tola)。

= 验证

#raw(
  "$ tola --version\ntola " + version.tola + "\ntypst " + version.typst,
  lang: "sh",
  block: true,
)
