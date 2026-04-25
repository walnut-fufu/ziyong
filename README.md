# Emby影视库 iOS IPA 云打包工程 v4

这是用于 GitHub Actions 云端生成未签名 iOS IPA 的工程。App 内部使用原生 Swift + WKWebView 加载：

```text
https://wiki.emby10086.xyz
```

## v4 修复内容

- 修复 WebView 上下白边，改成全屏沉浸式布局。
- 新增完整 AppIcon.appiconset。
- 在 `project.yml` 中指定：
  - `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon`
  - `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor`
- 在 GitHub Actions 里新增 `Force bundle app icons` 步骤，直接把 AppIcon PNG 文件复制进 `.app`，并强制写入 `Info.plist` 的 `CFBundleIcons` / `CFBundleIcons~ipad`。
- 打包前会在日志里打印 `.app` 内部的 AppIcon 文件，方便判断图标是否真的进包。

## 使用方法

1. 新建或清空一个 GitHub 仓库。
2. 把本工程所有文件上传到仓库根目录。
3. 确保仓库里只保留：

```text
.github/workflows/ios.yml
```

不要再运行 `ios1.yml`、`iOS starter workflow` 或其他旧工作流。

4. 打开 GitHub 仓库 `Actions`。
5. 选择 `Build unsigned iOS IPA`。
6. 点击 `Run workflow`。
7. 完成后在 `Artifacts` 下载：

```text
EmbyWikiWebView-unsigned-ipa
```

8. 解压得到：

```text
EmbyWikiWebView-unsigned.ipa
```

9. 用你自己的自签工具签名安装。

## 如果还是没有图标

优先检查 GitHub Actions 日志中的这一步：

```text
Force bundle app icons
```

正常情况下，日志里必须出现类似：

```text
AppIcon60x60@2x.png
AppIcon60x60@3x.png
AppIcon76x76@2x~ipad.png
AppIcon83.5x83.5@2x~ipad.png
```

如果这些文件没有出现，说明你运行的不是本工程里的 `ios.yml`，或者仓库里旧工作流还没删干净。

## 安装后图标仍旧不变

iOS 可能缓存旧图标。处理方式：

1. 删除旧 App。
2. 重新签名安装新版 IPA。
3. 必要时重启手机。
