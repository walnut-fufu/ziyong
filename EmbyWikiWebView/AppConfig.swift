import Foundation

/// App 基础配置：后续只需要改这里即可。
enum AppConfig {
    /// 你的网页入口地址。
    static let websiteURL = URL(string: "https://wiki.emby10086.xyz")!

    /// 是否隐藏常见的右下角悬浮广告/悬浮挂件。
    /// 如果误伤网页里的正常按钮，把这里改成 false 后重新打包。
    static let hideCommonFloatingAdSelectors = true

    /// 自定义 User-Agent 后缀，方便后端识别来自 iOS 壳 App 的访问。
    static let userAgentSuffix = " EmbyWikiIOS/1.0.0"
}
