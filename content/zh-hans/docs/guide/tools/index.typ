#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "内置包与脚本示例",
  description: "查询页面、处理图片、生成订阅和编写构建脚本的示例。",
  order: 5,
))

#title()

= 页面和模板

- #link("/docs/guide/tools/site-data/")[站点数据与内容查询]按栏目组织页面，生成标题目录，并演示用规则查递归关系。
- #link("/docs/guide/tools/page-presentation/")[图片、图标与代码]生成缩略图、内联 SVG 图标，以及切换明暗主题的高亮代码。
- #link("/docs/guide/tools/publication/")[分享、订阅与站点地图]设置浏览器标题与分享链接，并发布 RSS 和站点地图。

= 构建脚本

- #link("/docs/guide/tools/nushell/")[用 Nushell 写站点脚本]定义命令的参数，从钩子生成 JSON，再用内置脚本处理图片和诊断。

查找 API，见 #link("/docs/reference/packages/")[内置包]。查命令和选项，见 #link("/docs/reference/scripts/")[内置脚本]。
