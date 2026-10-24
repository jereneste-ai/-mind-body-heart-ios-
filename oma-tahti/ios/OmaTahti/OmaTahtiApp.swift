import SwiftUI
import WebKit
import UIKit

@main
struct AlwaysKindlyHyvinnApp: App {
    var body: some Scene {
        WindowGroup {
            BrowserScreen()
        }
    }
}

struct BrowserScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BrowserController {
        BrowserController()
    }

    func updateUIViewController(_ uiViewController: BrowserController, context: Context) {}
}

final class BrowserController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    private var web: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "nativeExport")
        web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        web.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(web)

        NSLayoutConstraint.activate([
            web.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            web.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            web.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            showError("Always Kindly × Hyvinn content is missing.")
        }
    }

    func showError(_ text: String) {
        let alert = UIAlertController(title: "Always Kindly × Hyvinn", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "nativeExport", message.frameInfo.isMainFrame,
              message.frameInfo.request.url?.isFileURL == true else { return }

        web.evaluateJavaScript("JSON.stringify(state, null, 2)") { [weak self] value, error in
            guard let self = self, let text = value as? String, error == nil else {
                self?.showError("Export failed.")
                return
            }

            do {
                let url = FileManager.default.temporaryDirectory.appendingPathComponent("always-kindly-hyvinn-export.json")
                try text.write(to: url, atomically: true, encoding: .utf8)
                let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                share.popoverPresentationController?.sourceView = self.view
                share.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 1, height: 1)
                share.completionWithItemsHandler = { _, _, _, _ in
                    try? FileManager.default.removeItem(at: url)
                }
                self.present(share, animated: true)
            } catch {
                self.showError("Export failed.")
            }
        }
    }

    func external(_ url: URL) {
        guard ["https", "tel", "mailto"].contains(url.scheme?.lowercased() ?? "") else { return }
        UIApplication.shared.open(url)
    }

    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.isFileURL {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            external(url)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            external(url)
        }
        return nil
    }
}
