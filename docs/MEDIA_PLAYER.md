# WEPSEED 音视频 / 媒体类型设计（P1）

> 状态：**M0–M2 + 视频 PiP + 持久媒体对话已实现，待 0.0.6 真机验收**  
> 关联：`docs/IMPLEMENTATION.md` §15 · Phase F 余 / 下一主路径  
> 产品约束（2026-07-17 更新）：**文章级** mediaType；**全局 mini player**；音视频使用独立的简易 LLM 对话悬浮窗，不创建网友评论任务  
> 平台：Flutter · Android 首发 · 本地优先  

本文档只写 **P1 要做成什么样、数据怎么落、播放器怎么叠**。实现时以本文件为准，并回写 IMPLEMENTATION 债表。

---

## 0. 目标与非目标

### 0.1 一句话

RSS 里除了图文博客，还能认出 **音频（播客）/ 视频**；点进详情有沉浸播放，切页后底部 **mini bar 续播**；锁屏/通知可控音频。

### 0.2 必须

| 能力 | 说明 |
|------|------|
| 文章级类型 | `blog` \| `audio` \| `video`（默认 blog） |
| 流地址 | enclosure / media:content / Atom enclosure 入库 |
| 封面 | 仍用现有 `imageUrl` 作 poster，与流 URL 分离 |
| 详情播放 | 视频：封面区 / 标题下主表面；音频：沉浸控件 + show notes 正文 |
| 全局 mini | 离开详情仍可暂停/进度/回详情；音频后台 |
| 通知控件 | 播放/暂停/（可选）±15s；与系统媒体会话对齐 |
| 视频全屏 / 小窗 | 横竖屏；退出回详情壳；播放中回桌面自动进入 Android 系统 PiP，也可手动点小窗按钮 |
| 独立 LLM 对话 | `audio` / `video` **不**触发网友评论任务；隐藏评论入口，改为仅媒体详情可见、**Drift 持久化**的「一起聊」悬浮窗 |

### 0.3 非目标（首版）

- 播客「完整壳」：多队列管理 UI、订阅目录、章节图文同步滚动  
- 本地下载整集缓存（可后置；隐私/磁盘要单开）  
- 源级 feedType 分栏（可选二期；首版只文章级）  
- iOS 首发阻塞  
- 应用内 WebView 播 HLS 站点页（流 URL 直连播放器；坏链再系统浏览器）  
- DRM / 付费墙流  

### 0.4 体验原则

- 克制：跟现有灰阶 / liquid glass；**不**大面积彩色播放器皮肤  
- 博客路径零回退：无 enclosure 的文章行为与 0.0.4 完全一致  
- 性能：列表卡不挂播放器实例；仅全局 **一个** 活跃 session  
- 外链兜底：流失败 → Toast +「在外部打开」`openExternalUrl(enclosureUrl)`  

---

## 1. 现状（代码基线 · 2026-07-17）

| 区域 | 现状 | 缺口 |
|------|------|------|
| `rss_parser` | 图：media thumbnail/content、`enclosure` image/、HTML img | 忽略 `audio/*` `video/*`；无 duration |
| `ParsedItem` / `Article` / `Articles` | 正文 + image | 无 mediaType / enclosure* / duration |
| New 卡片 | 有图 / 无图二态 | 无类型角标、无播放示意 |
| 详情 | HTML 正文 + 评论 + 外链浏览器 | 无 A/V chrome |
| 依赖 | 无 video/audio 播放包 | 需选型引入 |
| 评论 | 打开详情/评论 sheet 即 generate | 必须按类型短路 |

关键路径（扩展点）：

```text
RssParser → ParsedItem → DriftFeedRepository._upsertItems
  → Articles / Article → FeedCard → ArticleDetailPage
  → (新) MediaSessionController → MiniPlayerHost + DetailMediaSlot
```

---

## 2. 领域与类型推断

### 2.1 枚举

```dart
enum ArticleMediaType { blog, audio, video }
```

DB 存字符串：`blog` / `audio` / `video`。

### 2.2 推断顺序（实现写进 `rss_parser` 注释）

1. **MIME**：enclosure / `media:content` 的 `type`  
   - `video/*` → `video`  
   - `audio/*` → `audio`  
2. **URL 扩展名**（无 MIME 时）：  
   - 视频：`.mp4` `.webm` `.m3u8` `.mkv` `.mov` …  
   - 音频：`.mp3` `.m4a` `.aac` `.ogg` `.opus` `.flac` …  
3. **itunes / media 提示**（可选加强）：`itunes:episodeType`、`media:medium=audio|video`  
4. 否则 → **`blog`**（即使有封面图）

**混合稿**（播客 show notes HTML + MP3）：`mediaType=audio`，HTML 仍作正文；播放器在正文上方。

### 2.3 字段（建议）

**`ParsedItem` / `Article` / Drift `articles` 增量（schema 预计 6）：**

| 列 | 类型 | 说明 |
|----|------|------|
| `mediaType` | text default `blog` | 见上 |
| `enclosureUrl` | text? | 主播放地址 |
| `enclosureMime` | text? | 如 `audio/mpeg` |
| `enclosureLength` | int? | 字节，可选 |
| `durationSeconds` | int? | itunes:duration / media:duration |
| `imageUrl` | 已有 | poster / 列表图，**不要**被流 URL 覆盖 |

刷新 upsert：保留已读/收藏；媒体字段随 feed 更新（URL 变则更新）。

**Feed 级（二期可选）：** `feeds.defaultMediaType` 或用户标记「这是播客源」——首版不做。

---

## 3. 解析规格

**文件：** `lib/data/rss/rss_parser.dart` · `rss_models.dart`

### 3.1 RSS 2.0

- 每个 `item`：收集全部 `enclosure`（url, type, length）  
- 选 **主 enclosure**：优先 audio/video MIME；多个时取第一个合理媒体（可偏好更长 length）  
- 图像 enclosure **只**喂 `imageUrl` 路径（保持现逻辑）  
- `media:content` / `media:group`：非 image 写入候选流  
- `itunes:duration`：解析为秒（`HH:MM:SS` / `MM:SS` / 纯秒）  
- `media:thumbnail` / 现有图逻辑不变  

### 3.2 Atom

- `link rel="enclosure"`：`href` + `type` + `length`  
- 现有 `_atomLink` 只取 alternate —— **并列**取 enclosure，勿破坏原文 link  

### 3.3 验收夹具

- `test/fixtures/` 增加：audio enclosure RSS、video enclosure、Atom enclosure、show notes+mp3  
- 单测：类型推断表驱动  

---

## 4. UI 规格

### 4.1 New 卡片（`feed_card.dart`）

| 类型 | 视觉 |
|------|------|
| blog | 现状（图卡 / 字卡） |
| audio | 图卡左下或右上 **波形/音符** 小标；无图则字卡 + 「音频」弱标签 |
| video | 图卡中心半透明 **play**；16:9 优先（`imageAspect` 可默认 16/9） |

- 点击仍进 `/article/:id`（**不**单独 `/play` 首版）  
- 列表 **不** 内嵌真实播放器  

### 4.2 详情（`article_detail_page.dart`）

**共用壳：** 返回、源信息、标题、（可选）时长、正文、更多菜单。

| 类型 | 布局 |
|------|------|
| blog | 现状 + 评论 |
| audio | 大封面/monogram → **主播放条**（播/停、进度、倍速 0.8–2.0、±15s）→ show notes HTML → 「一起聊」 |
| video | 封面/视频面（初始 poster + play）→ 标题/摘要 → 正文（若有）→ 「一起聊」；全屏按钮 |

右侧操作条：

- blog：Save / 评论 / More（现状）  
- audio/video：Save / **投到 mini 的播放态** / More（分享、复制流链接、外部打开）  

### 4.3 全局 Mini Player

**挂载：** `AppShell` 底栏 **上方** 一条（勿挡 glass nav；留 8–12 安全距）。

| 元素 | 行为 |
|------|------|
| 封面 36–40 | 点 → push/go 回 `/article/:id` |
| 标题单行 | 源名 secondary |
| 播/停 | 主操作 |
| 关闭 | 停会话 + 卸 mini |
| 进度细条 | 可拖（音频必须；视频 mini 可只显示） |

规则：

- 同时仅 1 session；新开文章媒体 → 替换（可 Toast「已切换」可选）  
- 仅 `audio`/`video` 且用户已点播后出现；博客不出现  
- 进程被杀：首版 **可不** 恢复进度（二期：Drift `media_progress`）  

### 4.4 视频全屏

- 路由内 `FullscreenRoute` 或 `OrientationBuilder` + 隐藏系统栏  
- 退出：恢复竖屏 + 详情滚动位置尽量保持  
- 手势：单击显隐控件；双击±10s 可选  

### 4.5 空态 / 错误

| 情况 | 处理 |
|------|------|
| 类型 audio/video 但无 enclosureUrl | 当 blog 展示 + 文案「未找到媒体文件」弱提示 |
| 404 / 编解码失败 | Toast + 外部打开 |
| 仅有页面 link 无直链（常见视频站） | **不**假装能播；类型仍可为 blog，或 video 但 CTA 仅「浏览器打开」——首版 **无直链不标 video** 更干净 |

---

## 5. 播放架构

### 5.1 包选型（建议）

| 用途 | 推荐 | 备注 |
|------|------|------|
| 音频 | `just_audio` | 稳、进度、倍速 |
| 后台/通知 | `audio_service` 或 `just_audio_background` | 与系统 MediaSession 对齐 |
| 视频 | `video_player` + 薄封装 **或** `media_kit` | 若要 HLS/多格式再评估 media_kit 体积 |
| 状态 | Riverpod | 全局 `mediaSessionProvider` |

**原则：** 音频与视频可分两实现，但 **统一 `MediaSession` 门面**，mini UI 只认门面。

### 5.2 门面 API（示意）

```dart
class MediaSession {
  String? articleId;
  ArticleMediaType? type;
  String? title;
  String? subtitle; // 源名
  String? artUrl;
  String? streamUrl;
  Duration position;
  Duration? duration;
  bool playing;
  double speed; // audio

  Future<void> open(Article article, {bool autoplay = true});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration d);
  Future<void> skipForward([Duration d = const Duration(seconds: 15)]);
  Future<void> skipBack([Duration d = const Duration(seconds: 15)]);
  Future<void> setSpeed(double s);
  Future<void> stop(); // 卸 mini
  Future<void> enterVideoFullscreen(BuildContext context);
}
```

### 5.3 生命周期

```text
User taps play on detail
  → MediaSession.open(article)
  → Audio: bind audio_service handler；Video: attach controller to detail surface
  → show MiniPlayer when route pops / tab switch（视频可暂停或小窗续——首版：视频离详情默认暂停，仅音频强 mini）

Kill process
  → session 丢；重开不自动播（首版）

App resume
  → audio_service 可能仍持有系统会话：对齐 position 到 Riverpod
```

**视频与 mini：** 首版推荐：

- **音频**：后台 + mini + 通知  
- **视频**：详情内 / 全屏；播放中回桌面自动转 Android 系统 PiP；详情控制条可手动进入 PiP  

系统 PiP 已在 0.0.6 接入；视频 mini/PiP 不再后置。

### 5.4 与评论短路

```text
ensureGenerated / 详情 onBrowse / 评论 sheet
  → if article.mediaType != blog → return
详情 Chat 按钮
  → mediaType != blog → 不展示（或弹「媒体稿暂无网友点评」）
```

实现点：`article_detail_page.dart`、`comment_sheet` 入口、`CommentController.ensureGenerated` 头卫。

---

## 6. 路由与深链

| 路径 | 用途 |
|------|------|
| `/article/:id` | 唯一阅读/播放入口（推荐） |
| `/article/:id?autoplay=1` | 可选：从 mini 回详情自动续 |
| 通知 payload | 音频通知点进 `/article/:id?autoplay=1`（push 栈规则不变） |

**不要** 首版新增 `/play/:id`，除非全屏视频壳必须独立。

---

## 7. 数据流

### 7.1 刷新入库

```text
refresh feed
  → parse items (+ media fields)
  → upsert articles（mediaType, enclosure*, duration, imageUrl）
  → UI Stream 自动更新卡片角标
```

### 7.2 播放

```text
open detail (audio/video)
  → 不 mark 评论任务
  → 用户点播放 → MediaSession.open
  → position tick →（二期）persist progress
  → 离开详情 → audio 续 / video 暂停
```

### 7.3 外部打开

```text
More → 打开媒体文件 → openExternalUrl(enclosureUrl ?? link)
More → 打开原文 → openExternalUrl(link)  // 现状
```

---

## 8. 分阶段实现（建议）

### Phase M0 — 数据与类型（无播放器）

- [x] schema 6 列 + `Article` 映射  
- [x] parser enclosure / Atom / duration  
- [x] 卡片角标  
- [x] 评论短路 + 媒体专属 LLM 对话入口  
- [x] 解析与评论隔离单测  

### Phase M1 — 音频沉浸

- [x] `just_audio` + 详情音频控件  
- [x] 全局 mini + `audio_service` 通知  
- [x] 倍速 / ±15s  
- [ ] 真机：杀进程后系统通知是否符合 OEM 预期（文档说明即可）  

### Phase M2 — 视频

- [x] 详情视频面 + 全屏  
- [x] 错误/外链兜底  
- [x] 列表 play 角标  

### Phase M3 — 打磨（可选）

- [ ] 进度持久化 `media_progress`  
- [ ] 源级「播客」筛选  
- [x] Android 系统 PiP（手动小窗 + 回桌面自动进入）  
- [ ] 下载缓存  

---

## 9. 依赖与权限（Android）

| 项 | 说明 |
|----|------|
| 前台服务 | 音频后台可能需 FOREGROUND_SERVICE_MEDIA_PLAYBACK（targetSdk 视工程） |
| 通知 | 复用/新建 channel 如 `media_playback`（≠ `rss_updates`） |
| 网络 | 仅 stream；尊重用户流量心智（可选：wifiOnly 时提示） |
| 隐私 | `PRIVACY.md` 补充：媒体 URL 由用户订阅源提供，播放直连源站 |

---

## 10. 测试清单

### 单元

- MIME / 扩展名 / 默认 blog 表  
- duration 解析  
- upsert 不丢 bookmark；enclosure 更新  
- `mediaType != blog` → ensureGenerated no-op  

### 手工

- 真播客 RSS（例如公开 MP3 enclosure）  
- 假 video mp4 直链  
- 仅 HTML 无 enclosure → blog  
- 播放中切 Tab / 回 New → mini  
- 通知暂停/播放  
- 视频全屏进出  
- 无 Key 时音频稿不出现评论空态噪音  

---

## 11. 风险与决策

| 点 | 风险 | 决策 |
|----|------|------|
| 视频站无直链 | 无法应用内播 | 无 enclosure **不标 video**；用户走系统浏览器 |
| 包体积 | media_kit 较大 | 音频 just_audio；视频先 video_player，不够再换 |
| OEM 杀音频 | 与 RSS E-ROM 类似 | Set「后台被杀？」文案可复用；不承诺强后台 |
| 评论产品 | 用户以为媒体也能聊 | 明确隐藏；文案可后置「媒体稿暂无网友」 |
| 与 D-task | 无关 | 媒体不创建 comment_jobs |

---

## 12. 与 IMPLEMENTATION 的分工

| 文档 | 职责 |
|------|------|
| `IMPLEMENTATION.md` | 产品总规、债表、交接 §15、**链到本文** |
| **`MEDIA_PLAYER.md`（本文）** | 媒体类型 + 播放器专规；实现期改本文验收表 |

实现开工前：在 §15.3 把「P1」勾到本文件章节；schema 版本以当时 `app_database` 为准（D-task 已用 5，媒体预计 **6**）。

---

## 13. 决策记录（已确认）

| 日期 | 决策 |
|------|------|
| 2026-07-17 | 文章级 mediaType，非源级首版 |
| 2026-07-17 | 全局 mini player（非仅详情内嵌） |
| 2026-07-17 | **音视频不接 LLM** |
| 2026-07-17 | 新需求覆盖上一条：音视频不生成网友评论，改用独立、临时的 LLM 对话悬浮窗；上下文仅标题/节目说明/当前对话 |
| 2026-07-17 | P1 与 D-task 分离；D-task 优先代码，P1 先文档 |

---

*WEPSEED media — listen and watch without leaving the feed.*
