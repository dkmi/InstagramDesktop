import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        InstagramWebView()
            .frame(minWidth: 720, minHeight: 520)
    }
}

private struct InstagramWebView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsMagnification = true
        context.coordinator.webView = webView

        if let url = URL(string: "https://www.instagram.com/") {
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            let scheme = url.scheme?.lowercased()

            // Instagram/WebKit use these internally. They must remain inside
            // the web view instead of being sent to macOS as external URLs.
            if scheme == "about" || scheme == "blob" || scheme == "data" {
                decisionHandler(.allow)
                return
            }

            if scheme == "http" || scheme == "https" {
                decisionHandler(.allow)
                return
            }

            // Open only genuine external app links (for example mailto:).
            if let scheme, ["mailto", "tel"].contains(scheme) {
                NSWorkspace.shared.open(url)
            }

            decisionHandler(.cancel)
        }
    }
}
