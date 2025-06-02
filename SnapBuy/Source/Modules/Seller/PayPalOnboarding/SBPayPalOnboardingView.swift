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
            
            // Check if this is a completion URL
            if url.absoluteString.contains("unifiedonboarding/after-login") {
                print("Debug - Found completion URL")
                
                // Extract merchant ID from the URL if available
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                   let merchantId = components.queryItems?.first(where: { $0.name == "merchantIdInPayPal" })?.value {
                    print("Debug - Found merchant ID: \(merchantId)")
                    
                    // Create the return URL with the merchant ID
                    let returnUrl = URL(string: "snapbuy://return?merchantIdInPayPal=\(merchantId)&permissionsGranted=true")!
                    UserModeManager.shared.handlePayPalReturn(url: returnUrl)
                    hasCompletedOnboarding = true
                    onComplete(true)
                    decisionHandler(.allow)
                    return
                }
                
                // If we don't have a merchant ID yet, continue loading
                decisionHandler(.allow)
                return
            }
            
            // Check for PayPal's success page indicators
            if url.absoluteString.contains("returnToMerchant") || 
               url.absoluteString.contains("setup-complete") {
                print("Debug - Found success page")
                
                // If we haven't processed a return URL yet, this might be it
                if !hasCompletedOnboarding {
                    // Look for merchant ID in the URL
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                       let merchantId = components.queryItems?.first(where: { $0.name == "merchantIdInPayPal" })?.value {
                        print("Debug - Found merchant ID on success page: \(merchantId)")
                        
                        let returnUrl = URL(string: "snapbuy://return?merchantIdInPayPal=\(merchantId)&permissionsGranted=true")!
                        UserModeManager.shared.handlePayPalReturn(url: returnUrl)
                        hasCompletedOnboarding = true
                        onComplete(true)
                        decisionHandler(.cancel)
                        return
                    }
                }
            }
        }
        
        decisionHandler(.allow)
    }
} 
