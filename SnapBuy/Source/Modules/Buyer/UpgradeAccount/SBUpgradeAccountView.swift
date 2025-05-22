import SwiftUI

struct SBUpgradeAccountView: View {
    @Environment(\.dismiss) var dismiss
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
            
            Button(action: {
                // Upgrade action
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
