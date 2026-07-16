# WEPSEED 功能实现文档

> 版本：**0.0.3**（tag `v0.0.3` · 开源 MIT · GitHub [WEP-56/wepseed](https://github.com/WEP-56/wepseed)）  
> 平台：Flutter · Android 首发 · 本地优先（local-only）  
> 状态：**A–E + F 打磨 + 0.0.3**（通知返回栈 / New 筛选持久化限刷）；用户 **真机验 0.0.3**  
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
| 刷 | New masonry 流 + 源主页 | **真 Stream + 下拉刷新**（时间轨已移除；**筛选已接**） |
| 读 | 详情正文、已读、收藏 | **HTML 正文 + 图缓存 + 目录 scrubber**；外链系统浏览器 |
| 评 | TikTok 式评论区 + 多网友 | **配置真 + 内容真 LLM**（无 Key **不灌 mock**；见 §1.5 乱码/模型保存） |
| 回看 | ME 时间轴 | **Drift 持久化**；dwell/binge/streak/nightOwl 规则已接 |
| 设 | 形象、主题、字号、多提供商/网友、DATA、关于 | **大部分真持久化**；关于 = 真版本 + GitHub 更新/协议 |
| 推 | WorkManager + 本地通知 | **已接 Android 周期刷新 + 新文章通知 + 文章深链** |
| 发 | tag 驱动 Release | **已接** per-ABI APK + GitHub Actions（`v*`） |

---

## 1. 当前代码现状（2026-07-16 对照 · **0.0.3**）

### 1.1 目录

```
lib/
  main.dart / app.dart / app_shell.dart   # AppShell: PopScope 双击退出
  router/app_router.dart          # / · /article/:id · /source/:id
  core/config/app_flags.dart · app_links.dart   # GitHub / 协议 / API 常量
  core/ui/app_toast.dart          # 抬高底栏的统一 Toast
  core/theme/…  core/utils/open_url.dart · time_labels.dart · monogram.dart
  core/background/                # WorkManager + 本地通知
  data/
    models/models.dart
    mock/mock_data.dart           # 仅 kUseMockFeed=true
    db/tables.dart + app_database.dart   # Drift schemaVersion = 4
    rss/ · llm/                   # HttpLlmClient 含重试
    update/github_update_service.dart    # Releases 检查 + 下载
    repositories/ … warm Drift …
  providers/ …
  features/
    new/ …  me/ …
    set/  set_page（RSS + 检查更新下载安装）· llm_settings_section（测试连接）
  widgets/ glass_bottom_nav · edge_scrubber · …
docs/
  IMPLEMENTATION.md · TERMS.md · PRIVACY.md
  SIGNING.private.md              # gitignore：签名/Secrets 私密手册
.github/workflows/
  ci.yml · release.yml            # tag v* → 分包 APK Release
android/                          # 官方 Maven 优先；Aliyun 备用
test/
  fixtures/ · rss_parser · toc · time_labels · llm_client · semver · warm · widget
```

### 1.2 已可交互（真 / 半真）

| 模块 | 状态 |
|------|------|
| 壳 / 路由 | go_router；三 Tab + 玻璃底栏；**根页返回**：非 New→回 New，New 上 **2s 内再按退出** |
| 主题 / 字号 / 形象 | Drift 持久化；深色次级字已提亮 |
| 多提供商 × 多模型 | Drift + per-provider Key；编辑页 **「测试连接」** |
| 多网友 CRUD | Drift（权重 / 人设 / 模型绑定） |
| 评论触发 | off / onBrowse / onOpenComments |
| 评论区 UI | 真 LLM；无 Key 留空；clearAll；**HTTP 超时/429/5xx 重试**；D1 编码已修，**真机待确认** |
| New / 源 / 详情 | 真流；HTML；目录 scrubber；dwell |
| ME | warm Drift + 温度规则 |
| Set · RSS | 添加 / 列表 / OPML |
| Set · 关于 | **PackageInfo 真版本**；检查更新 → GitHub Releases → **应用内下载安装**；协议/隐私外链；关于 → 仓库 |
| Toast | `showAppToast`：浮动、短时、**抬高避开底栏** |
| 发布 | MIT；`v0.0.1`–`v0.0.3` 分包 APK；CI 签名靠 Secrets |

### 1.3 明确未做 / 下一会话可选主路径

**用户真机测 0.0.3** —— 重点：通知返回栈、New 筛选、D1 评论中文。

| 优先级 | 项 |
|--------|-----|
| 高 | 真机回归：返回 / Toast / 更新安装 / LLM 测连与评论可读（D1） |
| 中 | 评论任务持久化 + WorkManager 恢复（杀进程可靠） |
| 中 | 厂商 ROM 后台长期验收与 Set 说明文案 |
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
| LLM | `http_llm_client` + `scheduled_llm_client` | 重试在 `_postJson`；测连**绕过** scheduler |
| Toast | `lib/core/ui/app_toast.dart` + `appMessengerKey` | 勿再裸 `SnackBar` 贴底 |
| 返回 | `AppShell` `PopScope` | 仅根 `/`；子路由正常 pop |
| 通知深链 | `app.dart` `_openDeepLink` → **`router.push`** | **勿用 `go`**：会清栈，返回直接回桌面 |
| New 筛选 | `FeedFilter` + `filteredArticlesProvider` | Drift `feedFilterJson`；今日∩未看∩源；**选源才限刷** |
| 更新 | `GithubUpdateService` + Set `_UpdateSheet` | 资产名 `wepseed-*-{abi}.apk` |
| 链接常量 | `lib/core/config/app_links.dart` | TERMS/PRIVACY/API |
| 签名 | `docs/SIGNING.private.md`（本地 only） | 勿提交 jks / key.properties |
| 评论清空 | `CommentRepository.clearAll` | 清旧 mock / 脏串后重生成 |

### 1.5 已知问题 / 技术债（登记 · 0.0.3 真机测中）

> 下会话：**先听真机反馈**，再决定修债还是做任务持久化。

| # | 现象 | 状态 |
|---|------|------|
| D1 | 评论乱码 / 方块 / 西里尔 | **代码已修**（UTF-8 `bodyBytes` + 脏文本拒绝）；清评论后真端点重生成 — **0.0.2 待用户确认** |
| D2 | 模型保存失败 | **已修已验收，关闭** |
| D3–D7 | mock 占坑 / 场景帧 / 时间轨 / 状态 / 绑定回退 | **已改**（见历史行；D5 产品砍轨） |
| F-back | 一点返回就退出 | **0.0.2 已修**（双击退出） |
| F-notif-back | 通知/小 Toast「查看」进帖子后返回直接回桌面，再进仍停在帖子 | **0.0.3 已修**（`go`→`push` + 详情/源页 `canPop` 兜底 `go('/')`）；待真机确认 |
| F-filter | New 筛选占位 | **0.0.3 已接**（今日/未看/多源 + 持久化 + 选源限刷） |
| F-toast | SnackBar 挡底栏 | **0.0.2 已修**（`showAppToast`） |
| F-about | 关于 1.0.0 占位 | **0.0.2 已修**（真版本 + 更新/协议/GitHub） |
| F-llm | 无重试 / 无测连 | **0.0.2 已修** |
| E-ROM | 厂商杀后台 | **未做**长期验收 |
| D-task | 评论生成杀进程丢任务 | **未做** WorkManager 恢复 |

**D1 验收口径：** 清全部评论 → 真 Key 重开 → 中文可读、无成片 ``/西里尔 = 通过。  

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

### 3.1 表 / 实体（schemaVersion = 4）

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

**当前实现（Android）**

- 设置变化时以 `ExistingPeriodicWorkPolicy.update` 更新唯一周期任务；最短 15 分钟
- `wifiOnly=true` → `NetworkType.unmetered`；否则 `connected`；同时要求电量非低
- 后台 isolate 独立打开 Drift，刷新全部未暂停源；以刷新前后的 article id 差集识别真正新增文章
- 单轮最多通知最新 3 篇，避免通知轰炸；通知 payload 为 `/article/:id`
- Android 13+ 在通知开启时请求 `POST_NOTIFICATIONS`
- **导航**：`notificationRouteProvider` / 评论 Toast「查看」一律 **`router.push`**（`app.dart` `_openDeepLink`），保留下层栈；同 path 不重复 push
- 详情/源页返回：`canPop` 则 pop，否则 `go('/')`（冷启异常清栈兜底，避免出应用）

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
- [ ] **通知进帖 → 系统返回 / 顶栏返回 → 回到进通知前界面**（热启动）；冷启至少回壳 `/`  
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
- [x] HTTP 有限重试（超时 / 网络 / 429 / 5xx；401 不重试）  
- [x] 提供商编辑 **测试连接**（独立 HttpLlmClient，不占评论队列）  
- [ ]（可选）流式输出到评论气泡  
- [ ] 持久化评论任务 + WorkManager 恢复（杀进程可靠后台）  

### Phase E — ME 温度与通知 ✅ 主路径

- [x] warm 规则 binge/streak/nightOwl + 同日去重  
- [x] ME / warm / dwell **Drift 持久化**（替换 mock 内存）  
- [x] WorkManager + 本地通知 + `/article/:id` 深链  
- [x] 通知权限、Wi‑Fi/unmetered 约束、周期设置热更新  
- [ ] 厂商 ROM 后台长期实机验收  

### Phase F — 打磨 ⚠ 部分已接（0.0.3）

- [x] 根页返回拦截（双击退出）  
- [x] 关于：真版本 / 检查更新（GitHub）/ 应用内下载安装 / 协议隐私外链 / 仓库入口  
- [x] 统一低侵入 Toast  
- [x] 开源 MIT + tag Release CI（per-ABI）+ 官方 Maven 优先  
- [x] 测试：LLM 重试 · semver/ABI 选取（`test/semver_test.dart`）  
- [ ] 性能 / 错误空态补强  
- [ ] **应用内 WebView 阅读器**（见 §15.6）  
- [x] New 筛选 UI（今日/未看/多源 + 持久化 + 选源限刷） 

> 下一会话：先汇总 **0.0.3 真机反馈**；再评论任务杀进程恢复 / ROM 说明 / 剩余 F。

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

### 更后 / 0.0.3

- [x] 后台刷新 + 通知进文章（E）  
- [x] ME warm 持久化 + 温度规则（E）  
- [x] 返回 / Toast / 关于更新安装 / LLM 重试·测连 / Release（F 一批）  
- [x] 通知深链返回栈 + New 筛选（0.0.3）  
- [ ] 应用内 WebView（F 余）  
- [ ] 评论任务杀进程恢复  

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

**A–E 齐 + 0.0.3 已发（0.0.2 打磨 + 通知返回栈 + New 筛选持久化限刷）。用户真机测 0.0.3；下一会话先收反馈，再做评论任务杀进程恢复或 F 余项。**

### 15.2 现状速查

| 模块 | 路径 / 要点 |
|------|-------------|
| 仓库 | https://github.com/WEP-56/wepseed · MIT · tag `v0.0.3` |
| Flag | `kUseMockFeed=false`；`kUseMockComments=false` |
| 版本 | `pubspec` `0.0.3+3`；Release CI 用 tag 覆盖 build-name/number |
| RSS / DI | `lib/data/rss/*` · `core_providers.dart` |
| 正文 / 目录 | `article_body` · 详情 `EdgeScrubber` only |
| New | **无时间轨**；`feedFilter` + tune sheet |
| LLM HTTP | `http_llm_client.dart`：**3 次尝试**，超时/网络/429/5xx 重试 |
| LLM 队列 | `scheduled_llm_client.dart` |
| 测连 | `llm_settings_section`「测试连接」→ 裸 `HttpLlmClient` |
| 评论 | `comment_repository_impl` + `comment_providers`（activity Toast） |
| Toast | `core/ui/app_toast.dart` · `appMessengerKey` |
| 返回 | `app_shell.dart` `PopScope`；详情 `_leaveDetail` |
| 通知深链 | `notification_service` + `app.dart` `_openDeepLink`（**push**） |
| New 筛选 | `models.FeedFilter` · `core/utils/feed_filter.dart` · `filteredArticlesProvider` · `new_page` sheet |
| 更新 | `data/update/github_update_service.dart` · Set `_UpdateSheet` |
| 链接 | `core/config/app_links.dart` · `docs/TERMS.md` · `docs/PRIVACY.md` |
| Warm / 后台 | Drift warm · `background_refresh_service` · `notification_service` |
| 签名私密 | `docs/SIGNING.private.md`（gitignore）· Secrets：`KEYSTORE_*` |
| CI | `.github/workflows/release.yml` · **Maven：google/central 优先**，Aliyun 备用 |
| 测试 | `llm_client`（含重试）· `semver_test` · rss/toc/warm/widget |
| 债表 | **§1.5** |

### 15.3 下一会话建议顺序

1. **读用户 0.0.3 真机反馈**（通知返回、New 筛选、Toast、更新安装、测连、评论中文）  
2. 未通过项：按 §1.5 定点修，优先 D1 若仍乱码  
3. 通过后可选主线：  
   - 评论任务持久化 + WorkManager 恢复  
   - Set 厂商后台说明 + ROM 验收  
   - 流式气泡 / WebView（F）  
4. 发版：`git tag vX.Y.Z && git push origin vX.Y.Z`（勿依赖 Aliyun 优先）

### 15.4 不要做的事

- 恢复 New 左侧时间轨（除非产品改口）  
- 无必要重写 masonry / 玻璃  
- 应用内 WebView（未明确开工前）  
- 大改 RSS 解析（除非源坏了）  
- 重做整套 LLM 协议  
- 提交 `*.jks` / `key.properties` / `SIGNING.private.md`  
- 把 Gradle 再改回「Aliyun 优先」（会打挂 GitHub Actions）

### 15.5 启动命令

```bash
cd D:\wepseed
flutter pub get
flutter analyze
flutter test
flutter run -d <device>
# 或装 Release：https://github.com/WEP-56/wepseed/releases/tag/v0.0.3
# 首选 wepseed-0.0.3-arm64-v8a.apk
```

### 15.6 Backlog：应用内 WebView 阅读器（Phase F 余）

**产品诉求（已确认）：** 外链优先应用内 WebView，可存 cookies、管理下载；成本高，**现阶段一律系统浏览器**。

| 项 | 说明 |
|----|------|
| 包选型 | `webview_flutter` 或 `flutter_inappwebview` |
| 替换点 | `openExternalUrl` / `openArticleUrl(mode: inApp \| system)` |
| 风险 | 桌面 UA；隐私文案已部分在 `PRIVACY.md` |

未实现前：**`LaunchMode.externalApplication` only**。

### 15.7 已知产品决策（勿回退）

| 决策 | 说明 |
|------|------|
| 进源页 | `markSourceSeen`：badge 清零 + 该源文章标已读 |
| 删除源 | 硬删 feed + articles |
| 外链 | 系统浏览器（WebView 后置） |
| Scrubber | **仅详情目录**；New **不挂时间轨** |
| 评论 | 有 Key 真 LLM；**无 Key 不灌 mock**；可 clearAll |
| 人设 | 只写语气；场景 `kWepseedCommentScene` |
| 深色正文 | 强制高对比；strip 内联灰色 |
| 根返回 | 先回 New，New 上双击退出 |
| 更新 | GitHub Releases 分包 APK；优先 arm64-v8a |
| 协议隐私 | 外链仓库 `docs/TERMS.md` / `PRIVACY.md` |
| 开源 | MIT |

### 15.8 本会话变更摘要（便于 diff 记忆）

- **0.0.1**：首 tag Release；MIT；签名私密手册  
- **0.0.2**：返回双击退出；`showAppToast`；关于真版本 + 检查更新下载安装；TERMS/PRIVACY；LLM 重试 + 测试连接；CI Maven 官方优先（修 Aliyun 502）  
- **0.0.3**：通知/Toast 进帖 `go`→`push`（F-notif-back）；New `FeedFilter` 今日/未看/多源 + 持久化 + 选源限刷；Drift schema 4  
- **未收口**：0.0.3 真机全量验收；评论任务杀进程；ROM 后台；流式/WebView  

---

*WEPSEED — local-first RSS with warmth.*
