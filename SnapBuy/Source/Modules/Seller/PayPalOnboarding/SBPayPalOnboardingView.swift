import SwiftUI
import SafariServices

struct SBPayPalOnboardingView: View {
    @StateObject private var userModeManager = UserModeManager.shared
    @State private var showWebView = false
    
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
                
                Text("To start selling on SnapBuy, you need to connect your PayPal account. This will allow you to receive payments from buyers.")
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
                        showWebView = true
                    }
                }) {
                    HStack {
                        Image(systemName: "link")
                        Text("Connect PayPal Account")
                    }
                    .font(R.font.outfitMedium.font(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .disabled(userModeManager.paypalOnboardingURL == nil)
            }
        }
        .sheet(isPresented: $showWebView) {
            if let urlString = userModeManager.paypalOnboardingURL,
               let url = URL(string: urlString) {
                SafariView(url: url)
            }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
} 