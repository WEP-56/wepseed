# WEPSEED

Local-first RSS reader for Android (Flutter).  
刷订阅流 · 源主页 · 详情互动 · LLM 网友评论 · 个人时间轴 · 后台刷新通知。

## 状态

见 [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md)（Phase A–E 主路径已接）。

## 本地运行

```bash
flutter pub get
flutter run -d <device>
```

### Release APK（按 ABI 分包，体积更小）

```bash
# 三份：armeabi-v7a / arm64-v8a / x86_64
flutter build apk --release --split-per-abi

# 产物
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk   ← 真机首选
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

不要用无 `--split-per-abi` 的 fat APK（会把多 ABI 的 so 打进一个包，体积大很多）。

### 签名（可选，发正式包前建议配置）

```bash
# 1) 生成上传密钥（只做一次，妥善备份）
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 2) 配置（复制示例后填写；key.properties 已 gitignore）
cp android/key.properties.example android/key.properties
```

未配置时 release 回退 debug 签名，便于本地 `flutter run --release`。

## GitHub Release（tag 驱动）

仓库已配置 [`.github/workflows/release.yml`](.github/workflows/release.yml)：

1. 推送 tag：`git tag v1.6.0 && git push origin v1.6.0`
2. Action 执行 `flutter build apk --release --split-per-abi`
3. 自动创建 GitHub Release，挂上：
   - `wepseed-<ver>-arm64-v8a.apk`
   - `wepseed-<ver>-armeabi-v7a.apk`
   - `wepseed-<ver>-x86_64.apk`

正式签名（生成 keystore、填 Secrets、打 tag）的**完整私密步骤**见本机：

`docs/SIGNING.private.md`（已 gitignore，不进仓库）

公开 Secrets 名（值只写 GitHub Actions secrets）：`KEYSTORE_BASE64` · `KEYSTORE_PASSWORD` · `KEY_PASSWORD` · `KEY_ALIAS`。

未配置 secrets 时仍会出包，但为 **debug 签名**（仅内测）。

## 文档

- **[功能实现文档](docs/IMPLEMENTATION.md)** — 规格、模块、交接

## 许可证

[MIT](LICENSE)
