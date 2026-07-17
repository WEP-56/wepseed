# WEPSEED 功能实现文档

> 版本：**0.0.5**（tag `v0.0.5` · 开源 MIT · GitHub [WEP-56/wepseed](https://github.com/WEP-56/wepseed)）  
> 平台：Flutter · Android 首发 · 本地优先（local-only）  
> 状态：**0.0.5 代码完成，待真机安装验收**；包含 D-task + 音视频播放器 + 媒体专属 LLM 对话窗  
> 开关：`kUseMockFeed` / `kUseMockComments`（`lib/core/config/app_flags.dart`）

本文档只写**要做什么、做成什么样、怎么落地**。  
**新会话请从 §15 交接 + §1 现状 + §1.5 债表 起读。**

---

## 0. 产品目标（实现边界）

### 0.1 一句话

把 RSS 读成「可刷的信息流」：订阅像关注、详情像帖子、评论区是多角色「网友」点评与跟帖、ME 是个人阅读时间轴。

### 0.2 非目标（首版不做）

- 云同步 / 账号体系
- 社交真评论（用户之间）；网友↔网友互评
- iOS 首发（可预留，但不阻塞 Android）
- 完整 Web 端

### 0.3 首版必须闭环

| 能力 | 说明 | 进度 |
|------|------|------|
| 订阅 | 添加源、OPML 导入/导出、刷新 | **已接真**（Set + 源页） |
| 刷 | New masonry 流 + 源主页 | **真 Stream + 下拉刷新**（时间轨已移除；**筛选已接**） |
| 读 | 详情正文、已读、收藏 | **HTML 正文 + 图缓存 + 目录 scrubber**；外链系统浏览器 |
| 播 | RSS 音频 / 视频 | **文章级媒体识别 + 沉浸详情播放器 + 全局 mini + 音频后台通知 + 视频全屏** |
| 评 | TikTok 式评论区 + 多网友 | **真 LLM**；无 Key 不灌 mock；**去 think/tool 清洗**（0.0.4 真机通过）；**D-task 已接**（`comment_jobs` + one-off WM，待真机） |
| 回看 | ME 时间轴 | **Drift**；三 stat → 列表 CRUD（收藏/对话/痕迹，0.0.4 真机通过） |
| 设 | 形象、主题、字号、多提供商/网友、DATA、关于 | **大部分真持久化**；关于 = 真版本 + GitHub 更新/协议 |
| 推 | WorkManager + 本地通知 | **已接 + 加固**：冷启动重排程、后台 isolate 插件注册、通知 channel、杀进程仍周期刷源+通知（OEM 另见 E-ROM） |
| 发 | tag 驱动 Release | **已接** per-ABI APK + GitHub Actions（`v*`） |

---

## 1. 当前代码现状（2026-07-17 对照 · **0.0.5 RC**）

### 1.1 目录

```
lib/
  main.dart / app.dart / app_shell.dart   # AppShell: PopScope 双击退出；main→scheduleFromDatabase
  router/app_router.dart          # / · /article/:id · /source/:id · /me/bookmarks|chats|traces
  core/config/app_flags.dart · app_links.dart
  core/ui/app_toast.dart
  core/theme/…  core/utils/…    # open_url · time_labels · monogram · feed_filter
  core/background/                # RSS WorkManager + 本地通知 · 选源限刷
  data/
    models/models.dart
    mock/mock_data.dart
    db/tables.dart + app_database.dart   # Drift schemaVersion = 6（comment jobs + media fields）
    comments/                     # comment_job_models · comment_generation_engine
    rss/ · llm/                   # HttpLlmClient 重试 + llm_text_sanitize
    update/github_update_service.dart
    repositories/ …              # + comment_job_repository*
  providers/ …
  features/
    new/ …  media/（player + LLM chat）…  me/（me_page + me_list_page）…
    set/  set_page · llm_settings_section
  widgets/ glass_bottom_nav · edge_scrubber · …
docs/
  IMPLEMENTATION.md · MEDIA_PLAYER.md · TERMS.md · PRIVACY.md
  SIGNING.private.md
.github/workflows/
  ci.yml · release.yml
android/
test/
  fixtures/ · rss_parser · toc · feed_filter · llm_client · llm_text_sanitize · semver · warm · widget · background_refresh · comment_job_repository
```

### 1.2 已可交互（真 / 半真）

| 模块 | 状态 |
|------|------|
| 壳 / 路由 | go_router；三 Tab；**根页** 双击退出；ME 子路由列表 |
| 主题 / 字号 / 形象 | Drift 持久化 |
| 多提供商 × 多模型 | Drift + Key；**测试连接** |
| 多网友 CRUD | Drift |
| 评论区 | 真 LLM；clearAll；重试；**sanitize 去 think/tool**（**0.0.4 真机通过**） |
| New / 源 / 详情 | 真流 + 筛选 + HTML + scrubber + dwell |
| 媒体 | RSS/Atom 音视频识别；音频后台/通知/倍速；视频全屏；全局 mini；媒体专属 LLM 对话窗 |
| 通知深链 | **`push`**；返回栈 **真机通过** |
| ME | 时间轴 + **收藏/对话/痕迹列表 CRUD**（**0.0.4 真机通过**） |
| Set · RSS / 关于 / DATA | 订阅 OPML；更新安装；**后台被杀？** 提示 |
| 后台推送 | WM 周期刷源 + 本地通知（**0.0.4 综合测通过**） |
| 发布 | MIT；`v0.0.1`–`v0.0.4` per-ABI APK |

### 1.3 明确未做 / 下一会话主路径

**0.0.5 代码与自动化测试已通过**；D-task 与媒体功能待本轮真机安装验收。

| 优先级 | 项 |
|--------|-----|
| 中 | **0.0.5 真机验收**：D-task 杀进程恢复；音频后台/通知；视频全屏；媒体 AI 对话 |
| 低 | 媒体 M3：进度持久化、下载缓存、视频 PiP |
| 中 | E-ROM 长期：极端省电/多 ROM 文档与验收可继续补 |
| 低 | 评论流式气泡；应用内 WebView（§15.6） |
| 基建 | CI Actions Node 20 弃用告警可择机升 action 大版本 |

### 1.4 关键接线（勿重造）

| 点 | 现状 | 注意 |
|----|------|------|
| Feed/Article DI | `kUseMockFeed ? Mock* : Drift*` | 默认 **false** |
| 删除源 | 硬删 feed + articles | 见 `DriftFeedRepository` 注释 |
| Guid | guid → link → sha1(title\|published) | 刷新 upsert 不重复 |
| 外链 | `openExternalUrl` → 系统浏览器 | WebView 见 §15.6 |
| Scrubber | `EdgeScrubber` | **仅详情** h1–h3；New **不挂**时间轨 |
| LLM | `http_llm_client` + `scheduled_llm_client` + **`llm_text_sanitize`** | 重试 `_postJson`；测连绕过 scheduler；入库前清洗 think/tool |
| Toast | `lib/core/ui/app_toast.dart` + `appMessengerKey` | 勿再裸 `SnackBar` 贴底 |
| 返回 | `AppShell` `PopScope` | 仅根 `/`；子路由正常 pop |
| 通知深链 | `app.dart` `_openDeepLink` → **`router.push`** | **勿用 `go`** |
| RSS 后台 | `BackgroundRefreshService` + `runRssRefreshJob` | 冷启动 `scheduleFromDatabase`；`DartPluginRegistrant`；无 battery-not-low；channel 先建 |
| ME 列表 | `me_list_page` · `/me/bookmarks|chats|traces` | 收藏=article 书签；对话/痕迹=warm 事件；左滑删 / 清空 |
| New 筛选 | `FeedFilter` + `filteredArticlesProvider` | 今日∩未看∩源；**选源才限刷** |
| 更新 | `GithubUpdateService` + Set `_UpdateSheet` | `wepseed-*-{abi}.apk` |
| 链接常量 | `lib/core/config/app_links.dart` | TERMS/PRIVACY/API |
| 签名 | `docs/SIGNING.private.md`（本地 only） | 勿提交 jks / key.properties |
| 评论清空 | `CommentRepository.clearAll` | 同步 cancel `comment_jobs`；清脏评论 / 旧 mock 后重生成 |
| 评论任务 | `comment_jobs` + `comment_job_items` · `CommentGenerationEngine` · `runCommentJobsDrain` | taskName **`wepseed.drain-comment-jobs`**（≠ RSS）；租约防 UI/WM 双跑；冷启动 `recoverCommentJobsOnColdStart` + UI `recoverPendingJobs` |
| 媒体 | `mediaSessionProvider` + `DetailMediaPlayer` + `MiniMediaPlayer` | 全局单会话；媒体 AI 对话不写 comments/jobs |

### 1.5 已知问题 / 技术债（登记 · **D-task 代码后**）

> 下会话：根据 0.0.5 真机反馈修复；M3 / E-ROM / F 余可选。

| # | 现象 | 状态 |
|---|------|------|
| D1 | 评论乱码 / 方块 / 西里尔 | **关闭**（真机通过） |
| D2 | 模型保存失败 | **关闭** |
| D3–D7 | mock / 场景 / 时间轨 / 状态 / 绑定 | **已改** |
| F-back / F-notif-back / F-filter / F-toast / F-about / F-llm | UX 债 | **关闭**（0.0.2–0.0.3 真机） |
| F-comment-think | 评论展示思考过程 / toolcall | **关闭**（`sanitizeLlmCommentText`；**0.0.4 真机通过**） |
| F-me-lists | ME 收藏/对话/痕迹不可点 | **关闭**（列表 CRUD；**0.0.4 真机通过**） |
| **D-task** | 评论生成杀进程丢任务 | **代码已接**（schema 5 + one-off WM）；**待真机验收** |
| **P1-media** | 音视频播放器与媒体 AI 对话 | **代码已接**（schema 6）；**待真机验收** |
| E-ROM | 厂商杀后台 | Set 有提示；**0.0.4 综合测无问题**；极端 ROM 长期可续 |

**RSS 后台（杀进程仍通知）— 已加固 + 0.0.4 测过：**

| 点 | 做法 |
|----|------|
| 冷启动重排程 | `main` → `BackgroundRefreshService.scheduleFromDatabase()` |
| 后台 isolate 插件 | `DartPluginRegistrant.ensureInitialized()` + 独立 `AppDatabase` |
| 通知 channel | `createNotificationChannel`（`rss_updates`） |
| 约束 | 仅 network（wifiOnly→unmetered）；**去掉** `requiresBatteryNotLow` |
| 关通知开关 | 仍周期拉源；**不** post 本地通知 |
| 任务名 | `wepseed.periodic-rss-refresh` / `wepseed.refresh-feeds` |
| OEM 边界 | 强制停止 / 超激进省电仍可能停 WM，需用户放行自启动 |

**D-task（评论杀进程恢复）— 已实现：**

| 点 | 做法 |
|----|------|
| 表 | `comment_jobs` + `comment_job_items`（schemaVersion **5**） |
| 采样 | 创建 job 时写死 `pickedNetizenIdsJson`，恢复**不重掷** |
| 部分完成 | 已有某网友顶层评则 item 记 succeeded，只跑剩余 |
| 租约 | `leaseOwner` + `leaseUntil`；过期冷启动 `releaseExpiredLeases` |
| 生成核 | `CommentGenerationEngine`（UI + WM 共用） |
| WM | one-off `wepseed.oneoff-comment-jobs` / task `wepseed.drain-comment-jobs` |
| 冷启动 | `recoverCommentJobsOnColdStart` + App `recoverPendingJobs` |
| 边界 | 用户回复网友仍进程内 Future（非 D-task 范围） |  

---

## 2. 信息架构

### 2.1 三 Tab

| Tab | 图标 | 职责 |
|-----|------|------|
| New | search | 全局发现流 + 顶部订阅条 |
| ME | 用户 monogram | 个人轨迹 |
| Set | home | 设置 |

底栏：悬浮胶囊、**仅图标**、liquid glass、高度约 46、左右大 inset。

### 2.2 路由（已实现 go_router）

```
/                 → AppShell（壳内 tabIndex，非 path tab）
/article/:id      → ArticleDetailPage
/source/:id       → SourceFeedPage
/me/bookmarks     → MeListPage（收藏）
/me/chats         → MeListPage（对话）
/me/traces        → MeListPage（痕迹）
```

Set 内 sheet 仍用 `showModalBottomSheet`（提供商/网友编辑）。深链通知进文章：已有 `/article/:id`。

---

## 3. 领域模型（对照 Drift + models.dart）

### 3.1 表 / 实体（schemaVersion = 6）

```text
# RSS（Phase B 主写）
feeds
  id, title, url UNIQUE, siteUrl?, iconUrl?,
  lastFetchedAt?, etag?, lastModified?,
  isPaused, createdAt

articles
  id, feedId → feeds, guid, link?,
  title, author?, summary, contentHtml?, contentText,
  imageUrl?, imageAspect, featured, tagsJson,
  publishedAt, fetchedAt,
  isRead, isBookmarked, readAt?, bookmarkedAt?
  UNIQUE(feedId, guid)

# 评论区 / LLM 配置（A+ 已写）
llm_providers   id, name, protocol, baseUrl, isEnabled,
                maxConcurrent, requestsPerMinute, sortOrder, …
llm_models      id, providerId, modelId, displayName, isDefault, …
netizens        id, name, styleLabel?, systemHint, avatarPath?,
                weight, providerId?, modelId?, isEnabled, …
comments        id, articleId, authorType(user|netizen),
                netizenId?, parentId?, content, createdAt

# D-task 评论生成任务
comment_jobs    id, articleId, status, trigger, pickedNetizenIdsJson,
                attempt, maxAttempts, lastError?, leaseOwner?, leaseUntil?,
                createdAt, updatedAt
comment_job_items id, jobId → comment_jobs, netizenId, status,
                attempt, lastError?, commentId?, sortOrder, createdAt, updatedAt

user_profiles    id=default, displayName, …
app_settings    themeMode, fontScale, refreshMinutes, wifiOnly,
                notificationsEnabled, useMockFeed, commentTrigger,
                feedFilterJson,  # New 页筛选 {onlyToday,onlyUnread,feedIds}
                # 遗留列 llmBaseUrl/llmModel 不再作为产品配置
# apiKey → secure: llm.provider.{providerId}.apiKey

warm_events     id, type, title, subtitle, articleId?, …
# 遗留：companions / chat_sessions / chat_messages（不再主路径）
```

### 3.2 展示模型约定

| UI / 领域 | 说明 |
|-----------|------|
| `FeedSource` | 展示用源；DB 为 feeds，repo join 或映射 |
| `Article.source` | **仍内嵌** `FeedSource`，UI 不改 join |
| `Comment` + `Netizen` | 评论区；替代旧单伴侣私聊 |
| `LlmProvider` / `LlmModel` | 多提供商配置 |
| `MeEvent` | ME 时间轴展示（warm + bookmark/comment 文案） |
| 未读 | B 起：`COUNT(articles WHERE feedId=? AND isRead=0)` |

### 3.3 唯一键

- Feed：`url` unique  
- Article：`(feedId, guid)` unique；刷新 **upsert**  
- 无 guid 时可用 link 或哈希兜底（实现时定一条规则写进代码注释）

---

## 4. 功能规格（按模块）

### 4.1 订阅管理（RSS）

**用户故事**

- 添加单个 RSS/Atom URL
- 导入 OPML，导出 OPML
- 暂停/删除源
- 手动刷新 / 按频率后台刷新

**实现要点**

1. `http` 拉 XML → 解析 RSS 2.0 / Atom  
2. 推荐库调研顺序：`webfeed` / `rss_dart` / 自研轻量解析（按实测选）  
3.  favicon：`siteUrl/favicon.ico` 或 HTML `<link rel=icon>`（可后置，先 monogram）  
4. 错误：超时、非 feed、SSL → 可读错误文案  
5. 刷新策略：
   - 前台：下拉刷新全局 / 源主页
   - 后台：`workmanager` 周期任务（15/30/60/120 分钟，设置项）
   - 约束：网络；可选仅 Wi‑Fi

**验收**

- [ ] 添加合法源后 New 出现文章  
- [ ] OPML 导入至少 5 源不崩溃  
- [ ] 重复刷新不产生重复文章  
- [ ] 删除源后文章级联或软隐藏策略明确

---

### 4.2 New 信息流

**布局**

- 顶：标题 New + **筛选**（tune；非默认红点）
- 筛选规则（持久化 `app_settings.feedFilterJson`）：
  - **全都要看**（默认）：清今日/未看/源限制
  - **只看今日** / **只看未看**：可叠加
  - **只看这些源**：多选；可与今日/未看 AND
  - 列表：`filteredArticlesProvider` 客户端过滤
  - 刷新：仅 `feedIds` 非空时 New 下拉 + 后台 `refreshAll(feedIds:)` 限刷
- 订阅条：横向源列表（**始终全源**，不随筛选隐藏）
- 可选精选大卡（过滤后列表的最新）
- 双列 masonry：`flutter_staggered_grid_view`

**卡片规则**

| 类型 | 条件 | UI |
|------|------|----|
| 图卡 | 有 `imageUrl` | 图按 `imageAspect` + 标题 + 源·时间 |
| 文字卡 | 无图 | 浅灰底 + 源名大写 + 标题 + 摘要 |

**已读态**

- `opacity ≈ 0.55`
- 图卡角标「已读」/ 文字卡双勾图标
- 进入详情即 `isRead=true`（可配置「滑过即读」，首版打开即读）

**订阅条**

- monogram 圆标 + 名
- 右上角红点：未读数（>99 显示 99+）
- 有未读：描边更深
- 点击 → `/source/:id`
- 进入源主页：将该源未读清零（`markSourceSeen`）或仅清「徽标」保留文章未读——**首版采用进入即清未读计数 + 文章标已读**（与原型一致）；若过猛可改为「只清 badge」

**验收**

- [ ] 20+ 文章滚动流畅（目标 60fps 中端机）
- [ ] 无图/有图混排不错位
- [ ] 已读前后对比清晰但不「脏」

---

### 4.3 源主页（Source Feed）

**结构**

- 顶栏玻璃：返回 / more（管理源）
- 头：monogram、源名、domain、篇数、已订阅 pill
- 下：该源 masonry（同 New 卡片组件）

**More 菜单（待做）**

- 刷新此源
- 暂停更新
- 取消订阅
- 浏览器打开主页
- 复制 feed URL

**验收**

- [ ] 只显示该 feed 文章  
- [ ] 从订阅条进入 badge 行为符合规格  

---

### 4.4 文章详情

**结构**

- 可选封面 Hero
- 源 monogram + 名 + 相对时间
- 标题 / 摘要 / tags
- 正文

**正文渲染策略（需选型）**

| 方案 | 优点 | 缺点 | 建议 |
|------|------|------|------|
| A. HTML → Flutter 富文本（`flutter_html`） | 原生滚动一体 | 复杂 HTML 易挂 | **首版推荐** |
| B. WebView | 还原度高 | 手势/玻璃叠层麻烦 | 复杂页 fallback |
| C. 只显示 contentText | 稳 | 丢格式 | 无 HTML 时兜底 |

**右侧操作条（liquid glass）**

| 按钮 | 行为 |
|------|------|
| Save | toggle bookmark + ME 事件 |
| Chat | 打开评论抽屉 |
| More | 分享 / 导出 MD / 稍后读 / 减少此源 / 复制链接 |

**顶栏**

- 返回
- 外部浏览器打开原文 link

**驻留温度（WarmEvent）**

- 详情停留 ≥ 180s → 写 `dwell` 事件（每文章每天最多 1 次）
- 实现：`Timer` / `VisibilityDetector` + `readAt`

**验收**

- [ ] 打开即已读  
- [ ] 收藏状态返回列表仍正确  
- [ ] Chat 抽屉不遮死输入法  

---

### 4.5 评论区 = 多网友（当前：配置真 / 内容真 LLM）

**产品形态**

- 详情操作条：`评论`（非 Chat）
- TikTok 式简易评论流：网友顶层评 → 用户可「回复」挂在其下 → 被 @ 网友可 mock 回一条
- **不做**网友↔网友互评

**网友（Netizen）**

- 预设 4 位：总结君 / 辣评姐 / 冷淡叔 / 中立菌
- 字段：name、styleLabel、systemHint、avatarPath、weight(0–1 出现概率)、providerId、modelId、isEnabled
- 每篇文章独立掷骰采样；**至少选中 ≥1 人**；结果入库，重开不重掷

**评论触发（AppSettings.commentTrigger）**

| 值 | 行为 |
|----|------|
| off | 不自动生成 |
| onBrowse | 打开详情时 generate |
| onOpenComments | 展开评论 sheet 时 generate（默认） |

**多提供商 / 多模型（真实持久化）**

- `LlmProvider`：name、protocol（openai_chat / openai_responses / anthropic_messages）、baseUrl、Key(secure per id)
- `LlmModel`：挂在 provider 下，可设默认
- 真 HTTP 请求经提供商共享队列执行；并发/RPM 配置持久化到 provider

**验收（当前）**

- [x] Set 可 CRUD 提供商 + 模型 + per-provider Key  
- [x] Set 可 CRUD 网友（人设 / 权重 / 模型绑定 / 头像）  
- [x] 评论触发三项可切换  
- [x] 详情评论区多网友 + 用户回复  
- [x] 真 LLM 按网友绑定模型请求（Phase D）

---

### 4.6 ME 时间轴

**数据来源（合并视图）**

1. 收藏事件  
2. 对话事件（摘要第一条回复或用户首句）  
3. WarmEvent（驻留/连读/连续源/夜读）

**排序**：`createdAt DESC`，按「今天/昨天/星期/日期」分组。

**温度规则引擎（本地）**

| type | 触发 |
|------|------|
| dwell | 单篇停留 ≥ 3min |
| binge | 当日打开文章数 ≥ 10 |
| streak | 连续 ≥ 3 天阅读同一 feed |
| nightOwl | 本地时 0:00–5:00 有阅读 |

文案要短、具体、不鸡汤。去重：同 type + 同日 + 同 article 不重复刷屏。

**验收**

- [ ] 收藏/对话即时出现在顶部  
- [ ] 温度事件不刷屏  
- [ ] 点击事件能进对应文章（若有 articleId）

---

### 4.7 Set 设置

#### 常规

- 我的形象：`displayName` → monogram  
- 外观：system/light/dark  
- 阅读字号：0.9–1.3 倍（`MediaQuery.textScaler`）

#### RSS

- 订阅源列表（增删改查、暂停）  
- 导入 OPML  
- 导出 OPML  
- 刷新频率  

#### LLM

- 阅读伴侣编辑  
- API Key（secure）  
- Base URL / Model  
- （可选）测连按钮  

#### DATA

- 更新通知开关  
- 仅 Wi‑Fi  
- 清理缓存（图片缓存目录）  
- 导出数据（JSON：收藏/设置/对话，**不含 Key**）  

#### 关于

- 检查更新（Android：可后接 GitHub Release / 应用商店）  
- 用户协议  
- 隐私政策（强调 local-only + LLM 外发说明）  
- 关于 WEPSEED  

**验收**

- [ ] 主题/字号即时生效并持久化  
- [ ] Key 杀进程后仍在且不明文落盘到日志  
- [ ] 关于四项可打开  

---

### 4.8 通知与后台

**栈**

- `workmanager`：周期拉 feed  
- `flutter_local_notifications`：本地通知  

**当前实现（Android · 杀进程可刷源通知）**

- **冷启动**：`main` 调 `scheduleFromDatabase()`（读 Drift 设置并 `registerPeriodicTask`）；设置变更时 `configure` 再 update
- 最短周期 **15 分钟**（Android WM 下限）；`ExistingPeriodicWorkPolicy.update`
- `wifiOnly=true` → `NetworkType.unmetered`；否则 `connected`；**不**要求电量非低
- 后台 isolate：`DartPluginRegistrant` → 独立 Drift → `refreshAll`（选源限刷同 New 筛选 `feedIds`）
- 刷新前后 article id 差集 = 新文；最多通知 **3** 篇；payload `/article/:id`
- 通知 channel `rss_updates` 在 `NotificationService.initialize` **显式创建**（后台 isolate 同样走 initialize）
- 关「更新通知」：仍拉源，不 post
- Android 13+：开通知时 `requestNotificationsPermission`
- **导航**：深链 **`router.push`**；详情/源 `canPop`? pop : `go('/')`
- Set · DATA：「后台被杀？」提示用户开自启动/电池无限制

**通知文案**

- 避免「你有 3 条更新」  
- 优先：`{源名} · {文章标题}`  
- 点击 deep link → `/article/:id`（**push**，非 go）  

**权限**

- Android 13+ 通知权限请求（设置页也可二次打开）  

**验收**

- [x] 开关关闭后不弹  
- [x] 仅 Wi‑Fi 映射为 unmetered 后台约束  
- [x] 点击通知进对应文章  
- [x] **通知进帖 → 系统返回 / 顶栏返回 → 回到进通知前界面**（热启动）；冷启至少回壳 `/`（**0.0.3 真机通过**）  
- [x] 杀进程后周期任务仍注册：冷启动重排程 + isolate 插件注册 + channel（**代码已加固**）  
- [ ] 国产 ROM 杀后台/省电模式 **长期实机**（用户测：关 app 后是否仍收到新文通知）  

---

## 5. 技术架构（正式实现建议）

### 5.1 分层

```
presentation (features/*)
    ↓
application / providers (riverpod)
    ↓
domain (models, repositories interfaces)
    ↓
data (rss, llm, db, secure_storage, notifications)
```

### 5.2 推荐依赖

| 用途 | 包 |
|------|-----|
| 状态 | `flutter_riverpod` |
| 路由 | `go_router` |
| DB | `drift` + `sqlite3_flutter_libs` |
| 安全存储 | `flutter_secure_storage` |
| 网络 | `http` 或 `dio` |
| 图片缓存 | `cached_network_image` |
| HTML | `flutter_html`（或选型结果） |
| 后台 | `workmanager` |
| 通知 | `flutter_local_notifications` |
| 字体 | `google_fonts`（Inter） |
| 布局 | `flutter_staggered_grid_view` |
| OPML | 自研 XML（小）或现成工具 |

> Phase A 已引入 riverpod / drift / go_router；`AppState` 已删除。文章路径仍走 Mock*Repository。

### 5.3 Provider 地图（当前）

| Provider | 来源 |
|----------|------|
| `feedsProvider` / `feedByIdProvider` | FeedRepository |
| `articlesProvider` / `articlesByFeedProvider` / `articleByIdProvider` | ArticleRepository |
| `unreadCountsProvider` / `isRead` / `isBookmarked` / `articleActions` | ArticleRepository |
| `settingsProvider` / `userProfileProvider` / `settingsController` | SettingsRepository |
| `llmProvidersListProvider` / `llmModelsForProviderProvider` / `llmConfigController` | LlmProviderRepository |
| `netizensProvider` / `netizenController` | NetizenRepository |
| `commentsForArticleProvider` / `commentController` | CommentRepository |
| `meTimelineProvider` | WarmEventRepository |
| `tabIndexProvider` | 纯 UI |

### 5.4 玻璃 UI

- 统一组件：`LiquidGlass` / `LiquidGlassIconButton` / `LiquidGlassCircleAction`
- 原理：`BackdropFilter` blur + 半透明渐变 + 高光描边  
- 性能：列表项避免每卡一块 blur；blur 仅用于底栏/顶栏/操作条/抽屉壳  
- 若未来上真 Liquid Glass shader：可替换实现，接口保持 `LiquidGlass`  

---

## 6. UI / UX 规范（实现时勿回退）

### 6.1 视觉

- 色：近黑 / 近白 / 灰阶；**不要**大面积彩色强调  
- 红：仅未读 badge  
- 圆角：卡片 14、底栏胶囊 ~28、按钮 12  
- 边框：0.5px hairline  
- 字体：Inter；中文系统 fallback  
- 头像：monogram，不用 emoji 堆氛围  

### 6.2 动效

- Tab 切换：Fade + 轻微 Slide（~280ms）  
- 按压缩放：`Pressable` 0.97  
- 路由：详情 Fade；可加 Hero 封面  
- 克制，不弹跳过度  

### 6.3 文案语气

- 短、准、产品感  
- 温度事件像轻声旁白，不像运营 Push  

---

## 7. 数据流关键路径

### 7.1 刷新一篇源

```
User/WorkManager
  → FeedRepository.refresh(feedId)
  → HTTP GET feedUrl (If-None-Match / If-Modified-Since)
  → Parse items
  → Upsert articles
  → Recompute unread
  → If newItems && notificationsEnabled → notify
  → providers invalidate
```

### 7.2 打开文章

```
Open detail
  → ArticleRepository.markRead(id)
  → unread--
  → start dwell timer
  → on dispose: if elapsed>=3min → WarmEventRepository.add(dwell)
```

### 7.3 评论（Phase D 真 LLM）

```
open comments / onBrowse
  → CommentController 按 articleId 去重任务
  → CommentRepository.ensureGenerated(articleId)
  → 若该文已有 comments 行 → return（故脏数据会占坑，需 clear）
  → 权重采样 netizens（≥1）
  → resolveLlmConfigForNetizen(provider/model/key)
  → ScheduledLlmClient（按 providerId 共享并发 + 滑动窗口 RPM）
  → HttpLlmClient.complete
       无 Key / 未解析 → skip（不 insert mock）
       kUseMockComments → 仅测试 mock
       失败 → 任务失败状态（不写伪评论气泡）
  → 每个请求完成即 insert top-level comment（逐条可见）
  → 应用级完成事件；不在评论页时 SnackBar「查看」
user reply(parentId, text)
  → insert user comment
  → 显示「网友正在回复你」
  → 被 @ 网友真回复（同 provider 队列；无 Key 则不回）
  → 回复树递归展示，不限一层
  → MeEvent chat/comment
Set「清除全部评论」→ clearAll() → 下次可重生成
```

### 7.4 评论任务生命周期（D-task）

```text
Job:  pending → running → completed | failed | cancelled
Item: pending → running → succeeded | skipped | failed
                  ↘ provider lane（maxConcurrent + RPM）
```

- `CommentController`：同进程 `_generationTasks` 去重；写/续 `comment_jobs`；页面关闭后进程内仍可续；杀进程靠 DB + WM/冷启动。
- `CommentJobRepository`：创建 job（采样一次）、claim 租约、item 状态、finalize、releaseExpiredLeases。
- `CommentGenerationEngine`：UI isolate 与 WM isolate 共用；已存在该网友顶层评则 skip LLM。
- `ScheduledLlmClient`：提供商级 FIFO；默认并发 1。
- `CommentActivityNotifier`：直播进度 + `hydrateFromJob` 冷启动水合。
- `CommentRepository`：成功一条写一条；clear 时 cancel jobs；无 Key → item skipped。
- WM：`runCommentJobsDrain` / taskName `wepseed.drain-comment-jobs`（与 RSS 分离）。
- **边界**：用户回复→网友回帖仍进程内 Future（未入 job 表）。

---

## 8. 分阶段实施计划

### Phase A — 基础设施 ✅

- [x] riverpod / go_router / drift  
- [x] settings + profile 持久化；API Key secure  
- [x] 删除 `AppState`  
- [x] `kUseMockFeed` + Mock Feed/Article  
- [x] 路由 `/` · `/article/:id` · `/source/:id`  

### Phase A+ — 多网友评论区 ✅

- [x] 多 LlmProvider × LlmModel + per-provider Key  
- [x] 多 Netizen CRUD + weight + commentTrigger  
- [x] TikTok 式 `comment_sheet`（内容 mock，comments 表）  
- [x] 详情 Chat → 评论  

### Phase B — 真实 RSS + New 接真数据 ✅

- [x] 依赖：`http` + `xml` + `crypto`；自研 RSS2/Atom 解析  
- [x] `DriftFeedRepository` / `DriftArticleRepository`  
- [x] `core_providers` 按 `kUseMockFeed` 切换  
- [x] `addFeed(url)`：GET → parse → insert feed → upsert articles  
- [x] `refreshFeed` / `refreshAll`：ETag/Last-Modified + upsert  
- [x] 已读 / 收藏 / 未读写 `articles` 列并 Stream 出去  
- [x] New / 源主页 / 详情接真 Stream（布局未重写）  
- [x] Set：订阅源列表、添加 URL、删除/暂停、OPML 粘贴导入/剪贴板导出  
- [x] 下拉刷新（New 全局 + 源页单源）  
- [x] 空态：无源引导「去添加订阅」  
- [x] 默认 0 源（非 mock）；`kUseMockFeed=false`  

### Phase C — 详情与阅读质量 ✅

- [x] HTML 渲染（`flutter_html` + `ArticleBody`；无 HTML 则纯文本）  
- [x] 内联脏样式清洗 `sanitizeArticleHtml`（去 color/opacity）  
- [x] 深色正文对比度（近白正文 + 提亮 secondary/tertiary）  
- [x] 图片缓存 `cached_network_image`（列表/精选/封面/正文 img）  
- [x] 外链：`url_launcher` **系统浏览器**（`openExternalUrl`）  
- [x] 复制链接 / 分享 / 导出 Markdown  
- [x] dwell ≥180s → WarmEvent（每文每天最多 1 次；Drift 持久化）  
- [x] **EdgeScrubber**：详情 h1–h3 目录跳转（New 时间轨已产品决策移除）  
  - 左侧中部细横杠；拖动当前杠变长变深；右侧浮层标题  
  - 右滑超过约 56px →「松开取消」  
  - 至少 2 个锚点才显示  
- [ ] 应用内 WebView（cookies / 下载）→ **Phase F，见 §15.6** 

### Phase D — 真 LLM ⚠ **主路径已接，体验未收口**

- [x] 按 `LlmProtocol` 实现 `HttpLlmClient`（chat/completions、responses、anthropic messages）  
- [x] 网友绑 `providerId`/`modelId` + secure Key 请求（`resolveLlmConfigForNetizen`）  
- [x] 无 Key → **不灌 mock**（空评论区）；`kUseMockComments` 仅测试  
- [x] 失败友好占位（不崩）；Set「清除全部评论」  
- [x] 场景帧 `kWepseedCommentScene` + 人设只写语气（`llm_prompt.dart`）  
- [x] 模型编辑改 Dialog + 写后校验（D2 已验收）  
- [x] **D1 评论乱码 / 编码**（UTF-8 + 脏文本拒绝；**真机通过**）  
- [x] D2 模型保存真机验收通过  
- [x] D6 生成状态 / 完成提醒 / 空结果重试 / 失败不写伪气泡  
- [x] 提供商共享并发 + RPM 队列；默认依次请求、逐条显示  
- [x] 用户回复与 LLM 回复多层线程展示  
- [x] HTTP 有限重试（超时 / 网络 / 429 / 5xx；401 不重试）  
- [x] 提供商编辑 **测试连接**（独立 HttpLlmClient，不占评论队列）  
- [x] **评论清洗** `sanitizeLlmCommentText`（think/tool/纯计划独白；**0.0.4 真机通过**）  
- [x] **D-task**：`comment_jobs` / items + Engine + one-off WM + 冷启动恢复 — **代码已接，待真机**  
- [ ]（可选）流式输出到评论气泡  

### Phase E — ME 温度与通知 ✅ 主路径

- [x] warm 规则 binge/streak/nightOwl + 同日去重  
- [x] ME / warm / dwell **Drift 持久化**  
- [x] **ME 收藏/对话/痕迹列表**（左滑删、清空、进文章；**0.0.4 真机通过**）  
- [x] WorkManager + 本地通知 + `/article/:id` 深链（RSS；不含评论 D-task）  
- [x] 冷启动重排程 / isolate 插件 / channel（**0.0.4 综合测通过**）  
- [ ] 厂商 ROM 极端省电长期文档（可选）  

### Phase F — 打磨 ⚠ 部分已接（0.0.4 真机通过）

- [x] 根页返回拦截（双击退出）  
- [x] 关于：真版本 / 检查更新安装 / 协议隐私  
- [x] 统一 Toast  
- [x] MIT + Release CI + Maven 官方优先  
- [x] New 筛选（真机通过）  
- [x] 测试：LLM · sanitize · feed_filter · semver · background 常量  
- [ ] 性能 / 错误空态补强  
- [ ] **应用内 WebView**（§15.6）  

> 下一会话：可选 **D-task** / 流式 / WebView。

---

## 9. 测试清单（实现期）

### 9.1 单元

- feed 解析：RSS / Atom 样例夹具  
- OPML import/export roundtrip  
- unread count 聚合  
- warm rule 触发与去重  
- 上下文截断长度  

### 9.2 集成

- 刷新入库不重复  
- markRead 后 UI badge  
- chat session 续写  

### 9.3 手工

- 弱网 / 断网  
- 错误 feed URL  
- 超长标题/无摘要  
- 通知点击冷启动  

---

## 10. 风险与决策点

| 点 | 风险 | 建议决策 |
|----|------|----------|
| HTML 正文 | 各站质量差 | 先 `content:encoded`/`description` 清洗 + flutter_html，烂页转 WebView |
| 图片热链 | 403/尺寸乱 | 缓存 + 失败降级文字卡 |
| LLM 费用 | 用户 Key 自付 | 明确本地、不设中转；可显示估算 token |
| WorkManager 厂商限制 | 国产 ROM 杀后台 | 设置页说明 + 前台手动刷新兜底 |
| 玻璃性能 | 低端机掉帧 | 减少 blur 层；列表禁用毛玻璃 |
| 未读策略 | 进源页全已读过猛 | 可配置；默认与原型一致，收集反馈再改 |

---

## 11. 仓库接口（代码已有，B 补实现）

```dart
// lib/data/repositories/feed_repository.dart — 已存在
abstract class FeedRepository {
  Stream<List<FeedSource>> watchFeeds();
  Future<FeedSource?> getFeed(String id);
  Future<void> addFeed(String url);
  Future<void> removeFeed(String id);
  Future<void> refreshFeed(String id);
  Future<void> refreshAll({bool wifiOnly = false});
  Future<void> importOpml(String xml);
  Future<String> exportOpml();
}

// lib/data/repositories/article_repository.dart — 已存在
abstract class ArticleRepository {
  Stream<List<Article>> watchTimeline({String? feedId});
  Future<Article?> get(String id);
  Future<void> markRead(String id);
  Future<void> setBookmarked(String id, bool value);
  Stream<Map<String, int>> watchUnreadCounts();
  Future<void> markSourceSeen(String feedId);
  Stream<Set<String>> watchReadIds();
  Stream<Set<String>> watchBookmarkedIds();
  bool isRead(String id);
  bool isBookmarked(String id);
}

// 评论 / 网友 / 提供商 — A+ 已有 Drift 实现
// CommentRepository / NetizenRepository / LlmProviderRepository

// Phase D
abstract class LlmClient {
  Stream<String> complete(List<LlmMessage> messages, LlmConfig config);
}
```

UI 只依赖接口；**Phase B 新增 `DriftFeedRepository` / `DriftArticleRepository`，在 `core_providers.dart` 切换，勿改 New 卡片布局。**

---

## 12. 验收总表（MVP）

### 已完成（A–D）

- [x] 基础设施 Riverpod / Drift / go_router  
- [x] 主题 / 字号 / 形象持久化  
- [x] 多提供商 × 多模型 + secure Key  
- [x] 多网友 + 评论触发 + **真 LLM 评论**  
- [x] 真 RSS + New/源/详情真数据  
- [x] 已读 / 收藏持久化；OPML；空态；下拉刷新  
- [x] HTML 正文 / 图缓存 / 系统浏览器外链 / 分享复制  
- [x] EdgeScrubber（**仅详情**目录；New 无时间轨）  
- [x] 深色正文对比度  

### 更后 / 0.0.3–0.0.4

- [x] 后台刷新 + 通知进文章（E；**0.0.4 综合测通过**）  
- [x] ME warm 持久化 + 温度规则（E）  
- [x] ME 收藏/对话/痕迹列表 CRUD（0.0.4；**真机通过**）  
- [x] 返回 / Toast / 关于更新安装 / LLM 重试·测连 / Release  
- [x] 通知深链返回栈 + New 筛选（0.0.3；**真机通过**）  
- [x] 评论 think/tool 清洗（0.0.4；**真机通过**）  
- [x] **D-task** 评论任务持久化 + WM 恢复（**代码已接**；真机验收后 0.0.5）  
- [ ] 应用内 WebView（F 余）  
- [x] P1 媒体类型 + 音视频播放器 + 全局 mini + 媒体专属 LLM 对话窗（待真机）

---

## 13. 附录：设计 token（实现时保持）

```text
Light canvas:  #FAFAFA
Dark ink:      #0A0A0A
Card dark:     #181818
Text primary:  #0F0F0F / #F5F5F5
Text secondary:#737373 / #C4C4C4   # 深色已提亮，忌再用 #6B6B6B 级
Text tertiary: #A3A3A3 / #9A9A9A
Body dark:     #F0F0F0（详情 HTML 强制；并 strip 内联 color）
Badge red:     #E11D48
Hairline:      black/white 6–10% alpha
Font:          Inter + system CJK
Scrubber:      左侧中部细横杠；选中变长变深；右滑取消
```

---

## 14. 文档维护

- 功能变更时同步改本文件「规格 + 验收」  
- 行为冲突时 **以本文件决策表为准**，并回写代码  
- 不在本文件堆 UI 截图；视觉以 `lib/core/theme` 与真机为准  

---

## 15. 新会话交接（读这里开工）

### 15.1 一句话

**`v0.0.5` 已完成并进入真机验收：D-task 杀进程恢复 + schema 6 媒体字段 + 音视频播放器 + 全局 mini + 媒体专属 LLM 对话窗。**

### 15.2 现状速查

| 模块 | 路径 / 要点 |
|------|-------------|
| 仓库 | https://github.com/WEP-56/wepseed · MIT · tag **`v0.0.5`** |
| Flag | `kUseMockFeed=false`；`kUseMockComments=false` |
| 版本 | `pubspec` `0.0.5+5` |
| Drift | **schemaVersion = 6**；评论任务表 + articles 媒体字段 |
| 评论清洗 | `lib/data/llm/llm_text_sanitize.dart` · complete 后 + 入库前 |
| 评论任务 | `lib/data/comments/comment_generation_engine.dart` · `comment_job_repository*` · `comment_job_worker.dart` |
| ME 列表 | `/me/bookmarks` · `/me/chats` · `/me/traces` · `me_list_page.dart` |
| RSS 后台 | `scheduleFromDatabase` · `runRssRefreshJob` · `DartPluginRegistrant` |
| 评论 WM | one-off `wepseed.drain-comment-jobs`（≠ RSS） |
| 媒体 | `features/media/` · `mediaSessionProvider` · just_audio/audio_service · video_player |
| 媒体 AI | 仅音视频详情「一起聊」；默认模型；内存会话；不写网友评论任务 |
| 通知 | channel `rss_updates`；深链 **`push` only** |
| 债表 | **§1.5** |

### 15.3 下一会话建议顺序

1. **0.0.5 真机**：D-task 生成中强制停止；音频后台/通知/倍速；视频全屏；mini；媒体 AI 对话  
2. 根据真机反馈修复播放器格式兼容、系统栏与 OEM 后台行为  
3. 后续：媒体 M3（进度持久化/PiP/下载）或 WebView（§15.6）

### 15.4 不要做的事

- 恢复 New 左侧时间轨（除非产品改口）  
- 通知深链改回 `router.go`  
- 无必要重写 masonry / 玻璃  
- 应用内 WebView（未明确开工前）  
- 大改 RSS 解析（除非源坏了）  
- 重做整套 LLM 协议  
- 提交 `*.jks` / `key.properties` / `SIGNING.private.md`  
- 把 Gradle 再改回「Aliyun 优先」  
- 去掉评论 sanitize（会再出 think/tool 脏文）

### 15.5 启动命令

```bash
cd D:\wepseed
flutter pub get
flutter analyze
flutter test
flutter run -d <device>
# Release：https://github.com/WEP-56/wepseed/releases/tag/v0.0.5
# 首选 wepseed-0.0.5-arm64-v8a.apk
```

### 15.6 Backlog：应用内 WebView 阅读器（Phase F 余）

**产品诉求（已确认）：** 外链优先应用内 WebView，可存 cookies、管理下载；成本高，**现阶段一律系统浏览器**。

| 项 | 说明 |
|----|------|
| 包选型 | `webview_flutter` 或 `flutter_inappwebview` |
| 替换点 | `openExternalUrl` / `openArticleUrl(mode: inApp \| system)` |
| 风险 | 桌面 UA；隐私文案已部分在 `PRIVACY.md` |

未实现前：**`LaunchMode.externalApplication` only**。

### 15.6.1 已实现：音视频媒体类型与播放器（P1）

**专规文档：[`docs/MEDIA_PLAYER.md`](MEDIA_PLAYER.md)**（类型推断 · schema · mini player · M0–M2 已完成）。

| 项 | 说明 |
|----|------|
| 范围 | 文章级 `blog`/`audio`/`video`；全局 mini；音频后台通知 |
| 非目标首版 | 完整播客壳、下载缓存、源级分栏、无直链站点假播放 |
| 与 LLM | mediaType ≠ blog → 不创建网友评论任务；改用独立「一起聊」悬浮窗 |
| 余项 | M3：进度持久化、视频 PiP、下载缓存、源级筛选 |

### 15.7 已知产品决策（勿回退）

| 决策 | 说明 |
|------|------|
| 进源页 | `markSourceSeen`：badge 清零 + 该源文章标已读 |
| 删除源 | 硬删 feed + articles |
| 外链 | 系统浏览器（WebView 后置） |
| Scrubber | **仅详情目录**；New **不挂时间轨** |
| 评论 | 有 Key 真 LLM；无 Key 不灌 mock；**sanitize 去 think/tool**；可 clearAll |
| 人设 | 只写语气；场景 `kWepseedCommentScene` |
| 深色正文 | 强制高对比；strip 内联灰色 |
| 根返回 | 先回 New，New 上双击退出 |
| 通知深链 | **`push` 保留栈**；禁止 `go` 进帖 |
| New 筛选 | 今日∩未看∩源可叠；**仅选源时限刷** |
| ME 三块 | 可点进列表；收藏=书签；对话/痕迹=warm 事件可删 |
| 更新 | GitHub Releases 分包 APK；优先 arm64-v8a |
| 协议隐私 | 外链 `docs/TERMS.md` / `PRIVACY.md` |
| 开源 | MIT |

### 15.8 版本变更摘要

| 版本 | 内容 |
|------|------|
| **0.0.1** | 首 tag Release；MIT |
| **0.0.2** | 双击退出；Toast；关于更新；LLM 重试·测连；Maven 官方优先 |
| **0.0.3** | 通知 `push`；New 筛选 schema 4；**真机通过** |
| **0.0.4** | 评论 sanitize；ME 列表 CRUD；RSS WM 加固；**真机综合测通过** |
| **0.0.5** | D-task；schema 6 媒体识别；音频/视频/全局 mini；音频系统媒体会话；媒体 AI 对话窗；待真机反馈 |
| **未收口** | 0.0.5 真机；媒体 M3；流式/WebView；E-ROM 可选 |

### 15.9 会话记录

**0.0.3：** 通知返回栈 + 筛选；真机通过。

**0.0.4 发版 + 测：**  
- 评论：`sanitizeLlmCommentText` + prompt；去思考/tool  
- ME：收藏/对话/痕迹列表 CRUD  
- RSS：冷启动重排程、isolate 插件、channel、无 battery-not-low  
- tag `v0.0.4` · `d7b407c` · **用户真机综合测无问题**

**D-task（本会话 · 未抬版本号）：**  
- Drift v5：`comment_jobs` / `comment_job_items`  
- `CommentGenerationEngine` + job repo；部分完成可补全  
- WM one-off `wepseed.drain-comment-jobs`；冷启动 recover  
- 单测：job/lease/partial/legacy short-circuit  

**0.0.5 媒体实现：**  
- RSS/Atom enclosure 与 media:content 推断；Drift schema 6  
- just_audio + audio_service 后台通知；video_player + 全屏；全局 mini  
- 音视频隐藏网友评论，提供临时 LLM「一起聊」悬浮窗  
- 自动化：媒体解析、类型 roundtrip、评论任务隔离；真机待验收

---

*WEPSEED — local-first RSS with warmth.*
