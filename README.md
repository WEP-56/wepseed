# WEPSEED

> 把 RSS 读成一条有温度的信息流。

WEPSEED 是一款 Android 优先、local-first 的 RSS 阅读器。它保留订阅阅读的安静和可控，也给文章、音频与视频一点更像当下产品的阅读体验：轻盈的信息流、沉浸播放器、可回看的个人轨迹，以及由你自己的 API Key 驱动的 AI 对话。

没有账号，没有云端阅读画像；订阅、文章缓存、收藏与对话都留在你的设备上。

## 它是什么样的

- **像刷信息流一样读订阅**：图片与文字混排、源主页、已读状态、筛选与下拉刷新。
- **认真阅读一篇文章**：HTML 正文、目录跳转、图片缓存、收藏、分享；原文默认在**应用内浏览器**打开（可转系统浏览器）。
- **也能听与看**：自动识别 RSS/Atom 中的音频、视频直链；音频支持后台和系统媒体通知，视频支持全屏与 Android 小窗播放。
- **应用内浏览器**：收藏、浏览历史、下载管理、无痕模式；站点深链打开本机 App 前会弹窗确认。
- **陪你留下轨迹**：收藏、阅读停留与温度事件沉淀在 ME 页面，随时回看。
- **AI 是你的，不是平台的**：可配置自己的提供商与模型。博客有“网友”评论；音视频有独立的「一起聊」对话，聊天记录本地持久化。

## 从这里开始

下载安装包请前往 [Releases](https://github.com/WEP-56/wepseed/releases)，大多数 Android 手机选择：

`wepseed-*-arm64-v8a.apk`

安装后可以先添加一个 RSS/Atom 地址，或从 OPML 导入已有订阅。音视频内容会在信息流卡片上标出类型；打开视频后，点详情控制条的“小窗播放”，或直接回到桌面，即可进入系统画中画。

## 本地运行

```bash
flutter pub get
flutter run -d <device>
```

发布采用 tag 驱动的 GitHub Actions，自动构建按 ABI 拆分的 APK。签名与发布流程见 [发布工作流](.github/workflows/release.yml)。

## 本地优先，也请了解这些边界

- RSS、音视频流由你订阅的源站直接提供。
- 使用 AI 功能时，标题、节目说明和你的问题会发送给你配置的 LLM 服务商；API Key 使用系统安全存储。
- WEPSEED 不提供账号体系，也没有收集订阅与阅读数据的自有后端。

完整说明见 [隐私政策](docs/PRIVACY.md) 与 [功能实现文档](docs/IMPLEMENTATION.md)。

## 还在生长

欢迎通过 [Issues](https://github.com/WEP-56/wepseed/issues) 分享好用的订阅源、异常 RSS/Atom 样本或体验建议。YouTube 与 RSSHub 订阅兼容性正在登记排查中。

## License

[MIT](LICENSE)
