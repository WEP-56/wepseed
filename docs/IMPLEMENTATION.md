# WEPSEED 功能实现文档

> 版本：Phase E 1.6.0（Warm 持久化 · 温度规则 · 后台刷新通知）  
> 平台：Flutter · Android 首发 · 本地优先（local-only）  
> 状态：**A–E 主路径已接**；D 仅余真实端点验收/流式，E 仅余厂商 ROM 长期实机验收与评论任务杀进程恢复  
> 开关：`kUseMockFeed` / `kUseMockComments`（`lib/core/config/app_flags.dart`）

本文档只写**要做什么、做成什么样、怎么落地**。  
**新会话请从 §1 现状 + §1.5 已知问题 + §8 + §15 交接 起读。**

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
| 刷 | New masonry 流 + 源主页 | **真 Stream + 下拉刷新**（时间轨已移除，筛选后置） |
| 读 | 详情正文、已读、收藏 | **HTML 正文 + 图缓存 + 目录 scrubber**；外链系统浏览器 |
| 评 | TikTok 式评论区 + 多网友 | **配置真 + 内容真 LLM**（无 Key **不灌 mock**；见 §1.5 乱码/模型保存） |
| 回看 | ME 时间轴 | **Drift 持久化**；dwell/binge/streak/nightOwl 规则已接 |
| 设 | 形象、主题、字号、多提供商/网友、DATA、关于 | **大部分真持久化** |
| 推 | WorkManager + 本地通知 | **已接 Android 周期刷新 + 新文章通知 + 文章深链** |

---

## 1. 当前代码现状（2026-07-15 对照）

### 1.1 目录

```
lib/
  main.dart / app.dart / app_shell.dart
  router/app_router.dart          # / · /article/:id · /source/:id
  core/config/app_flags.dart      # kUseMockFeed / kUseMockComments
  core/theme/…  core/utils/open_url.dart · time_labels.dart · monogram.dart
  data/
    models/models.dart            # FeedSource(+isPaused), Article(+contentHtml),
                                  # Netizen, Comment, Llm*, AppSettings…
    mock/mock_data.dart           # 仅 kUseMockFeed=true 时用
    db/tables.dart + app_database.dart   # Drift schemaVersion = 3
    rss/                          # client · parser · opml · models
    llm/                          # HttpLlmClient · prompt · resolve
    repositories/
      feed_repository.dart + mock + drift_feed_repository.dart
      article_repository.dart + mock + drift_article_repository.dart
      settings / llm / netizen / comment / warm（warm 真 Drift）
  providers/
    core_providers.dart           # kUseMockFeed + llmClientProvider
    settings / feed / article / llm / netizen / comment / me / shell
  features/
    new/
      new_page.dart               # 真流 masonry（无时间轨）
      feed_card · source_feed_page
      article_detail_page.dart    # HTML 正文 · 目录 scrubber · dwell · 外链
      article_body.dart · article_toc.dart · comment_sheet.dart
    me/   me_page
    set/  set_page（RSS 真管理）· llm_settings_section
  widgets/
    edge_scrubber.dart            # 详情目录 scrubber（New 不用）
    app_network_image.dart · glass_bottom_nav · liquid_glass · pressable
test/
  fixtures/ sample_rss · sample_atom · sample.opml
  rss_parser · toc_extract · time_labels · llm_client
```

### 1.2 已可交互（真 / 半真）

| 模块 | 状态 |
|------|------|
| 壳 / 路由 | go_router；三 Tab + 玻璃底栏 |
| 主题 / 字号 / 形象 | Drift 持久化；深色次级字已提亮 |
| 多提供商 × 多模型 | Drift + per-provider Key（secure） |
| 多网友 CRUD | Drift（权重 / 人设 / 模型绑定） |
| 评论触发 | off / onBrowse / onOpenComments |
| 评论区 UI | TikTok 式；**真 LLM**（`HttpLlmClient`）；无 Key 留空；Set 可「清除全部评论」；**乱码代码已修，真实端点重生成待验收 → §1.5** |
| New | **真 Stream**；下拉刷新；空态；**无时间轨**（产品决策移除，筛选后置） |
| 源主页 | 真文章；下拉刷新；more：刷新/暂停/复制/退订 |
| 详情 | HTML/`contentText`；图缓存；打开原文/分享/复制/MD；**目录 scrubber**；dwell |
| 已读 / 收藏 / 未读 | Drift `articles` 列 + Stream（杀进程仍在） |
| ME | UI 齐；warm **Drift 持久化**（含 dwell/binge/streak/nightOwl） |
| Set · RSS | 添加 URL / 列表 / 暂停删除 / OPML 粘贴导入 / 剪贴板导出 |

### 1.3 明确未做 / 下一会话可选主路径

**主线 A — 收口 Phase D 体验（建议优先，若真机评论仍烂）：** 见 §1.5  

**Phase E 已接：**  
- warm 规则 + Drift 持久化  
- WorkManager / 本地通知 / `/article/:id`  

**下一主线：**  
- 评论任务持久化 + WorkManager 恢复（杀进程可靠）  
- Android 厂商 ROM 后台长期验收与设置说明  
- 应用内 WebView（Phase F / §15.6）  
- New 筛选 UI；评论流式气泡  

### 1.4 关键接线（勿重造）

| 点 | 现状 | 注意 |
|----|------|------|
| Feed/Article DI | `kUseMockFeed ? Mock* : Drift*` | 默认 **false** |
| 删除源 | 硬删 feed + articles | 见 `DriftFeedRepository` 注释 |
| Guid | guid → link → sha1(title\|published) | 刷新 upsert 不重复 |
| 外链 | `openExternalUrl` → 系统浏览器 | WebView 见 §15.6 |
| Scrubber | `EdgeScrubber` | **仅详情** h1–h3 目录；New **不挂**时间轨 |
| LLM | `lib/data/llm/*` + `llmClientProvider` | 场景帧在 `llm_prompt.dart` |
| 评论清空 | `CommentRepository.clearAll` / Set「清除全部评论」 | 清旧 mock 用 |

### 1.5 已知问题 / 技术债（2026-07-15 真机反馈 · **本会话不修，只登记**）

> 用户明确：问题还多但先歇，**只更文档**。下会话按优先级捞。

| # | 现象 | 可能原因 | 建议方向（未实施） |
|---|------|----------|-------------------|
| D1 | **评论气泡正文乱码 / 方块 / 西里尔夹杂**（真机截图：顶层评与「冷淡叔」回复均不可读，夹 `DeepSeek`/`Codex`/`Bonsai` 等碎片） | 已定位：`response.body` 会受网关缺失/错误 charset 影响，在 JSON 解析前把 UTF-8 中文误解码 | **代码已修（2026-07-16）**：请求声明 UTF-8；响应统一从 `bodyBytes` 严格 `utf8.decode`；替换符/控制字符拒绝返回，避免脏串入库；回归测试已覆盖。仍需清旧评论后用真实端点重生成验收 |
| D2 | Set 添加模型曾出现保存失败 | Dialog + 写后校验修复 | **已修并验收，不再跟踪** |
| D3 | 无 Key 时旧逻辑会灌 **mock 评论** 占坑，清不掉就不重生成 | `ensureGenerated` 见 existing 即 return | **已改**：默认不灌 mock；Set「清除全部评论」；`kUseMockComments` 仅测试 |
| D4 | 预设人设未说明「在 RSS 评论区当网友」 | systemHint 过短 | **已改**：`kWepseedCommentScene` 注入；seed 人设只写语气。**已装设备 seed 不覆盖**，需手改人设或清库 |
| D5 | New 左侧时间轨侵入/卡顿/overflow | 按日刻度过多 | **已产品决策移除**；筛选后置；详情 TOC scrubber 保留 |
| D6 | 评论生成过程曾是黑盒；失败文案混在气泡里 | 缺少任务状态 | **首轮已修**：显示排队/正在评论/正在回复；成功逐条入库；失败不再伪装成评论；空结果可重试；流式气泡后置 |
| D7 | 网友显式绑定失效时曾回退到其他提供商 | `resolveLlmConfigForNetizen` 回退策略 | **已修**：显式绑定无效直接跳过，禁止静默消耗其他提供商额度；未绑定网友仍用首个可用提供商 |

**与截图相关的验收口径（D1）：**  
- 打开评论后，中文网友气泡应可读；出现 `` 成片或西里尔乱码 = **未验收通过**  
- 清除该文评论或「清除全部评论」后重开，应重新请求而非永久脏数据  

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
```

Set 内 sheet 仍用 `showModalBottomSheet`（提供商/网友编辑）。深链通知进文章：已有 `/article/:id`。

---

## 3. 领域模型（对照 Drift + models.dart）

### 3.1 表 / 实体（schemaVersion = 3）

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

user_profiles    id=default, displayName, …
app_settings    themeMode, fontScale, refreshMinutes, wifiOnly,
                notificationsEnabled, useMockFeed, commentTrigger,
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

- 顶：标题 New + 筛选（后置）
- 订阅条：横向源列表
- 可选精选大卡（最新/运营规则/用户未读优先）
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

**当前实现（Android）**

- 设置变化时以 `ExistingPeriodicWorkPolicy.update` 更新唯一周期任务；最短 15 分钟
- `wifiOnly=true` → `NetworkType.unmetered`；否则 `connected`；同时要求电量非低
- 后台 isolate 独立打开 Drift，刷新全部未暂停源；以刷新前后的 article id 差集识别真正新增文章
- 单轮最多通知最新 3 篇，避免通知轰炸；通知 payload 为 `/article/:id`
- Android 13+ 在通知开启时请求 `POST_NOTIFICATIONS`

**通知文案**

- 避免「你有 3 条更新」  
- 优先：`{源名} · {文章标题}`  
- 点击 deep link → `/article/:id`  

**权限**

- Android 13+ 通知权限请求（设置页也可二次打开）  

**验收**

- [x] 开关关闭后不弹  
- [x] 仅 Wi‑Fi 映射为 unmetered 后台约束  
- [x] 点击通知进对应文章  
- [ ] 国产 ROM 杀后台/省电模式长期实机验收  

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

### 7.4 评论任务生命周期（1.5.0）

```text
preparing → queued → running → completed / failed
                  ↘ provider lane（maxConcurrent + RPM）
```

- `CommentController`：文章级任务去重；页面关闭后任务在应用进程内继续。
- `ScheduledLlmClient`：提供商级 FIFO 队列；所有文章、顶层评论和回复共享额度，默认并发 1。
- `CommentActivityNotifier`：广播排队、执行、回复和完成事件；评论 sheet 与全局提示消费同一状态。
- `CommentRepository`：成功一条写一条；网络错误不写入评论表；用户回复先本地落库，再等待网友回复。
- **当前边界**：进程存活时可跨页面继续；Android 杀进程后不能恢复。完整后台可靠性需新增持久化 `comment_jobs/comment_job_items`、租约/重试次数/下次执行时间，并由 WorkManager 恢复；不能把普通 Future 视为可靠后台任务。

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
- [x] **D1 评论乱码 / 编码代码修复**（严格 UTF-8 字节解码 + 脏文本拦截；真实端点重生成待验收）  
- [x] D2 模型保存真机验收通过  
- [x] D6 生成状态 / 完成提醒 / 空结果重试 / 失败不写伪气泡  
- [x] 提供商共享并发 + RPM 队列；默认依次请求、逐条显示  
- [x] 用户回复与 LLM 回复多层线程展示  
- [ ]（可选）流式输出到评论气泡  
- [ ] 持久化评论任务 + WorkManager 恢复（杀进程可靠后台）  

### Phase E — ME 温度与通知 ✅ 主路径

- [x] warm 规则 binge/streak/nightOwl + 同日去重  
- [x] ME / warm / dwell **Drift 持久化**（替换 mock 内存）  
- [x] WorkManager + 本地通知 + `/article/:id` 深链  
- [x] 通知权限、Wi‑Fi/unmetered 约束、周期设置热更新  
- [ ] 厂商 ROM 后台长期实机验收  

> 下一会话：优先评论任务持久化/杀进程恢复，或继续 Phase F 打磨。

### Phase F — 打磨

- [ ] 性能 / 错误空态 / 关于更新 / 测试补强  
- [ ] **应用内 WebView 阅读器**（见 §15.6）  
- [ ] New 筛选 UI

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

### 更后

- [x] 后台刷新 + 通知进文章（E）  
- [x] ME warm 持久化 + 温度规则（E）  
- [ ] 应用内 WebView（F） 

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

**A–E 主路径已接。D 已有真 HTTP、严格 UTF-8、队列/RPM、任务状态与多层回复；E 已有 Warm Drift、温度规则、后台 RSS、本地通知和深链。下一步优先评论任务杀进程恢复或 Phase F。**

### 15.2 现状速查

| 模块 | 路径 / 要点 |
|------|-------------|
| Flag | `kUseMockFeed=false`；`kUseMockComments=false` |
| RSS | `lib/data/rss/*` · `drift_feed/article_repository.dart` |
| DI | `lib/providers/core_providers.dart`（`llmClientProvider`） |
| 正文 | `article_body.dart`：HTML + sanitize |
| 目录 | `article_toc.dart` + 详情 `EdgeScrubber` |
| New | `new_page.dart`：**无时间轨**；筛选后置 |
| LLM HTTP | `lib/data/llm/http_llm_client.dart` |
| LLM 队列 | `lib/data/llm/scheduled_llm_client.dart`：provider 共享并发/RPM |
| LLM 场景/人设 | `llm_prompt.dart`（`kWepseedCommentScene`）· seed 在 `app_database._seedDefaults` |
| 解析绑定 | `llm_resolve.dart` |
| 模型 UI | `llm_settings_section.dart`：模型用 **Dialog**；提供商 sheet 内列表 |
| 评论 | `comment_repository_impl.dart`：逐条入库；`comment_providers.dart`：生命周期/通知/去重 |
| 外链 | `open_url.dart` 系统浏览器 |
| Warm | `drift_warm_event_repository.dart`：持久化 + dwell/binge/streak/nightOwl |
| 后台 | `core/background/background_refresh_service.dart` + `notification_service.dart` |
| 测试 | `rss_parser` · `toc_extract` · `time_labels` · `llm_client` |
| 债表 | **§1.5** |

### 15.3 下一会话建议顺序

**若先收口 D（推荐）：**  
1. 验收 D1：Set 清除全部旧评论 → 同一 DeepSeek/代理重新生成 → 确认中文可读且无方块/西里尔乱码  
2. 验收队列：提供商并发 1、低 RPM；多网友应依次出现，额度耗尽后等待  
3. 验收回复：回复任一网友评论 → 显示“正在回复你” → LLM 回复出现在该线程下  
4. 决定是否进入持久化评论任务 + WorkManager（杀进程恢复）  

**E 验收：**  
1. 杀进程重开，ME/Warm 仍在  
2. 通知开关关闭不弹；仅 Wi‑Fi 使用 unmetered 约束  
3. 点击新文章通知进入 `/article/:id`  
4. 国产 ROM 关闭省电限制后观察周期任务  

### 15.4 不要做的事

- 恢复 New 左侧时间轨（除非产品改口）  
- 无必要重写 masonry / 玻璃  
- 应用内 WebView（F）  
- 大改 RSS 解析（除非源坏了）  
- 重做整套 LLM 协议（只修 bug / charset）

### 15.5 启动命令

```bash
cd D:\wepseed
flutter pub get
flutter analyze
flutter test test/rss_parser_test.dart test/toc_extract_test.dart test/llm_client_test.dart
flutter run -d <device>
```

### 15.6 Backlog：应用内 WebView 阅读器（Phase F）

**产品诉求（已确认）：** 外链优先应用内 WebView，可存 cookies、管理下载；成本高，**现阶段一律系统浏览器**。

| 项 | 说明 |
|----|------|
| 包选型 | `webview_flutter`（Android/iOS）+ 桌面兜底外开；或 `flutter_inappwebview`（cookies/下载更全） |
| Cookies | 持久化 CookieManager |
| 下载 | Android 下载监听 → 通知 / 文件列表；iOS 受限更多 |
| UI | 顶栏：返回 / 刷新 / 外开系统浏览器 / 分享；进度条 |
| 入口 | 详情顶栏、正文 `<a>`、底部「打开原文」→ 应用内；保留「用系统浏览器」 |
| 替换点 | 只改 `openExternalUrl` 或 `openArticleUrl(mode: inApp \| system)` |
| 风险 | Windows 跨盘插件；桌面 UA；隐私文案 |

未实现前：**`LaunchMode.externalApplication` only**。

### 15.7 已知产品决策（勿回退）

| 决策 | 说明 |
|------|------|
| 进源页 | `markSourceSeen`：badge 清零 + 该源文章标已读 |
| 删除源 | 硬删 feed + articles |
| 外链 | 系统浏览器（WebView 后置） |
| Scrubber | **仅详情目录**；右滑取消；≥2 锚点；**New 不挂时间轨**（侵入/卡顿，已砍） |
| 评论 | 有 Key 真 LLM；**无 Key 不灌 mock**；`kUseMockComments` 仅测试；可 clearAll |
| 人设 | 用户/seed 只写语气；**场景由 `kWepseedCommentScene` 注入** |
| 深色正文 | 强制高对比；strip feed 内联灰色 |

### 15.8 本会话变更摘要（便于 diff 记忆）

- New：去掉月/日时间轨与 `EdgeScrubber`  
- D：`HttpLlmClient` + `ensureGenerated` 真请求；prompt 场景帧；clearAll；模型 Dialog 保存路径加固  
- D 1.5：提供商并发/RPM 队列；评论/回复状态；应用级完成提醒；递归回复树；D2 已验收  
- E 1.6：Warm Drift；binge/streak/nightOwl；WorkManager RSS；本地通知与文章深链  
- **未收口**：评论编码真实端点验收；评论任务杀进程恢复；厂商 ROM 后台长期验收；可选流式气泡  

---

*WEPSEED — local-first RSS with warmth.*
