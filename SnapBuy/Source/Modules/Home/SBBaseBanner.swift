import SwiftUI

struct SBBannerView: View {
    let banner: Banner
    
    var body: some View {
        ZStack {
            Image(banner.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.1)]),
                startPoint: .bottom,
                endPoint: .top
            )
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Spacer()
                    Text(banner.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(banner.subtitle)
                        .foregroundColor(.white)
                    Text("By \(banner.storeName)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding()
        }
        .frame(height: 160)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 4)
    }
}
#Preview {
    SBBannerView(banner: .sample3)
}
