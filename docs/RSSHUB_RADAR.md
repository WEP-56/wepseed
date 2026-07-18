# WEPSEED · RSSHub 雷达数据说明

> 精选版。完整路由以 [docs.rsshub.app/zh/routes](https://docs.rsshub.app/zh/routes/) 为准；
> 公共实例以 [instances](https://docs.rsshub.app/zh/guide/instances) 为准。
>
> 机器可读目录：`assets/rsshub/radar_catalog.json`（version 1 · 2026-07-18）

---

## 0. 产品用法（雷达三步）

1. **选实例** `instance`（可测连通：`GET {instance}/healthz` 或任意已知路由）
2. **选内容来源** `namespace`（如 bilibili / youtube / telegram）
3. **选路由并填表** 替换 path 中的 `:param` → 得到订阅 URL → `addFeed`

```text
订阅 URL = {instance}{path}
例: https://rsshub.rssforever.com/telegram/channel/awesomeRSSHub
```

草稿自动保存建议字段：`instanceId`, `namespace`, `routePath`, `params{}`, `builtUrl`, `updatedAt`。

---

## 1. 精选原则

| 收 | 不收 |
|----|------|
| 主流社媒 / 视频 / 科技媒体 / 开发者 / 播客 / 电商好价 / 常见外媒 | 高校通知、地方政府、极小众站 |
| 每源只保留高频路由（投稿/动态/频道/Release…） | 同一源下生僻子路由海 |
| 标注 `requireConfig` / `antiCrawler` 风险 | 假装所有公网实例都能用 |

完整 1600+ namespace 不进 app 包体；需要时用户仍可 **手动粘贴完整 RSSHub URL**。

---

## 2. 实例（Instances）

官方列表来源：`InstanceList.vue`（[RSSHub-Docs](https://github.com/DIYgod/RSSHub-Docs)）。
状态会变：添加前应用内「测试」应对 `{instance}` 发起探测。

| ID | URL | 备注 |
|----|-----|------|
| `rsshub.app` | https://rsshub.app | 最常用；部分网络/地区可能 403，可换公共实例。 |
| `rssforever` | https://rsshub.rssforever.com |  |
| `slarker` | https://hub.slarker.me |  |
| `pseudoyu` | https://rsshub.pseudoyu.com |  |
| `rss.tips` | https://rsshub.rss.tips |  |
| `ktachibana` | https://rsshub.ktachibana.party |  |
| `owo` | https://rss.owo.nz |  |
| `wudifeixue` | https://rss.wudifeixue.com |  |
| `littlebaby` | https://rss.littlebaby.life/rsshub |  |
| `henry` | https://rsshub.henry.wang |  |
| `holoxx` | https://holoxx.f5.si |  |
| `umzzz` | https://rsshub.umzzz.com |  |
| `isrss` | https://rsshub.isrss.com |  |
| `email-once` | https://rsshub.email-once.com |  |
| `datuan` | https://rss.datuan.dev |  |
| `4040940` | https://rss.4040940.xyz |  |
| `cups` | https://rsshub.cups.moe |  |
| `spriple` | https://rss.spriple.org |  |
| `virworks` | https://rsshub-balancer.virworks.moe | 负载均衡入口，可用性随上游变化。 |
| `injahow` | https://rss.injahow.cn | 文档列表未收录；B 站等路由在部分公网实例 503 时可作备选。 |

**说明**

- `rsshub.app` 在部分网络返回 403，真机应允许换实例。
- 同一路由在不同实例上成功率不同（B 站反爬尤甚）。
- 用户可自定义实例 URL（雷达里「自定义」）。

---

## 3. 内容来源与路由（精选）

共 **49** 个来源，路由明细以 JSON 为准；下表为摘要。

### YouTube (`youtube`)

频道/播放列表（也可用 YouTube 官方 Atom；雷达走 RSSHub 路由）。

文档：https://docs.rsshub.app/zh/routes/youtube

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/youtube/user/:username/:routeParams?` | Channel with user handle | `/youtube/user/@JFlaMusic` | username | 需配置 |
| `/youtube/channel/:id/:routeParams?` | Channel with id | `/youtube/channel/UCDwDMPOZfxVV0x_dz0eQ8KQ` | id | 需配置 |
| `/youtube/playlist/:id/:embed?` | Playlist | `/youtube/playlist/PLqQ1RwlxOgeLTJ1f3fNMSwhjVgaWKo_9Z` | id | 需配置 |
| `/youtube/subscriptions/:embed?` | Subscriptions | `/youtube/subscriptions` | - | 需配置 |

### 哔哩哔哩 bilibili (`bilibili`)

UP 投稿 / 动态 / 番剧 / 排行榜等。

文档：https://docs.rsshub.app/zh/routes/bilibili

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/bilibili/user/video/:uid/:embed?` | UP 主投稿 | `/bilibili/user/video/2267573` | uid | - |
| `/bilibili/user/dynamic/:uid/:routeParams?` | UP 主动态 | `/bilibili/user/dynamic/2267573` | uid | 需配置 |
| `/bilibili/user/article/:uid` | UP 主图文 | `/bilibili/user/article/334958638` | uid | - |
| `/bilibili/user/fav/:uid/:embed?` | UP 主默认收藏夹 | `/bilibili/user/fav/2267573` | uid | - |
| `/bilibili/user/coin/:uid/:embed?` | UP 主投币视频 | `/bilibili/user/coin/208259` | uid | - |
| `/bilibili/user/bangumi/:uid/:type?` | 用户追番列表 | `/bilibili/user/bangumi/208259` | uid | - |
| `/bilibili/partion/:tid/:embed?` | 分区视频 | `/bilibili/partion/33` | tid | - |
| `/bilibili/bangumi/media/:mediaid/:embed?` | 番剧 | `/bilibili/bangumi/media/9192` | mediaid | 反爬 |
| `/bilibili/weekly/:embed?` | B 站每周必看 | `/bilibili/weekly` | - | - |
| `/bilibili/live/room/:roomID` | 直播开播 | `/bilibili/live/room/3` | roomID | - |

### Telegram (`telegram`)

公开频道。私有频道通常需要实例配置。

文档：https://docs.rsshub.app/zh/routes/telegram

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/telegram/channel/:username/:routeParams?` | Channel | `/telegram/channel/awesomeRSSHub` | username | 需配置 |
| `/telegram/stickerpack/:name` | Sticker Pack | `/telegram/stickerpack/DIYgod` | name | - |
| `/telegram/blog` | Telegram Blog | `/telegram/blog` | - | - |

### GitHub (`github`)

Issue / PR / Trending / 用户仓库与动态。

文档：https://docs.rsshub.app/zh/routes/github

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/github/repos/:user/:type?/:sort?` | User Repo | `/github/repos/DIYgod` | user | - |
| `/github/issue/:user/:repo/:state?/:labels?` | Repo Issues | `/github/issue/DIYgod/RSSHub/open` | user, repo | - |
| `/github/pull/:user/:repo/:state?/:labels?` | Repo Pull Requests | `/github/pull/DIYgod/RSSHub` | user, repo | - |
| `/github/trending/:since/:language/:spoken_language?` | Trending | `/github/trending/daily/javascript/en` | since, language | 需配置 |
| `/github/user/followers/:user` | User Followers | `/github/user/followers/HenryQW` | user | - |
| `/github/stars/:user/:repo` | Repo Stars | `/github/stars/DIYgod/RSSHub` | user, repo | 需配置 |
| `/github/starred_repos/:user` | User Starred Repositories | `/github/starred_repos/DIYgod` | user | 需配置 |
| `/github/branches/:user/:repo` | Repo Branches | `/github/branches/DIYgod/RSSHub` | user, repo | - |
| `/github/file/:user/:repo/:branch/:filepath{.+}` | File Commits | `/github/file/DIYgod/RSSHub/master/README.md` | user, repo, branch, filepath | - |
| `/github/search/:query/:sort?/:order?` | Search Result | `/github/search/RSSHub/bestmatch/desc` | query | - |
| `/github/wiki/:user/:repo/:page?` | Wiki History | `/github/wiki/flutter/flutter/Roadmap` | user, repo | - |
| `/github/discussion/:user/:repo/:state?/:category?` | Repo Discussions | `/github/discussion/DIYgod/RSSHub` | user, repo | 需配置 |
| `/github/repo_event/:owner/:repo/:types?` | Repository Event | `/github/repo_event/DIYgod/RSSHub` | owner, repo | 需配置 |
| `/github/user_event/:username/:types?` | User Event | `/github/user_event/mslxl` | username | 需配置 |

### X (Twitter) (`twitter`)

X/Twitter 用户时间线等（多数实例需配置 token，易失效）。

文档：https://docs.rsshub.app/zh/routes/twitter

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/twitter/user/:id/:routeParams?` | User timeline | `/twitter/user/_RSSHub` | id | 需配置 |
| `/twitter/keyword/:keyword/:routeParams?` | Keyword | `/twitter/keyword/RSSHub` | keyword | 需配置 |
| `/twitter/home/:routeParams?` | Home timeline | `/twitter/home` | - | 需配置 |
| `/twitter/list/:id/:routeParams?` | List timeline | `/twitter/list/1502570462752219136` | id | 需配置 |
| `/twitter/media/:id/:routeParams?` | User media | `/twitter/media/_RSSHub` | id | 需配置 |

### 微博 (`weibo`)

用户时间线、关键词、超话。

文档：https://docs.rsshub.app/zh/routes/weibo

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/weibo/user/:uid/:routeParams?` | 博主 | `/weibo/user/1195230310` | uid | 需配置,反爬 |
| `/weibo/keyword/:keyword/:routeParams?` | 关键词 | `/weibo/keyword/RSSHub` | keyword | 需配置 |
| `/weibo/super_index/:id/:type?/:routeParams?` | 超话 | `/weibo/super_index/1008084989d223732bf6f02f75ea30efad58a9/sort_time` | id | 需配置 |

### 知乎 (`zhihu`)

用户、收藏夹、日报、热榜。

文档：https://docs.rsshub.app/zh/routes/zhihu

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/zhihu/people/activities/:id` | 用户动态 | `/zhihu/people/activities/diygod` | id | 需配置,反爬 |
| `/zhihu/people/answers/:id` | 用户回答 | `/zhihu/people/answers/diygod` | id | 需配置,反爬 |
| `/zhihu/people/pins/:id` | 用户想法 | `/zhihu/people/pins/kan-dan-45` | id | 反爬 |
| `/zhihu/collection/:id/:getAll?` | 收藏夹 | `/zhihu/collection/26444956` | id | 需配置,反爬 |
| `/zhihu/zhuanlan/:id` | 专栏 | `/zhihu/zhuanlan/googledevelopers` | id | 需配置,反爬 |
| `/zhihu/daily` | 知乎日报 | `/zhihu/daily` | - | 反爬 |
| `/zhihu/pin/hotlist` | 知乎想法热榜 | `/zhihu/pin/hotlist` | - | 反爬 |

### 小红书 (`xiaohongshu`)

用户笔记 / 专辑（反爬较强，实例成功率波动大）。

文档：https://docs.rsshub.app/zh/routes/xiaohongshu

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/xiaohongshu/board/:board_id` | 专辑 | `/xiaohongshu/board/5db6f79200000000020032df` | board_id | - |

### 豆瓣 (`douban`)

书影音、小组、豆列、用户日记。

文档：https://docs.rsshub.app/zh/routes/douban

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/douban/movie/later` | 即将上映的电影 | `/douban/movie/later` | - | - |
| `/douban/movie/weekly/:type?` | 一周口碑榜 | `/douban/movie/weekly` | - | - |
| `/douban/movie/classification/:sort?/:score?/:tags?` | 豆瓣电影分类 | `/douban/movie/classification/R/7.5/Netflix,2020` | - | - |
| `/douban/music/latest/:area?` | 最新增加的音乐 | `/douban/music/latest/chinese` | - | - |
| `/douban/group/:groupid/:type?` | 豆瓣小组 | `/douban/group/648102` | groupid | - |
| `/douban/people/:userid/status/:routeParams?` | 用户广播 | `/douban/people/75118396/status` | userid | - |
| `/douban/explore` | 浏览发现 | `/douban/explore` | - | - |
| `/douban/explore/column/:id` | Unknown | `-` | - | - |
| `/douban/celebrity/:id/:sort?` | 豆瓣电影人 | `/douban/celebrity/1274261` | id | - |
| `/douban/doulist/:id` | 豆瓣豆列 | `/douban/doulist/37716774` | id | - |
| `/douban/topic/:id/:sort?` | 话题 | `/douban/topic/48823` | id | - |

### 少数派 sspai (`sspai`)

少数派首页、专题、作者、Matrix。

文档：https://docs.rsshub.app/zh/routes/sspai

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/sspai/index` | 首页 | `/sspai/index` | - | - |
| `/sspai/series` | 最新上架付费专栏 | `/sspai/series` | - | - |
| `/sspai/shortcuts` | Shortcuts Gallery | `/sspai/shortcuts` | - | - |
| `/sspai/matrix` | Matrix | `/sspai/matrix` | - | - |
| `/sspai/author/:id` | 作者 | `/sspai/author/796518` | id | - |
| `/sspai/column/:id` | 专栏 | `/sspai/column/262` | id | 反爬 |
| `/sspai/topics` | 专题 | `/sspai/topics` | - | - |
| `/sspai/topic/:id` | 专题内文章更新 | `/sspai/topic/250` | id | - |
| `/sspai/tag/:keyword` | 标签订阅 | `/sspai/tag/apple` | keyword | - |

### 掘金 (`juejin`)

掘金文章、沸点、用户。

文档：https://docs.rsshub.app/zh/routes/juejin

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/juejin/posts/:id` | 用户文章 | `/juejin/posts/3051900006845944` | id | - |
| `/juejin/category/:category` | 分类 | `/juejin/category/frontend` | category | - |
| `/juejin/tag/:tag` | 标签 | `/juejin/tag/JavaScript` | tag | - |
| `/juejin/trending/:category/:type` | 热门 | `/juejin/trending/ios/monthly` | category, type | - |
| `/juejin/pins/:type?` | 沸点 | `/juejin/pins/6824710202487472141` | - | - |
| `/juejin/books` | 小册 | `/juejin/books` | - | - |
| `/juejin/column/:id` | 专栏 | `/juejin/column/6960559453037199391` | id | - |
| `/juejin/collections/:userId` | 收藏集 | `/juejin/collections/1697301682482439` | userId | - |
| `/juejin/collection/:collectionId` | 单个收藏夹 | `/juejin/collection/6845243180586123271` | collectionId | - |

### V2EX (`v2ex`)

节点、主题、用户。

文档：https://docs.rsshub.app/zh/routes/v2ex

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/v2ex/topics/:type` | 最热 / 最新主题 | `/v2ex/topics/latest` | type | - |
| `/v2ex/tab/:tabid` | 标签 | `/v2ex/tab/hot` | tabid | - |

### 即刻 (`jike`)

用户动态、圈子。

文档：https://docs.rsshub.app/zh/routes/jike

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/jike/user/:id` | 用户动态 | `/jike/user/3EE02BC9-C5B3-4209-8750-4ED1EE0F67BB` | id | - |
| `/jike/topic/:id/:showUid?` | 圈子 | `/jike/topic/556688fae4b00c57d9dd46ee` | id | - |
| `/jike/topic/text/:id` | 圈子 - 纯文字 | `/jike/topic/text/553870e8e4b0cafb0a1bef68` | id | - |

### 36kr (`36kr`)

快讯与资讯热榜（合并路由，参数见表单）。

文档：https://docs.rsshub.app/zh/routes/36kr

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/36kr/:category/:subCategory?/:keyword?` | 资讯, 快讯, 用户文章, 主题文章, 专题文章, 搜索文章, 搜索快讯 | `/36kr/newsflashes` | category | - |
| `/36kr/hot-list/:category?` | 资讯热榜 | `/36kr/hot-list` | - | - |

### iThome 台灣 (`ithome`)

IT 之家（注意与台湾 iThome 命名空间不同时以 routes 为准）。

文档：https://docs.rsshub.app/zh/routes/ithome

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/ithome/:caty` | 分类资讯 | `/ithome/it` | caty | - |
| `/ithome/ranking/:type` | 热榜 | `/ithome/ranking/24h` | type | - |
| `/ithome/tag/:name` | 标签 | `/ithome/tag/win11` | name | - |
| `/ithome/tw/feeds/:category` | Feeds | `/ithome/tw/feeds/news` | category | - |
| `/ithome/zt/:id?` | 专题 | `/ithome/zt/xijiayi` | - | - |

### Solidot (`solidot`)

奇客 Solidot。

文档：https://docs.rsshub.app/zh/routes/solidot

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/solidot/:type?` | 最新消息 | `/solidot/linux` | - | - |

### 极客公园 (`geekpark`)

极客公园。

文档：https://docs.rsshub.app/zh/routes/geekpark

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/geekpark/:column?` | 栏目 | `/geekpark` | - | - |

### 品玩 (`pingwest`)

品玩。

文档：https://docs.rsshub.app/zh/routes/pingwest

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/pingwest/status` | 实时要闻 | `/pingwest/status` | - | - |
| `/pingwest/tag/:tag/:type/:option?` | 话题动态 | `/pingwest/tag/ChinaJoy/1` | tag, type | - |
| `/pingwest/user/:uid/:type?/:option?` | 用户 | `/pingwest/user/7781550877/article` | uid | - |

### Hacker News (`hackernews`)

Hacker News。

文档：https://docs.rsshub.app/zh/routes/hackernews

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/hackernews/:section?/:type?/:value?` | Stories | `/hackernews/threads/comments_list/dang` | - | - |

### Bluesky (bsky) (`bsky`)

Bluesky 用户与关键词。

文档：https://docs.rsshub.app/zh/routes/bsky

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/bsky/keyword/:keyword` | Keywords | `/bsky/keyword/hello` | keyword | - |
| `/bsky/profile/:handle/feed/:space/:routeParams?` | Feeds | `/bsky/profile/jaz.bsky.social/feed/cv:cat` | handle, space | - |
| `/bsky/profile/:handle/:routeParams?` | Post | `/bsky/profile/bsky.app` | handle | - |

### Threads (`threads`)

Threads 用户。

文档：https://docs.rsshub.app/zh/routes/threads

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/threads/:user/:routeParams?` | User timeline | `/threads/zuck` | user | - |

### pixiv (`pixiv`)

用户投稿、排行榜（常需 cookie/配置）。

文档：https://docs.rsshub.app/zh/routes/pixiv

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/pixiv/user/bookmarks/:id` | User Bookmark | `/pixiv/user/bookmarks/15288095` | id | - |
| `/pixiv/user/illustfollows` | Following timeline | `/pixiv/user/illustfollows` | - | 需配置 |
| `/pixiv/ranking/:mode/:date?` | Rankings | `/pixiv/ranking/week` | mode | - |
| `/pixiv/search/:keyword/:order?/:mode?/:include_ai?` | Keyword | `/pixiv/search/Nezuko/popular` | keyword | - |
| `/pixiv/user/:id` | User Activity | `/pixiv/user/15288095` | id | - |
| `/pixiv/novel/series/:id` | Novel Series | `/pixiv/novel/series/11586857` | id | 需配置 |
| `/pixiv/user/novels/:id/:full_content?` | User Novels | `/pixiv/user/novels/27104704` | id | 需配置 |

### Spotify (`spotify`)

艺人 / 播客 / 播放列表。

文档：https://docs.rsshub.app/zh/routes/spotify

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/spotify/artist/:id` | Artist Albums | `/spotify/artist/6k9TBCxyr4bXwZ8Y21Kwn1` | id | 需配置 |
| `/spotify/top/artists` | Personal Top Artists | `/spotify/top/artists` | - | 需配置 |
| `/spotify/playlist/:id` | Playlist | `/spotify/playlist/4UBVy1LttvodwivPUuwJk2` | id | 需配置 |
| `/spotify/saved/:limit?` | Personal Saved Tracks | `/spotify/saved/50` | - | 需配置 |
| `/spotify/show/:id` | Show/Podcasts | `/spotify/show/5CfCWKI5pZ28U0uOzXkDHe` | id | 需配置 |
| `/spotify/top/tracks` | Personal Top Tracks | `/spotify/top/tracks` | - | 需配置 |

### 小宇宙 (`xiaoyuzhou`)

小宇宙播客。

文档：https://docs.rsshub.app/zh/routes/xiaoyuzhou

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/xiaoyuzhou/` | Unknown | `-` | - | - |
| `/xiaoyuzhou/podcast/:id` | 播客 | `/xiaoyuzhou/podcast/6021f949a789fca4eff4492c` | id | - |

### Steam (`steam`)

愿望单、搜索、新闻。

文档：https://docs.rsshub.app/zh/routes/steam

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/steam/news/:appid/:language?` | News | `/steam/news/958260/english` | appid | - |
| `/steam/appcommunityfeed/:appid/:routeParams?` | Steam Community Hub Feeds | `/steam/appcommunityfeed/730` | appid | - |
| `/steam/curator/:id/:routeParams?` | Latest Curator Reviews | `/steam/curator/34646096-80-Days` | id | - |
| `/steam/search/:params` | Store Search | `/steam/search/sort_by=Released_DESC&tags=492&category1=10&os=linux` | params | - |
| `/steam/sharefile-changelog/:sharefileID/:routeParams?` | Sharefile Changelog | `/steam/sharefile-changelog/2851063440/l=schinese` | sharefileID | - |
| `/steam/workshopsearch/:appid?/:routeParams?` | Community Workshop Search | `/steam/workshopsearch/730` | - | - |

### Epic Games Store (`epicgames`)

Epic 免费游戏等。

文档：https://docs.rsshub.app/zh/routes/epicgames

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/epicgames/freegames/:locale?/:country?` | Free games | `/epicgames/freegames/en-US/US` | - | - |

### 什么值得买 (`smzdm`)

什么值得买关键词与好价。

文档：https://docs.rsshub.app/zh/routes/smzdm

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/smzdm/ranking/:rank_type/:rank_id/:hour` | 排行榜 | `/smzdm/ranking/pinlei/11/3` | rank_type, rank_id, hour | 需配置 |
| `/smzdm/article/:uid` | 用户文章 | `/smzdm/article/6902738986` | uid | 需配置 |
| `/smzdm/baoliao/:uid` | 用户爆料 | `/smzdm/baoliao/7367111021` | uid | 需配置 |
| `/smzdm/haowen/fenlei/:name/:sort?` | 好文分类 | `/smzdm/haowen/fenlei/shenghuodianqi` | name | 需配置 |
| `/smzdm/haowen/:day?` | 好文 | `/smzdm/haowen/1` | - | 需配置 |
| `/smzdm/keyword/:keyword` | 关键词 | `/smzdm/keyword/女装` | keyword | 需配置 |
| `/smzdm/product/:id` | 商品 | `/smzdm/product/zm5vzpe` | id | 需配置 |

### Product Hunt (`producthunt`)

Product Hunt 日榜。

文档：https://docs.rsshub.app/zh/routes/producthunt

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/producthunt/today` | Top Products Launching Today | `/producthunt/today` | - | - |

### Nature Journal (`nature`)

Nature 期刊栏目。

文档：https://docs.rsshub.app/zh/routes/nature

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/nature/cover` | Cover Story | `/nature/cover` | - | - |
| `/nature/highlight/:journal?` | Research Highlight | `/nature/highlight` | - | - |
| `/nature/news-and-comment/:journal?` | Unknown | `-` | - | - |
| `/nature/news` | Nature News | `/nature/news` | - | - |
| `/nature/research/:journal?` | Latest Research | `/nature/research/ng` | - | - |
| `/nature/siteindex` | Journal List | `/nature/siteindex` | - | - |

### BBC (`bbc`)

BBC 频道。

文档：https://docs.rsshub.app/zh/routes/bbc

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/bbc/learningenglish/:channel?` | Learning English | `/bbc/learningenglish/take-away-english` | - | - |
| `/bbc/sport/:sport` | Sport | `/bbc/sport/formula1` | sport | - |
| `/bbc/zhongwen/topics/:topic/:variant?` | Topics - BBC News 中文 | `/bbc/zhongwen/topics/ckr7mn6r003t` | topic | - |
| `/bbc/topics/:topic` | Topics | `/bbc/topics/c77jz3md4rwt` | topic | - |
| `/bbc/:site?/:channel?` | News | `/bbc/world-asia` | - | - |

### The Verge (`theverge`)

The Verge。

文档：https://docs.rsshub.app/zh/routes/theverge

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/theverge/:hub?` | Category | `/theverge` | - | - |

### The New York Times (`nytimes`)

纽约时报（部分路由需配置）。

文档：https://docs.rsshub.app/zh/routes/nytimes

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/nytimes/book/:category?` | Best Seller Books | `/nytimes/book/combined-print-and-e-book-nonfiction` | - | - |
| `/nytimes/daily_briefing_chinese` | Daily Briefing | `/nytimes/daily_briefing_chinese` | - | - |
| `/nytimes/:lang?` | News | `/nytimes/dual` | - | - |
| `/nytimes/rss/:cat?` | News | `/nytimes/rss/HomePage` | - | - |

### AP News (`apnews`)

AP News。

文档：https://docs.rsshub.app/zh/routes/apnews

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/apnews/sitemap/:route` | Sitemap | `/apnews/sitemap/ap-sitemap-latest` | route | - |
| `/apnews/topics/:topic?` | Topics | `/apnews/topics/apf-topnews` | - | - |
| `/apnews/mobile/:path{.+}?` | News (from mobile client API) | `/apnews/mobile` | path | - |
| `/apnews/rss/:category?` | News | `/apnews/rss/business` | - | - |

### 华尔街见闻 (`wallstreetcn`)

华尔街见闻。

文档：https://docs.rsshub.app/zh/routes/wallstreetcn

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/wallstreetcn/calendar/:section?` | 财经日历 | `/wallstreetcn/calendar` | - | - |
| `/wallstreetcn/hot/:period?` | 最热文章 | `/wallstreetcn/hot` | - | - |
| `/wallstreetcn/news/:category?` | 资讯 | `/wallstreetcn/news` | - | - |
| `/wallstreetcn/live/:category?/:score?` | 实时快讯 | `/wallstreetcn/live` | - | - |

### 财联社 (`cls`)

财联社。

文档：https://docs.rsshub.app/zh/routes/cls

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/cls/telegraph/:category?` | 电报 | `/cls/telegraph` | - | - |
| `/cls/depth/:category?` | 深度 | `/cls/depth/1000` | - | - |
| `/cls/hot` | 热门文章排行榜 | `/cls/hot` | - | 反爬 |
| `/cls/subject/:id?` | 话题 | `/cls/subject/1103` | - | - |

### 财新博客 (`caixin`)

财新。

文档：https://docs.rsshub.app/zh/routes/caixin

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/caixin/k` | 财新一线 | `/caixin/k` | - | - |
| `/caixin/blog/:column?` | 用户博客 | `/caixin/blog/zhangwuchang` | - | - |
| `/caixin/:column/:category` | 新闻分类 | `/caixin/finance/regulation` | column, category | - |
| `/caixin/database` | 财新数据通 | `/caixin/database` | - | - |
| `/caixin/weekly` | 财新周刊 | `/caixin/weekly` | - | - |
| `/caixin/article` | 首页新闻 | `/caixin/article` | - | - |
| `/caixin/latest` | 最新文章 | `/caixin/latest` | - | - |

### 联合早报 (`zaobao`)

联合早报。

文档：https://docs.rsshub.app/zh/routes/zaobao

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/zaobao/interactive-graphics` | 互动新闻 | `/zaobao/interactive-graphics` | - | - |
| `/zaobao/other/:type?/:section?` | 其他栏目 | `/zaobao/other/lifestyle/health` | - | - |
| `/zaobao/realtime/:section?` | 即时新闻 | `/zaobao/realtime/china` | - | - |
| `/zaobao/znews/:section?` | 新闻 | `/zaobao/znews/china` | - | - |

### 酷安 (`coolapk`)

酷安（话题 / 用户等）。

文档：https://docs.rsshub.app/zh/routes/coolapk

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/coolapk/dyh/:dyhId` | 看看号 | `/coolapk/dyh/1524` | dyhId | 需配置 |
| `/coolapk/hot/:type?/:period?` | 热榜 | `/coolapk/hot` | - | 需配置 |
| `/coolapk/huati/:tag` | 话题 | `/coolapk/huati/iPhone` | tag | 需配置 |
| `/coolapk/toutiao/:type?` | 头条 | `/coolapk/toutiao` | - | 需配置 |
| `/coolapk/tuwen/:type?` | 图文 | `/coolapk/tuwen` | - | 需配置 |
| `/coolapk/user/:uid/dynamic` | 用户 | `/coolapk/user/3177668/dynamic` | uid | 需配置 |

### 小黑盒 (`xiaoheihe`)

小黑盒。

文档：https://docs.rsshub.app/zh/routes/xiaoheihe

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/xiaoheihe/discount/:platform` | 游戏折扣 | `/xiaoheihe/discount/pc` | platform | - |
| `/xiaoheihe/add2cart/:platform` | 喜加一 | `/xiaoheihe/add2cart/epic` | platform | - |
| `/xiaoheihe/news` | 游戏新闻 | `/xiaoheihe/news` | - | - |
| `/xiaoheihe/user/:id` | 用户动态 | `/xiaoheihe/user/30664023` | id | - |

### 竹白 (`zhubai`)

竹白专栏。

文档：https://docs.rsshub.app/zh/routes/zhubai

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/zhubai/posts/:id` | 文章 | `/zhubai/posts/via` | id | - |
| `/zhubai/top20` | 上周热门 TOP 20 | `/zhubai/top20` | - | - |

### 微信小程序 (`wechat`)

公众号相关（强依赖第三方/配置，不稳定）。

文档：https://docs.rsshub.app/zh/routes/wechat

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/wechat/wechat2rss/:id` | 公众号（Wechat2RSS 来源） | `/wechat/wechat2rss/5b925323244e9737c39285596c53e3a2f4a30774` | id | - |
| `/wechat/announce` | 公众平台系统公告栏目 | `/wechat/announce` | - | - |
| `/wechat/ce/:id` | 公众号（CareerEngine 来源） | `/wechat/ce/595a5b14d7164e53908f1606` | id | 反爬 |
| `/wechat/data258/:id?` | Unknown | `-` | - | - |
| `/wechat/ershicimi/:id` | 公众号（二十次幂来源） | `/wechat/ershicimi/813oxJOl` | id | 反爬 |
| `/wechat/mp/homepage/:biz/:hid/:cid?` | 公众号栏目 (非推送 & 历史消息) | `/wechat/mp/homepage/MzA3MDM3NjE5NQ==/16` | biz, hid | 反爬 |
| `/wechat/mp/msgalbum/:biz/:aid` | 公众号文章话题 Tag | `/wechat/mp/msgalbum/MzA3MDM3NjE5NQ==/1375870284640911361` | biz, aid | 反爬 |
| `/wechat/sogou/:id` | 公众号（搜狗来源） | `/wechat/sogou/qimao0908` | id | 反爬 |

### 抖音直播 (`douyin`)

抖音直播等。

文档：https://docs.rsshub.app/zh/routes/douyin

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/douyin/hashtag/:cid/:routeParams?` | 标签 | `/douyin/hashtag/1592824105719812` | cid | 反爬 |
| `/douyin/live/:rid` | 直播间开播 | `/douyin/live/685317364746` | rid | 反爬 |
| `/douyin/user/:uid/:routeParams?` | 博主 | `/douyin/user/MS4wLjABAAAARcAHmmF9mAG3JEixq_CdP72APhBlGlLVbN-1eBcPqao` | uid | 反爬 |

### TikTok (`tiktok`)

TikTok 用户。

文档：https://docs.rsshub.app/zh/routes/tiktok

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/tiktok/live/:user` | Live | `/tiktok/live/@shinichifuku` | user | - |
| `/tiktok/user/:user/:iframe?` | User | `/tiktok/user/@linustech/true` | user | - |

### Instagram (`instagram`)

Instagram（常经 picnob 等，实例差异大）。

文档：https://docs.rsshub.app/zh/routes/instagram

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/instagram/:category/:key` | User Profile / Hashtag - Private API | `/instagram/user/stefaniejoosten` | category, key | 需配置,反爬 |
| `/instagram/2/:category/:key` | User Profile / Hashtag | `/instagram/2/user/stefaniejoosten` | category, key | 反爬 |

### Mastodon (`mastodon`)

Mastodon 实例用户/时间线。

文档：https://docs.rsshub.app/zh/routes/mastodon

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/mastodon/tag/:site/:hashtag/:only_media?` | Hashtag timeline | `/mastodon/tag/mastodon.social/gochisou/true` | site, hashtag | - |
| `/mastodon/timeline/:site/:only_media?` | Instance timeline (local) | `/mastodon/timeline/pawoo.net/true` | site | - |
| `/mastodon/remote/:site/:only_media?` | Instance timeline (federated) | `/mastodon/remote/pawoo.net/true` | site | - |
| `/mastodon/account_id/:site/:account_id/statuses/:only_media?` | User timeline (by account ID) | `/mastodon/account_id/mas.to/109300507275095341/statuses/false` | site, account_id | - |
| `/mastodon/acct/:acct/statuses/:only_media?` | User timeline | `/mastodon/acct/Mastodon@mastodon.social/statuses` | acct | - |

### Twitch (`twitch`)

Twitch 直播与视频。

文档：https://docs.rsshub.app/zh/routes/twitch

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/twitch/live/:login` | Live | `/twitch/live/riotgames` | login | - |
| `/twitch/schedule/:login` | Stream Schedule | `/twitch/schedule/riotgames` | login | - |
| `/twitch/video/:login/:filter?` | Channel Video | `/twitch/video/riotgames/highlights` | login | - |

### AcFun (`acfun`)

AcFun UP 与分区。

文档：https://docs.rsshub.app/zh/routes/acfun

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/acfun/bangumi/:id/:embed?` | 番剧 | `/acfun/bangumi/6000617` | id | - |
| `/acfun/article/:categoryId/:sortType?/:timeRange?` | 文章 | `/acfun/article/110` | categoryId | - |
| `/acfun/user/video/:uid/:embed?` | 用户投稿 | `/acfun/user/video/6102` | uid | - |

### 开源中国 (`oschina`)

开源中国。

文档：https://docs.rsshub.app/zh/routes/oschina

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/oschina/u/:uid` | 用户博客 | `/oschina/u/3920392` | uid | - |
| `/oschina/news/:category?` | 资讯 | `/oschina/news` | - | - |
| `/oschina/column/:id` | 专栏 | `/oschina/column/14` | id | - |
| `/oschina/event/:category?` | 活动 | `/oschina/event` | - | - |
| `/oschina/topic/:topic` | 问答主题 | `/oschina/topic/weekly-news` | topic | - |

### cnBeta.COM (`cnbeta`)

cnBeta。

文档：https://docs.rsshub.app/zh/routes/cnbeta

| 路由 | 名称 | 示例 | 必填参数 | 风险 |
|------|------|------|----------|------|
| `/cnbeta/category/:id` | 分类 | `/cnbeta/category/movie` | id | - |
| `/cnbeta/` | 头条资讯 | `/cnbeta` | - | - |
| `/cnbeta/topics/:id` | 主题 | `/cnbeta/topics/453` | id | - |

---

## 4. 表单字段模型（给 UI / 草稿）

```json
{
  "instanceId": "rssforever",
  "instanceUrl": "https://rsshub.rssforever.com",
  "namespace": "bilibili",
  "routePath": "/user/video/:uid/:embed?",
  "params": { "uid": "2267573", "embed": "" },
  "builtUrl": "https://rsshub.rssforever.com/bilibili/user/video/2267573"
}
```

拼 URL 规则：

1. 用 `params` 替换 path 中 `:name` / `:name?`；空可选段及其 `/` 删掉。
2. 前置 namespace：RSSHub 的 example 通常已含 namespace（如 `/bilibili/user/video/2267573`）。
   以 `route.example` 与 `route.path` 为准——**订阅 path = example 的模式，参数替换后不以 namespace 再拼一层。**
3. `builtUrl = instanceUrl.rstrip('/') + '/' + path.lstrip('/')`（若 path 已以 namespace 开头则不要重复）。

参数 schema（来自 JSON `parameters`）：

| 字段 | 含义 |
|------|------|
| `description` | 表单 label / hint |
| `default` | 默认值，可空 |
| `required` | 是否必填 |
| `options` | 枚举（如下拉），可空 |

---

## 5. 应用内能力对照

| 能力 | 说明 |
|------|------|
| 测试 | HEAD/GET 实例 healthz 或 builtUrl，展示状态码与是否像 feed |
| 添加 | `builtUrl` → 现有 `FeedRepository.addFeed` |
| 草稿 | 本地持久化未提交表单（SharedPreferences / Drift settings） |
| 关闭入口 | 设置项 `showExploreTab`（默认 true） |

---

## 6. 维护

- 上游：`https://raw.githubusercontent.com/DIYgod/RSSHub-Docs/main/src/public/routes.json`
- 重建脚本：`docs/_build_radar_catalog.py`（需本地 `_routes_raw.json`）
- 增删来源：改脚本内 `CURATED` 后重跑
- **不要**把完整 routes.json（数 MB）打进 APK

---

## 7. 非目标（本精选明确不做）

- 高校 / 政府 / 小众地域站全量收录
- 依赖 Folo 云 trending / AGPL 客户端代码
- 把 RSSHub 实例稳定性担保写进产品承诺

*数据用于 WEPSEED 雷达；RSSHub 商标与路由归原项目。*
