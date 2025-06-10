import SwiftUI
import WebKit

struct SBPayPalOnboardingView: View {
    @StateObject private var userModeManager = UserModeManager.shared
    @State private var showWebView = false
    @State private var onboardingURL: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if userModeManager.isOnboardingPayPal {
                ProgressView("Setting up PayPal...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if userModeManager.isPayPalConnected {
                Image("img_paypal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                Text("PayPal account connected successfully!")
                    .font(R.font.outfitBold.font(size: 22))
                    .foregroundColor(.green)
                Text("Your PayPal account is connected. You can now receive payments from buyers.")
                    .font(R.font.outfitRegular.font(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                Image("img_paypal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                
                Text("Connect with PayPal")
                    .font(R.font.outfitBold.font(size: 24))
                
                Text("To start selling on SnapBuy, you need to connect your PayPal account. This allows you to receive payments directly from buyers.")
                    .font(R.font.outfitRegular.font(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                if let error = userModeManager.onboardingError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(R.font.outfitRegular.font(size: 14))
                        .padding()
                }
                
                Button(action: {
                    if let url = userModeManager.paypalOnboardingURL {
                        onboardingURL = url
                        showWebView = true
                    }
                }) {
                    HStack {
                        Image("img_paypal")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 25)
                        Text("Connect PayPal Account")
                            .font(R.font.outfitMedium.font(size: 18))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
                .padding(.horizontal)
                .disabled(userModeManager.paypalOnboardingURL == nil)
            }
        }
        .sheet(isPresented: $showWebView) {
            if let url = onboardingURL {
                PayPalWebView(url: url) { success in
                    if success {
                        // Give the UserModeManager time to process the return URL
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showWebView = false
                            dismiss()
                        }
                    } else {
                        showWebView = false
                    }
                }
            }
        }
    }
}

struct PayPalWebView: UIViewControllerRepresentable {
    let url: String
    let onComplete: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> PayPalWebViewController {
        let controller = PayPalWebViewController(url: url, onComplete: onComplete)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PayPalWebViewController, context: Context) {}
}

class PayPalWebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var url: String
    var onComplete: (Bool) -> Void
    private var hasCompletedOnboarding = false
    
    init(url: String, onComplete: @escaping (Bool) -> Void) {
        self.url = url
        self.onComplete = onComplete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        
        if let url = URL(string: url) {
            print("Debug - Loading initial URL: \(url)")
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print("Debug - Navigation URL: \(url)")
            
            // Extract merchant ID from any URL parameters
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let merchantId = components.queryItems?.first(where: { $0.name == "merchantIdInPayPal" })?.value {
                print("Debug - Found merchant ID in URL parameters: \(merchantId)")
                handleMerchantId(merchantId)
                decisionHandler(.allow)
                return
            }
            
            // Check various completion URLs
            let completionIndicators = [
                "unifiedonboarding/after-login",
                "returnToMerchant",
                "setup-complete",
                "onboarding-status"
            ]
            
            if completionIndicators.contains(where: { url.absoluteString.contains($0) }) {
                print("Debug - Found completion URL: \(url)")
                
                // Try to extract merchant ID from the URL path components
                if let merchantId = extractMerchantId(from: url) {
                    print("Debug - Extracted merchant ID from URL: \(merchantId)")
                    handleMerchantId(merchantId)
                } else {
                    // If we can't find the merchant ID, try to get it from the page content
                    webView.evaluateJavaScript("document.body.innerHTML") { result, error in
                        if let html = result as? String {
                            print("Debug - Searching page content for merchant ID")
                            // Look for merchant ID in the HTML content
                            if let merchantId = self.extractMerchantIdFromHTML(html) {
                                print("Debug - Found merchant ID in page content: \(merchantId)")
                                self.handleMerchantId(merchantId)
                            }
                        }
                    }
                }
            }
            
            // Always allow navigation unless we've completed onboarding
            decisionHandler(hasCompletedOnboarding ? .cancel : .allow)
            return
        }
        
        decisionHandler(.allow)
    }
    
    private func extractMerchantId(from url: URL) -> String? {
        // Try different URL patterns
        let patterns = [
            "merchantId=([A-Z0-9]+)",
            "merchant_id=([A-Z0-9]+)",
            "merchantIdInPayPal=([A-Z0-9]+)",
            "/merchant/([A-Z0-9]+)/"
        ]
        
        let urlString = url.absoluteString
        
        for pattern in patterns {
            if let range = urlString.range(of: pattern, options: .regularExpression),
               let match = urlString[range].split(separator: "=").last {
                return String(match)
            }
        }
        
        return nil
    }
    
    private func extractMerchantIdFromHTML(_ html: String) -> String? {
        // Try different patterns that might appear in the HTML
        let patterns = [
            "merchantId\":\\s*\"([A-Z0-9]+)\"",
            "merchant_id\":\\s*\"([A-Z0-9]+)\"",
            "data-merchant-id=\"([A-Z0-9]+)\""
        ]
        
        for pattern in patterns {
            if let range = html.range(of: pattern, options: .regularExpression),
               let match = html[range].split(separator: "\"").last {
                return String(match)
            }
        }
        
        return nil
    }
    
    private func handleMerchantId(_ merchantId: String) {
        guard !hasCompletedOnboarding else { return }
        
        print("Debug - Processing merchant ID: \(merchantId)")
        
        // Try both URL schemes
        let schemes = ["com.ui.se.snapbuy", "snapbuy"]
        for scheme in schemes {
            if let returnUrl = URL(string: "\(scheme)://onboarding-complete?merchantIdInPayPal=\(merchantId)&permissionsGranted=true") {
                print("Debug - Attempting return URL: \(returnUrl)")
                UserModeManager.shared.handlePayPalReturn(url: returnUrl)
                hasCompletedOnboarding = true
                onComplete(true)
                break
            }
        }
    }
} 
