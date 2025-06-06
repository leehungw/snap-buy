import SwiftUI
import PayPal
import Foundation

struct SBUpgradeAccountView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessSheet = false
    var body: some View {
        
        VStack(spacing: 6) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            AutoImageCarouselView(images: ["up_1", "up_2", "up_3"])
            
            Text("Upgrade Account")
                .font(R.font.outfitBold.font(size: 24))
            
            Text("Become a seller to start your business and reach thousands of customers.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .font(R.font.outfitRegular.font(size: 14))
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                Label("Create and manage your own store", systemImage: "building.2")
                Label("Track your sales and performance", systemImage: "chart.line.uptrend.xyaxis")
                Label("Easily manage orders and shipping", systemImage: "shippingbox")
                Label("Chat directly with customers", systemImage: "message")
                Label("Verified and secure seller system", systemImage: "lock.shield")
            }
            .font(R.font.outfitRegular.font(size: 14))
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            
            Spacer()
            
            // Outstanding price label
            Text("$99.00")
                .font(R.font.outfitBold.font(size: 32))
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 32)
                .background(Color.main)
                .cornerRadius(20)
                .shadow(color: Color.main.opacity(0.3), radius: 10, x: 0, y: 4)
                .padding(.bottom, 8)
            
            Button(action: {
                Task {
                    isLoading = true
                    alertMessage = ""
                    do {
                        let orderId = try await SBPaypalService.shared.createAdminUpgradeOrder(amount: 99.0)
                        // Start PayPal checkout
                        let request = PayPalWebCheckoutRequest(orderID: orderId, fundingSource: .paypal)
                        let _ = try await SBPaypalService.shared.payPalClient.start(request: request)
                        // Capture the payment with admin access token
                        try await SBPaypalService.shared.captureAdminOrder(orderId: orderId)
                        // Call goPremium endpoint
                        if let userId = UserRepository.shared.currentUser?.id {
                            let urlString = "\(SBAppConstant.apiBaseURL)/user/api/users/goPremium/\(userId)"
                            guard let url = URL(string: urlString) else { throw NSError(domain: "Upgrade", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]) }
                            var request = URLRequest(url: url)
                            request.httpMethod = "PUT"
                            let (data, response) = try await URLSession.shared.data(for: request)
                            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                                throw NSError(domain: "Upgrade", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to upgrade account"]) }
                            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let result = json["result"] as? Int, result == 1 {
                                isLoading = false
                                showSuccessSheet = true
                            } else {
                                isLoading = false
                                alertMessage = "Something went wrong. Please contact support."
                                showAlert = true
                            }
                        } else {
                            isLoading = false
                            alertMessage = "User not found. Please log in again."
                            showAlert = true
                        }
                    } catch {
                        isLoading = false
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            }) {
                Text("Upgrade Now")
                    .font(R.font.outfitSemiBold.font(size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.main)
                    .cornerRadius(30)
            }
            .padding(.horizontal)
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1.0)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Upgrade Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showSuccessSheet) {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.seal.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                    Text("Congratulations!")
                        .font(R.font.outfitBold.font(size: 28))
                    Text("You have successfully upgraded to a premium seller.")
                        .font(R.font.outfitRegular.font(size: 18))
                        .multilineTextAlignment(.center)
                    Button("Done") {
                        showSuccessSheet = false
                        if let userId = UserRepository.shared.currentUser?.id {
                            UserRepository.shared.fetchUserById(userId: userId) { result in
                                switch result {
                                case .success(let userData):
                                    UserRepository.shared.currentUser = userData
                                case .failure:
                                    break
                                }
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }
                    .font(R.font.outfitBold.font(size: 18))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                .padding()
            }
            
            if isLoading {
                ProgressView("Processing...")
                    .padding()
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

struct AutoImageCarouselView: View {
    let images: [String]
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(images.indices, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 350)
                    .cornerRadius(20)
                    .padding()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 380)
        .onAppear {
            startAutoScroll()
        }
    }

    func startAutoScroll() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % images.count
            }
        }
    }
}

#Preview {
    SBUpgradeAccountView()
}
