import SwiftUI
import WebKit

struct WebExperienceView: View {
    var onDismiss: (() -> Void)?
    private let url: URL
    @State private var isLoading = true
    @State private var reloadID = UUID()

    init(url: URL = WebExperienceView.defaultURL, onDismiss: (() -> Void)? = nil) {
        self.url = url
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WebExperienceContainer(url: url, reloadID: reloadID, isLoading: $isLoading)
                    .ignoresSafeArea(.all, edges: .bottom)

                if isLoading {
                    ProgressView("Loading experience…")
                        .padding(16)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .navigationTitle("Virtual Lookbook")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if let onDismiss {
                        Button("Done", action: onDismiss)
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        reloadID = UUID()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

private extension WebExperienceView {
    static var defaultURL: URL {
        if let bundled = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "WebExperience") {
            return bundled
        }
        return URL(string: "https://review-n-zip.lovable.app")!
    }
}

private struct WebExperienceContainer: UIViewRepresentable {
    let url: URL
    let reloadID: UUID
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        context.coordinator.lastLoadedID = reloadID
        load(in: webView)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard context.coordinator.lastLoadedID != reloadID else { return }
        context.coordinator.lastLoadedID = reloadID
        load(in: uiView)
    }

    private func load(in webView: WKWebView) {
        isLoading = true
        if url.isFileURL {
            let directory = url.deletingLastPathComponent()
            webView.loadFileURL(url, allowingReadAccessTo: directory)
        } else {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            webView.load(request)
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        var lastLoadedID = UUID()

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}

#Preview {
    WebExperienceView(url: URL(string: "https://apple.com")!)
}
