"""Build curated RSSHub radar catalog for WEPSEED (popular routes only)."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RAW = Path(__file__).with_name("_routes_raw.json")
OUT_JSON = ROOT / "assets" / "rsshub" / "radar_catalog.json"
OUT_DOC = Path(__file__).with_name("RSSHUB_RADAR.md")

# Official + public instances (from docs.rsshub.app InstanceList.vue, 2026-07).
# Online status fluctuates; health check path is /healthz on most instances.
INSTANCES = [
    {
        "id": "rsshub.app",
        "url": "https://rsshub.app",
        "label": "官方",
        "location": "Cloudflare",
        "maintainer": "DIYgod",
        "official": True,
        "notes": "最常用；部分网络/地区可能 403，可换公共实例。",
    },
    {
        "id": "rssforever",
        "url": "https://rsshub.rssforever.com",
        "label": "rssforever",
        "location": "🇺🇸",
        "maintainer": "Stille",
        "official": False,
    },
    {
        "id": "slarker",
        "url": "https://hub.slarker.me",
        "label": "slarker",
        "location": "🇺🇸",
        "maintainer": "Slarker",
        "official": False,
    },
    {
        "id": "pseudoyu",
        "url": "https://rsshub.pseudoyu.com",
        "label": "pseudoyu",
        "location": "🇺🇸",
        "maintainer": "pseudoyu",
        "official": False,
    },
    {
        "id": "rss.tips",
        "url": "https://rsshub.rss.tips",
        "label": "rss.tips",
        "location": "🇺🇸",
        "maintainer": "AboutRSS",
        "official": False,
    },
    {
        "id": "ktachibana",
        "url": "https://rsshub.ktachibana.party",
        "label": "ktachibana",
        "location": "🇺🇸",
        "maintainer": "KTachibanaM",
        "official": False,
    },
    {
        "id": "owo",
        "url": "https://rss.owo.nz",
        "label": "owo",
        "location": "🇩🇪",
        "maintainer": "Vincent Yang",
        "official": False,
    },
    {
        "id": "wudifeixue",
        "url": "https://rss.wudifeixue.com",
        "label": "wudifeixue",
        "location": "🇨🇦",
        "maintainer": "wudifeixue",
        "official": False,
    },
    {
        "id": "littlebaby",
        "url": "https://rss.littlebaby.life/rsshub",
        "label": "littlebaby",
        "location": "🇺🇸",
        "maintainer": "yuanhong",
        "official": False,
    },
    {
        "id": "henry",
        "url": "https://rsshub.henry.wang",
        "label": "henry.wang",
        "location": "🇬🇧",
        "maintainer": "HenryQW",
        "official": False,
    },
    {
        "id": "holoxx",
        "url": "https://holoxx.f5.si",
        "label": "holoxx",
        "location": "🇯🇵",
        "maintainer": "Vania",
        "official": False,
    },
    {
        "id": "umzzz",
        "url": "https://rsshub.umzzz.com",
        "label": "umzzz",
        "location": "🇭🇰",
        "maintainer": "nesay",
        "official": False,
    },
    {
        "id": "isrss",
        "url": "https://rsshub.isrss.com",
        "label": "isrss",
        "location": "🇺🇸",
        "maintainer": "isRSS",
        "official": False,
    },
    {
        "id": "email-once",
        "url": "https://rsshub.email-once.com",
        "label": "email-once",
        "location": "🇭🇰",
        "maintainer": "EmailOnce",
        "official": False,
    },
    {
        "id": "datuan",
        "url": "https://rss.datuan.dev",
        "label": "datuan",
        "location": "🇻🇳",
        "maintainer": "Tuấn Dev",
        "official": False,
    },
    {
        "id": "4040940",
        "url": "https://rss.4040940.xyz",
        "label": "4040940",
        "location": "🇺🇸",
        "maintainer": "TingyuShare",
        "official": False,
    },
    {
        "id": "cups",
        "url": "https://rsshub.cups.moe",
        "label": "cups",
        "location": "🇨🇳",
        "maintainer": "FunnyCups",
        "official": False,
    },
    {
        "id": "spriple",
        "url": "https://rss.spriple.org",
        "label": "spriple",
        "location": "🇺🇸",
        "maintainer": "Spriple",
        "official": False,
    },
    {
        "id": "virworks",
        "url": "https://rsshub-balancer.virworks.moe",
        "label": "virworks-balancer",
        "location": "🇺🇸",
        "maintainer": "chesha1",
        "official": False,
        "notes": "负载均衡入口，可用性随上游变化。",
    },
    {
        "id": "injahow",
        "url": "https://rss.injahow.cn",
        "label": "injahow",
        "location": "?",
        "maintainer": "community",
        "official": False,
        "notes": "文档列表未收录；B 站等路由在部分公网实例 503 时可作备选。",
    },
]

# Curated sources: only high-value platforms + common routes.
# path keys match RSSHub routes.json route path (without leading domain).
CURATED: dict[str, dict] = {
    "youtube": {
        "priority": 10,
        "icon": "youtube",
        "blurb": "频道/播放列表（也可用 YouTube 官方 Atom；雷达走 RSSHub 路由）。",
        "routes": [
            "/user/:username/:routeParams?",
            "/channel/:id/:routeParams?",
            "/playlist/:id/:embed?",
            "/subscriptions/:embed?",
        ],
    },
    "bilibili": {
        "priority": 20,
        "icon": "bilibili",
        "blurb": "UP 投稿 / 动态 / 番剧 / 排行榜等。",
        "routes": [
            "/user/video/:uid/:embed?",
            "/user/dynamic/:uid/:routeParams?",
            "/user/article/:uid",
            "/user/fav/:uid/:embed?",
            "/user/coin/:uid/:embed?",
            "/user/bangumi/:uid/:type?",
            "/partion/:tid/:embed?",
            "/ranking/:rid?/:day?/:arc_type?/:disableEmbed?",
            "/bangumi/media/:mediaid/:embed?",
            "/weekly/:embed?",
            "/live/room/:roomID",
        ],
    },
    "telegram": {
        "priority": 30,
        "icon": "telegram",
        "blurb": "公开频道。私有频道通常需要实例配置。",
        "routes": [
            "/channel/:username/:routeParams?",
            "/stickerpack/:name",
            "/blog",
        ],
    },
    "github": {
        "priority": 40,
        "icon": "github",
        "blurb": "Issue / PR / Trending / 用户仓库与动态。",
        "routes": [
            "/repos/:user/:type?/:sort?",
            "/issue/:user/:repo/:state?/:labels?",
            "/pull/:user/:repo/:state?/:labels?",
            "/trending/:since/:language/:spoken_language?",
            "/user/followers/:user",
            "/stars/:user/:repo",
            "/starred_repos/:user",
            "/branches/:user/:repo",
            "/file/:user/:repo/:branch/:filepath{.+}",
            "/search/:query/:sort?/:order?",
            "/wiki/:user/:repo/:page?",
            "/discussion/:user/:repo/:state?/:category?",
            "/repo_event/:owner/:repo/:types?",
            "/user_event/:username/:types?",
        ],
    },
    "twitter": {
        "priority": 50,
        "icon": "x",
        "blurb": "X/Twitter 用户时间线等（多数实例需配置 token，易失效）。",
        "routes": [
            "/user/:id/:routeParams?",
            "/keyword/:keyword/:routeParams?",
            "/home/:routeParams?",
            "/list/:id/:routeParams?",
            "/media/:id/:routeParams?",
        ],
    },
    "weibo": {
        "priority": 60,
        "icon": "weibo",
        "blurb": "用户时间线、关键词、超话。",
        "routes": [
            "/user/:uid/:routeParams?",
            "/keyword/:keyword/:routeParams?",
            "/search/hot",
            "/super_index/:id/:type?/:routeParams?",
        ],
    },
    "zhihu": {
        "priority": 70,
        "icon": "zhihu",
        "blurb": "用户、收藏夹、日报、热榜。",
        "routes": [
            "/people/activities/:id",
            "/people/answers/:id",
            "/people/pins/:id",
            "/collection/:id/:getAll?",
            "/zhuanlan/:id",
            "/daily",
            "/hotlist",
            "/hot",
            "/topic/:topicId/:type?",
        ],
    },
    "xiaohongshu": {
        "priority": 80,
        "icon": "xiaohongshu",
        "blurb": "用户笔记 / 专辑（反爬较强，实例成功率波动大）。",
        "routes": [
            "/user/:user_id/:category",
            "/board/:board_id",
        ],
    },
    "douban": {
        "priority": 90,
        "icon": "douban",
        "blurb": "书影音、小组、豆列、用户日记。",
        "routes": [
            "/movie/playing",
            "/movie/later",
            "/movie/weekly/:type?",
            "/movie/classification/:sort?/:score?/:tags?",
            "/book/latest",
            "/book/rank/:type",
            "/music/latest/:area?",
            "/group/:groupid/:type?",
            "/people/:userid/status/:routeParams?",
            "/people/:userid/notes",
            "/people/:userid/wish/:type?",
            "/list/:type/:id",
            "/explore",
            "/explore/column/:id",
            "/celebrity/:id/:sort?",
            "/doulist/:id",
            "/topic/:id/:sort?",
        ],
    },
    "sspai": {
        "priority": 100,
        "icon": "sspai",
        "blurb": "少数派首页、专题、作者、Matrix。",
        "routes": [
            "/index",
            "/series",
            "/shortcuts",
            "/matrix",
            "/author/:id",
            "/column/:id",
            "/topics",
            "/topic/:id",
            "/tag/:keyword",
            "/activity/:id",
        ],
    },
    "juejin": {
        "priority": 110,
        "icon": "juejin",
        "blurb": "掘金文章、沸点、用户。",
        "routes": [
            "/posts/:id",
            "/category/:category",
            "/tag/:tag",
            "/trending/:category/:type",
            "/pins/:type?",
            "/books",
            "/column/:id",
            "/collections/:userId",
            "/collection/:collectionId",
        ],
    },
    "v2ex": {
        "priority": 120,
        "icon": "v2ex",
        "blurb": "节点、主题、用户。",
        "routes": [
            "/topics/:type",
            "/tab/:tabid",
            "/member/:username/:type?",
            "/namespace/:name",
        ],
    },
    "jike": {
        "priority": 130,
        "icon": "jike",
        "blurb": "用户动态、圈子。",
        "routes": [
            "/user/:id",
            "/topic/:id/:showUid?",
            "/topic/text/:id",
        ],
    },
    "36kr": {
        "priority": 140,
        "icon": "36kr",
        "blurb": "快讯与资讯热榜（合并路由，参数见表单）。",
        "routes": "all",
    },
    "ithome": {
        "priority": 150,
        "icon": "ithome",
        "blurb": "IT 之家（注意与台湾 iThome 命名空间不同时以 routes 为准）。",
        "routes": "all_popular",
    },
    "solidot": {
        "priority": 160,
        "icon": "solidot",
        "blurb": "奇客 Solidot。",
        "routes": "all",
    },
    "geekpark": {
        "priority": 170,
        "icon": "geekpark",
        "blurb": "极客公园。",
        "routes": "all_popular",
    },
    "pingwest": {
        "priority": 180,
        "icon": "pingwest",
        "blurb": "品玩。",
        "routes": "all_popular",
    },
    "hackernews": {
        "priority": 190,
        "icon": "hackernews",
        "blurb": "Hacker News。",
        "routes": "all",
    },
    "bsky": {
        "priority": 200,
        "icon": "bsky",
        "blurb": "Bluesky 用户与关键词。",
        "routes": "all_popular",
    },
    "threads": {
        "priority": 210,
        "icon": "threads",
        "blurb": "Threads 用户。",
        "routes": "all",
    },
    "pixiv": {
        "priority": 220,
        "icon": "pixiv",
        "blurb": "用户投稿、排行榜（常需 cookie/配置）。",
        "routes": "all_popular",
    },
    "spotify": {
        "priority": 230,
        "icon": "spotify",
        "blurb": "艺人 / 播客 / 播放列表。",
        "routes": "all_popular",
    },
    "xiaoyuzhou": {
        "priority": 240,
        "icon": "xiaoyuzhou",
        "blurb": "小宇宙播客。",
        "routes": "all",
    },
    "steam": {
        "priority": 250,
        "icon": "steam",
        "blurb": "愿望单、搜索、新闻。",
        "routes": "all_popular",
    },
    "epicgames": {
        "priority": 260,
        "icon": "epicgames",
        "blurb": "Epic 免费游戏等。",
        "routes": "all_popular",
    },
    "smzdm": {
        "priority": 270,
        "icon": "smzdm",
        "blurb": "什么值得买关键词与好价。",
        "routes": "all_popular",
    },
    "producthunt": {
        "priority": 280,
        "icon": "producthunt",
        "blurb": "Product Hunt 日榜。",
        "routes": "all_popular",
    },
    "nature": {
        "priority": 290,
        "icon": "nature",
        "blurb": "Nature 期刊栏目。",
        "routes": "all_popular",
    },
    "bbc": {
        "priority": 300,
        "icon": "bbc",
        "blurb": "BBC 频道。",
        "routes": "all_popular",
    },
    "theverge": {
        "priority": 310,
        "icon": "theverge",
        "blurb": "The Verge。",
        "routes": "all_popular",
    },
    "nytimes": {
        "priority": 320,
        "icon": "nytimes",
        "blurb": "纽约时报（部分路由需配置）。",
        "routes": "all_popular",
    },
    "apnews": {
        "priority": 330,
        "icon": "apnews",
        "blurb": "AP News。",
        "routes": "all_popular",
    },
    "wallstreetcn": {
        "priority": 340,
        "icon": "wallstreetcn",
        "blurb": "华尔街见闻。",
        "routes": "all_popular",
    },
    "cls": {
        "priority": 350,
        "icon": "cls",
        "blurb": "财联社。",
        "routes": "all_popular",
    },
    "caixin": {
        "priority": 360,
        "icon": "caixin",
        "blurb": "财新。",
        "routes": "all_popular",
    },
    "zaobao": {
        "priority": 370,
        "icon": "zaobao",
        "blurb": "联合早报。",
        "routes": "all_popular",
    },
    "coolapk": {
        "priority": 380,
        "icon": "coolapk",
        "blurb": "酷安（话题 / 用户等）。",
        "routes": "all_popular",
    },
    "xiaoheihe": {
        "priority": 390,
        "icon": "xiaoheihe",
        "blurb": "小黑盒。",
        "routes": "all_popular",
    },
    "zhubai": {
        "priority": 400,
        "icon": "zhubai",
        "blurb": "竹白专栏。",
        "routes": "all_popular",
    },
    "wechat": {
        "priority": 410,
        "icon": "wechat",
        "blurb": "公众号相关（强依赖第三方/配置，不稳定）。",
        "routes": "all_popular",
    },
    "douyin": {
        "priority": 420,
        "icon": "douyin",
        "blurb": "抖音直播等。",
        "routes": "all_popular",
    },
    "tiktok": {
        "priority": 430,
        "icon": "tiktok",
        "blurb": "TikTok 用户。",
        "routes": "all_popular",
    },
    "instagram": {
        "priority": 440,
        "icon": "instagram",
        "blurb": "Instagram（常经 picnob 等，实例差异大）。",
        "routes": "all_popular",
    },
    "mastodon": {
        "priority": 450,
        "icon": "mastodon",
        "blurb": "Mastodon 实例用户/时间线。",
        "routes": "all_popular",
    },
    "twitch": {
        "priority": 460,
        "icon": "twitch",
        "blurb": "Twitch 直播与视频。",
        "routes": "all_popular",
    },
    "acfun": {
        "priority": 470,
        "icon": "acfun",
        "blurb": "AcFun UP 与分区。",
        "routes": "all_popular",
    },
    "oschina": {
        "priority": 480,
        "icon": "oschina",
        "blurb": "开源中国。",
        "routes": "all_popular",
    },
    "cnbeta": {
        "priority": 490,
        "icon": "cnbeta",
        "blurb": "cnBeta。",
        "routes": "all_popular",
    },
}


def _param_required(path: str, name: str) -> bool:
    for token in path.strip("/").split("/"):
        if token == f":{name}":
            return True
        if token.startswith(f":{name}?") or token == f":{name}?":
            return False
        # patterns like :filepath{.+ }
        if token.startswith(f":{name}") and "?" not in token.split("{")[0]:
            # :name or :name{...}
            base = token[1:].split("{")[0].split("(")[0]
            if base == name:
                return True
    return False


def _normalize_params(path: str, params: object) -> dict:
    out: dict = {}
    if not params:
        return out
    if not isinstance(params, dict):
        return out
    for pk, pv in params.items():
        if isinstance(pv, str):
            out[pk] = {
                "description": pv,
                "default": None,
                "required": _param_required(path, pk),
                "options": None,
            }
        elif isinstance(pv, dict):
            out[pk] = {
                "description": pv.get("description") or "",
                "default": pv.get("default"),
                "required": _param_required(path, pk),
                "options": pv.get("options"),
            }
        else:
            out[pk] = {
                "description": str(pv),
                "default": None,
                "required": _param_required(path, pk),
                "options": None,
            }
    return out


def _pick_routes(ns: str, ns_data: dict, selector) -> dict:
    all_routes = ns_data.get("routes") or {}
    if selector == "all":
        keys = list(all_routes.keys())
    elif selector == "all_popular":
        keys = []
        for rk, rv in all_routes.items():
            cats = set(rv.get("categories") or [])
            if cats & {"university", "government"} and not (cats & {"popular", "social-media", "new-media"}):
                continue
            if "popular" in cats or len(all_routes) <= 8:
                keys.append(rk)
        if not keys:
            # fallback: first 8 non gov/uni
            for rk, rv in all_routes.items():
                cats = set(rv.get("categories") or [])
                if cats <= {"university", "government"}:
                    continue
                keys.append(rk)
                if len(keys) >= 8:
                    break
    elif isinstance(selector, list):
        keys = []
        for want in selector:
            if want in all_routes:
                keys.append(want)
                continue
            # fuzzy: match by path field
            found = None
            for rk, rv in all_routes.items():
                p = rv.get("path") or rk
                if not isinstance(p, str):
                    p = rk if isinstance(rk, str) else str(p)
                if p == want or rk == want:
                    found = rk
                    break
            if found:
                keys.append(found)
            else:
                want_s = want if isinstance(want, str) else str(want)
                for rk, rv in all_routes.items():
                    p = rv.get("path") or rk
                    if not isinstance(p, str):
                        continue
                    if p.endswith(want_s.lstrip("/")) or want_s.endswith(p):
                        keys.append(rk)
                        break
    else:
        keys = []

    picked = {}
    for rk in keys:
        rv = all_routes.get(rk)
        if not rv:
            continue
        path = rv.get("path") or rk
        if not isinstance(path, str):
            path = rk if isinstance(rk, str) else str(path)
        cats = rv.get("categories") or []
        if set(cats) <= {"university", "government"}:
            continue
        feat = rv.get("features") or {}
        require_config = feat.get("requireConfig")
        # Feed path template always includes namespace (matches RSSHub examples).
        if path.startswith(f"/{ns}/") or path == f"/{ns}":
            feed_path = path
        else:
            feed_path = f"/{ns}{path if path.startswith('/') else '/' + path}"
        # Keep radar source patterns short (first 2) for app package size.
        radar_raw = rv.get("radar") or []
        radar = []
        for item in radar_raw[:2]:
            if isinstance(item, dict):
                radar.append(
                    {
                        "source": item.get("source"),
                        "target": item.get("target"),
                    }
                )
        picked[feed_path] = {
            "id": f"{ns}:{feed_path}",
            "path": feed_path,
            "routePath": path,
            "name": rv.get("name") or path,
            "example": rv.get("example"),
            "categories": cats,
            "parameters": _normalize_params(path, rv.get("parameters")),
            "radar": radar,
            "requireConfig": bool(require_config)
            if not isinstance(require_config, list)
            else True,
            "antiCrawler": bool(feat.get("antiCrawler")),
            "docsUrl": f"https://docs.rsshub.app/zh/routes/{ns}",
        }
    return picked


def build_catalog(routes_root: dict) -> dict:
    sources = []
    for ns, meta in CURATED.items():
        if not meta:
            continue
        if ns not in routes_root:
            print(f"skip missing namespace: {ns}")
            continue
        ns_data = routes_root[ns]
        selector = meta["routes"]
        picked = _pick_routes(ns, ns_data, selector)
        if not picked:
            print(f"skip empty routes: {ns}")
            continue
        sources.append(
            {
                "namespace": ns,
                "name": ns_data.get("name") or ns,
                "siteUrl": ns_data.get("url"),
                "priority": meta.get("priority", 999),
                "icon": meta.get("icon", ns),
                "blurb": meta.get("blurb", ""),
                "docsUrl": f"https://docs.rsshub.app/zh/routes/{ns}",
                "routes": list(picked.values()),
            }
        )
    sources.sort(key=lambda s: s["priority"])
    return {
        "version": 1,
        "updated": "2026-07-18",
        "sourcesNote": (
            "精选热门命名空间与常用路由，排除高校/政府等长尾。"
            "完整列表见 https://docs.rsshub.app/zh/routes/ ；"
            "实例列表见 https://docs.rsshub.app/zh/guide/instances 。"
            "路由元数据源自 RSSHub-Docs routes.json。"
        ),
        "urlTemplate": "{instance}{pathWithParams}",
        "pathNotes": (
            "最终订阅 URL = 实例 origin + 路由 path（已替换参数）。"
            "例如 instance=https://rsshub.rssforever.com + path=/bilibili/user/video/2267573"
        ),
        "instances": INSTANCES,
        "sources": sources,
    }


def render_md(catalog: dict) -> str:
    lines = [
        "# WEPSEED · RSSHub 雷达数据说明",
        "",
        "> 精选版。完整路由以 [docs.rsshub.app/zh/routes](https://docs.rsshub.app/zh/routes/) 为准；",
        "> 公共实例以 [instances](https://docs.rsshub.app/zh/guide/instances) 为准。",
        ">",
        f"> 机器可读目录：`assets/rsshub/radar_catalog.json`（version {catalog['version']} · {catalog['updated']}）",
        "",
        "---",
        "",
        "## 0. 产品用法（雷达三步）",
        "",
        "1. **选实例** `instance`（可测连通：`GET {instance}/healthz` 或任意已知路由）",
        "2. **选内容来源** `namespace`（如 bilibili / youtube / telegram）",
        "3. **选路由并填表** 替换 path 中的 `:param` → 得到订阅 URL → `addFeed`",
        "",
        "```text",
        "订阅 URL = {instance}{path}",
        "例: https://rsshub.rssforever.com/telegram/channel/awesomeRSSHub",
        "```",
        "",
        "草稿自动保存建议字段：`instanceId`, `namespace`, `routePath`, `params{}`, `builtUrl`, `updatedAt`。",
        "",
        "---",
        "",
        "## 1. 精选原则",
        "",
        "| 收 | 不收 |",
        "|----|------|",
        "| 主流社媒 / 视频 / 科技媒体 / 开发者 / 播客 / 电商好价 / 常见外媒 | 高校通知、地方政府、极小众站 |",
        "| 每源只保留高频路由（投稿/动态/频道/Release…） | 同一源下生僻子路由海 |",
        "| 标注 `requireConfig` / `antiCrawler` 风险 | 假装所有公网实例都能用 |",
        "",
        "完整 1600+ namespace 不进 app 包体；需要时用户仍可 **手动粘贴完整 RSSHub URL**。",
        "",
        "---",
        "",
        "## 2. 实例（Instances）",
        "",
        "官方列表来源：`InstanceList.vue`（[RSSHub-Docs](https://github.com/DIYgod/RSSHub-Docs)）。",
        "状态会变：添加前应用内「测试」应对 `{instance}` 发起探测。",
        "",
        "| ID | URL | 备注 |",
        "|----|-----|------|",
    ]
    for ins in catalog["instances"]:
        note = ins.get("notes") or ("官方" if ins.get("official") else "")
        lines.append(f"| `{ins['id']}` | {ins['url']} | {note} |")
    lines += [
        "",
        "**说明**",
        "",
        "- `rsshub.app` 在部分网络返回 403，真机应允许换实例。",
        "- 同一路由在不同实例上成功率不同（B 站反爬尤甚）。",
        "- 用户可自定义实例 URL（雷达里「自定义」）。",
        "",
        "---",
        "",
        "## 3. 内容来源与路由（精选）",
        "",
        f"共 **{len(catalog['sources'])}** 个来源，路由明细以 JSON 为准；下表为摘要。",
        "",
    ]
    for src in catalog["sources"]:
        lines.append(f"### {src['name']} (`{src['namespace']}`)")
        lines.append("")
        if src.get("blurb"):
            lines.append(src["blurb"])
            lines.append("")
        lines.append(f"文档：{src['docsUrl']}")
        lines.append("")
        lines.append("| 路由 | 名称 | 示例 | 必填参数 | 风险 |")
        lines.append("|------|------|------|----------|------|")
        for rt in src["routes"]:
            req = [
                k
                for k, v in (rt.get("parameters") or {}).items()
                if v.get("required")
            ]
            risk = []
            if rt.get("requireConfig"):
                risk.append("需配置")
            if rt.get("antiCrawler"):
                risk.append("反爬")
            risk_s = ",".join(risk) if risk else "-"
            ex = rt.get("example") or "-"
            lines.append(
                f"| `{rt['path']}` | {rt['name']} | `{ex}` | {', '.join(req) if req else '-'} | {risk_s} |"
            )
        lines.append("")
    lines += [
        "---",
        "",
        "## 4. 表单字段模型（给 UI / 草稿）",
        "",
        "```json",
        "{",
        '  "instanceId": "rssforever",',
        '  "instanceUrl": "https://rsshub.rssforever.com",',
        '  "namespace": "bilibili",',
        '  "routePath": "/user/video/:uid/:embed?",',
        '  "params": { "uid": "2267573", "embed": "" },',
        '  "builtUrl": "https://rsshub.rssforever.com/bilibili/user/video/2267573"',
        "}",
        "```",
        "",
        "拼 URL 规则：",
        "",
        "1. 用 `params` 替换 path 中 `:name` / `:name?`；空可选段及其 `/` 删掉。",
        "2. 前置 namespace：RSSHub 的 example 通常已含 namespace（如 `/bilibili/user/video/2267573`）。",
        "   以 `route.example` 与 `route.path` 为准——**订阅 path = example 的模式，参数替换后不以 namespace 再拼一层。**",
        "3. `builtUrl = instanceUrl.rstrip('/') + '/' + path.lstrip('/')`（若 path 已以 namespace 开头则不要重复）。",
        "",
        "参数 schema（来自 JSON `parameters`）：",
        "",
        "| 字段 | 含义 |",
        "|------|------|",
        "| `description` | 表单 label / hint |",
        "| `default` | 默认值，可空 |",
        "| `required` | 是否必填 |",
        "| `options` | 枚举（如下拉），可空 |",
        "",
        "---",
        "",
        "## 5. 应用内能力对照",
        "",
        "| 能力 | 说明 |",
        "|------|------|",
        "| 测试 | HEAD/GET 实例 healthz 或 builtUrl，展示状态码与是否像 feed |",
        "| 添加 | `builtUrl` → 现有 `FeedRepository.addFeed` |",
        "| 草稿 | 本地持久化未提交表单（SharedPreferences / Drift settings） |",
        "| 关闭入口 | 设置项 `showExploreTab`（默认 true） |",
        "",
        "---",
        "",
        "## 6. 维护",
        "",
        "- 上游：`https://raw.githubusercontent.com/DIYgod/RSSHub-Docs/main/src/public/routes.json`",
        "- 重建脚本：`docs/_build_radar_catalog.py`（需本地 `_routes_raw.json`）",
        "- 增删来源：改脚本内 `CURATED` 后重跑",
        "- **不要**把完整 routes.json（数 MB）打进 APK",
        "",
        "---",
        "",
        "## 7. 非目标（本精选明确不做）",
        "",
        "- 高校 / 政府 / 小众地域站全量收录",
        "- 依赖 Folo 云 trending / AGPL 客户端代码",
        "- 把 RSSHub 实例稳定性担保写进产品承诺",
        "",
        "*数据用于 WEPSEED 雷达；RSSHub 商标与路由归原项目。*",
        "",
    ]
    return "\n".join(lines)


def main() -> None:
    if not RAW.exists():
        raise SystemExit(f"missing {RAW}; download routes.json first")
    routes_root = json.loads(RAW.read_text(encoding="utf-8-sig"))
    # remove placeholder
    CURATED.pop("github-trending-only", None)
    catalog = build_catalog(routes_root)
    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    OUT_DOC.write_text(render_md(catalog), encoding="utf-8")
    n_routes = sum(len(s["routes"]) for s in catalog["sources"])
    print(f"sources={len(catalog['sources'])} routes={n_routes}")
    print(f"wrote {OUT_JSON}")
    print(f"wrote {OUT_DOC}")
    print(f"json bytes={OUT_JSON.stat().st_size}")


if __name__ == "__main__":
    main()
