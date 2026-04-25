import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let errorView = UIView()
    private let errorTitleLabel = UILabel()
    private let errorDetailLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let refreshControl = UIRefreshControl()
    private var progressObservation: NSKeyValueObservation?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.965, green: 0.979, blue: 1.0, alpha: 1.0)
        view.clipsToBounds = true

        configureWebView()
        configureProgressView()
        configureErrorView()
        loadHomePage()
    }

    deinit {
        progressObservation?.invalidate()
    }

    private func makeWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }

        let userContentController = WKUserContentController()
        userContentController.addUserScript(WKUserScript(
            source: viewportFitScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        ))
        userContentController.addUserScript(WKUserScript(
            source: immersiveShellStyleScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        ))

        if AppConfig.hideCommonFloatingAdSelectors {
            userContentController.addUserScript(WKUserScript(
                source: hideFloatingAdScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            ))
        }

        configuration.userContentController = userContentController
        return configuration
    }

    private func configureWebView() {
        webView = WKWebView(frame: .zero, configuration: makeWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = UIColor(red: 0.965, green: 0.979, blue: 1.0, alpha: 1.0)
        webView.isOpaque = false
        webView.scrollView.bounces = true
        webView.scrollView.keyboardDismissMode = .interactive
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInset = .zero
        webView.scrollView.scrollIndicatorInsets = .zero
        webView.scrollView.verticalScrollIndicatorInsets = .zero
        webView.scrollView.horizontalScrollIndicatorInsets = .zero

        refreshControl.addTarget(self, action: #selector(reloadPage), for: .valueChanged)
        refreshControl.tintColor = .systemBlue
        webView.scrollView.refreshControl = refreshControl

        webView.customUserAgent = defaultUserAgentWithSuffix()

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureProgressView() {
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progress = 0
        progressView.isHidden = true
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])

        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                let progress = Float(webView.estimatedProgress)
                self.progressView.setProgress(progress, animated: true)
                self.progressView.isHidden = progress >= 1.0
                if progress >= 1.0 {
                    self.progressView.setProgress(0, animated: false)
                }
            }
        }
    }

    private func configureErrorView() {
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.backgroundColor = UIColor(red: 0.965, green: 0.979, blue: 1.0, alpha: 1.0)
        errorView.isHidden = true
        view.addSubview(errorView)

        errorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        errorTitleLabel.text = "页面加载失败"
        errorTitleLabel.textAlignment = .center
        errorTitleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        errorTitleLabel.textColor = .label

        errorDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        errorDetailLabel.text = "请检查网络连接后重试"
        errorDetailLabel.textAlignment = .center
        errorDetailLabel.font = .systemFont(ofSize: 15, weight: .regular)
        errorDetailLabel.textColor = .secondaryLabel
        errorDetailLabel.numberOfLines = 0

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("重新加载", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        retryButton.addTarget(self, action: #selector(reloadPage), for: .touchUpInside)

        errorView.addSubview(errorTitleLabel)
        errorView.addSubview(errorDetailLabel)
        errorView.addSubview(retryButton)

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorTitleLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -36),
            errorTitleLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 24),
            errorTitleLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -24),

            errorDetailLabel.topAnchor.constraint(equalTo: errorTitleLabel.bottomAnchor, constant: 10),
            errorDetailLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 28),
            errorDetailLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -28),

            retryButton.topAnchor.constraint(equalTo: errorDetailLabel.bottomAnchor, constant: 22),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    private func defaultUserAgentWithSuffix() -> String? {
        nil
    }

    private func loadHomePage() {
        var request = URLRequest(url: AppConfig.websiteURL)
        request.timeoutInterval = 30
        request.cachePolicy = .useProtocolCachePolicy
        webView.load(request)
    }

    @objc private func reloadPage() {
        hideErrorView()
        if webView.url == nil {
            loadHomePage()
        } else {
            webView.reload()
        }
    }

    private func showErrorView(message: String? = nil) {
        refreshControl.endRefreshing()
        errorDetailLabel.text = message ?? "请检查网络连接后重试"
        errorView.isHidden = false
        view.bringSubviewToFront(errorView)
    }

    private func hideErrorView() {
        errorView.isHidden = true
        view.sendSubviewToBack(errorView)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        hideErrorView()
        progressView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideErrorView()
        refreshControl.endRefreshing()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        let scheme = url.scheme?.lowercased() ?? ""
        if ["tel", "mailto", "sms"].contains(scheme) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    private func handleNavigationError(_ error: Error) {
        let nsError = error as NSError
        if nsError.code == NSURLErrorCancelled { return }
        showErrorView(message: nsError.localizedDescription)
    }

    // MARK: - WKUIDelegate

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    // MARK: - Injected JS

    private var viewportFitScript: String {
        """
        (function() {
          var meta = document.querySelector('meta[name="viewport"]');
          if (!meta) {
            meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, viewport-fit=cover';
            document.head.appendChild(meta);
          } else {
            var content = meta.getAttribute('content') || '';
            if (content.indexOf('viewport-fit=cover') === -1) {
              meta.setAttribute('content', content ? content + ', viewport-fit=cover' : 'width=device-width, initial-scale=1.0, viewport-fit=cover');
            }
          }
        })();
        """
    }

    private var immersiveShellStyleScript: String {
        """
        (function() {
          var css = `
            html {
              background: #f6f9ff !important;
            }
            html, body {
              width: 100% !important;
              min-height: 100% !important;
              margin: 0 !important;
              background: #f6f9ff !important;
              overscroll-behavior-y: auto;
            }
            body.emby-ios-shell-safe-area {
              box-sizing: border-box;
              padding-top: max(env(safe-area-inset-top), 0px);
              padding-bottom: max(env(safe-area-inset-bottom), 0px);
              padding-left: max(env(safe-area-inset-left), 0px);
              padding-right: max(env(safe-area-inset-right), 0px);
            }
          `;
          var style = document.createElement('style');
          style.setAttribute('data-emby-ios-shell-style', 'true');
          style.textContent = css;
          document.documentElement.appendChild(style);

          function applySafeArea() {
            if (document.body && !document.body.classList.contains('emby-ios-shell-safe-area')) {
              document.body.classList.add('emby-ios-shell-safe-area');
            }
          }

          if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', applySafeArea, { once: true });
          } else {
            applySafeArea();
          }
        })();
        """
    }

    private var hideFloatingAdScript: String {
        """
        (function() {
          var css = `
            .float-ad,
            #float-ad,
            .floating-ad,
            .floating-ads,
            .corner-ad,
            .right-bottom-ad,
            .fixed-ad,
            .ad-float,
            .ad-floating,
            .adsbygoogle,
            [class*="float"][class*="ad"],
            [id*="float"][id*="ad"],
            [class*="ad"][class*="fixed"],
            [id*="ad"][id*="fixed"] {
              display: none !important;
              opacity: 0 !important;
              visibility: hidden !important;
              pointer-events: none !important;
            }
          `;
          var style = document.createElement('style');
          style.setAttribute('data-emby-ios-hide-floating-ad', 'true');
          style.textContent = css;
          document.documentElement.appendChild(style);
        })();
        """
    }
}
