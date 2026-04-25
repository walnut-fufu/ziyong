# Emby影视库 iOS WebView IPA 云打包工程

这是一个极简 iOS 原生 Swift + WKWebView 壳工程，用来把下面网页封装成 iPhone / iPad 可用的 IPA：

```text
https://wiki.emby10086.xyz
```

本工程默认生成的是 **未签名 IPA**，适合你后续用自己的自签工具、P12 证书、描述文件去签名安装。

---

## 已配置内容

```text
App 名称：Emby影视库
Bundle ID：com.walnut.emby10086wiki
网页入口：https://wiki.emby10086.xyz
最低系统：iOS 13+
支持设备：iPhone + iPad
屏幕方向：竖屏 + 横屏
核心技术：原生 Swift + WKWebView
输出文件：EmbyWikiWebView-unsigned.ipa
```

已处理：

```text
1. iPhone / iPad 设备适配
2. 刘海屏、安全区、圆角屏、Home Indicator 区域适配
3. 横竖屏支持
4. HTTPS 网页加载
5. 下拉刷新
6. 网页加载失败错误页
7. target="_blank" / 新窗口链接在当前 WebView 打开
8. WebView 自带左右滑动返回网页历史
9. 常见右下角悬浮广告/悬浮按钮隐藏脚本
10. GitHub Actions 云端自动生成未签名 IPA
```

---

## 最简单使用方法：GitHub Actions 免费云编译

### 第 1 步：新建 GitHub 仓库

新建一个公开仓库，例如：

```text
emby-ios-webview
```

公开仓库更省事，GitHub Actions 通常不用额外付费。

### 第 2 步：上传本工程所有文件

把这个压缩包解压后，把里面所有文件上传到仓库根目录。

必须包含这些文件：

```text
.github/workflows/build-ios-unsigned-ipa.yml
EmbyWikiWebView/AppConfig.swift
EmbyWikiWebView/AppDelegate.swift
EmbyWikiWebView/SceneDelegate.swift
EmbyWikiWebView/ViewController.swift
EmbyWikiWebView/Info.plist
EmbyWikiWebView/Base.lproj/LaunchScreen.storyboard
project.yml
```

### 第 3 步：运行云打包

进入 GitHub 仓库：

```text
Actions
↓
Build unsigned iOS IPA
↓
Run workflow
↓
Run workflow
```

等待几分钟。

### 第 4 步：下载 IPA

打包完成后：

```text
Actions
↓
点进刚刚成功的任务
↓
页面底部 Artifacts
↓
下载 EmbyWikiWebView-unsigned-ipa
```

下载后解压，会得到：

```text
EmbyWikiWebView-unsigned.ipa
```

这个就是未签名 IPA。你再用轻松签、ESign、Sideloadly、AltStore 等工具自签安装。

---

## 自签安装说明

本工程生成的是未签名 IPA，不内置你的证书，也不会要求你把 P12 密码上传到 GitHub。

你拿到 IPA 后再本地签名：

```text
1. 打开你的自签工具
2. 导入 EmbyWikiWebView-unsigned.ipa
3. 选择你的 p12 证书
4. 输入 p12 密码
5. 选择对应 mobileprovision
6. 签名
7. 安装到 iPhone / iPad
```

如果你的自签工具支持自动注入 mobileprovision，就按工具自己的流程走。

---

## 修改网页地址

打开：

```text
EmbyWikiWebView/AppConfig.swift
```

修改这一行：

```swift
static let websiteURL = URL(string: "https://wiki.emby10086.xyz")!
```

---

## 修改 Bundle ID

打开：

```text
project.yml
```

修改：

```yaml
PRODUCT_BUNDLE_IDENTIFIER: com.walnut.emby10086wiki
```

如果你自签工具会二次改 Bundle ID，这里也可以保持默认。

---

## 修改 App 名称

打开：

```text
EmbyWikiWebView/Info.plist
```

修改：

```xml
<key>CFBundleDisplayName</key>
<string>Emby影视库</string>
```

---

## 关闭右下角悬浮广告隐藏脚本

本工程默认会注入 CSS，隐藏常见的右下角悬浮广告 / 浮动按钮。

如果发现误伤了网页内正常功能，打开：

```text
EmbyWikiWebView/AppConfig.swift
```

把：

```swift
static let hideCommonFloatingAdSelectors = true
```

改成：

```swift
static let hideCommonFloatingAdSelectors = false
```

然后重新运行 GitHub Actions 打包。

---

## 替换图标

当前工程没有强制配置 AppIcon，避免云编译因为图标尺寸不规范失败。

如果你需要正式图标，建议后续用 Xcode 或在线 AppIcon 工具生成完整 `AppIcon.appiconset`，再在 `project.yml` 里增加：

```yaml
ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
```

自签自用阶段，不换图标也能先测试网页壳功能。

---

## 常见问题

### 1. 为什么不是直接签好的 IPA？

因为你要自己自签安装，所以这个工程只生成未签名 IPA。这样不用上传你的 P12、密码和描述文件。

### 2. iPhone 和 iPad 都能用吗？

能。工程里已经设置：

```yaml
TARGETED_DEVICE_FAMILY: "1,2"
```

其中：

```text
1 = iPhone
2 = iPad
```

### 3. 横屏可以吗？

可以。`Info.plist` 已经配置 iPhone 和 iPad 的横竖屏方向。

### 4. 网页内部如果不适配手机怎么办？

壳工程只能保证 App 容器层适配手机、平板、安全区和横竖屏。网页内部排版仍取决于 `https://wiki.emby10086.xyz` 自身的响应式设计。

### 5. GitHub Actions 报 xcodegen 找不到怎么办？

工作流里已经写了：

```bash
brew install xcodegen
```

正常情况下会自动安装。

### 6. 打出来的 IPA 装不上怎么办？

未签名 IPA 不能直接安装。必须先用你的自签工具签名，再安装到设备。

---

## 文件结构

```text
.
├── .github
│   └── workflows
│       └── build-ios-unsigned-ipa.yml
├── EmbyWikiWebView
│   ├── AppConfig.swift
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift
│   ├── Info.plist
│   ├── Assets.xcassets
│   └── Base.lproj
│       └── LaunchScreen.storyboard
├── scripts
│   └── build_unsigned_ipa.sh
├── project.yml
└── README.md
```


## 图标配置说明

本版本已经在 `project.yml` 中显式配置：

```yaml
ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
```

并且已内置 `EmbyWikiWebView/Assets.xcassets/AppIcon.appiconset`，GitHub Actions 构建时会把图标编译进 `.app`。

如果安装后还是显示旧图标，通常是 iOS 或自签工具缓存导致。处理方法：删除旧 App → 重新签名安装；必要时重启设备，或临时换一个 Bundle ID 再安装。
