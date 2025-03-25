import SwiftUI

struct BannerCarouselView: View {
    let banners: [Banner]
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(banners.enumerated()), id: \.offset) { index, banner in
                BannerView(banner: banner)
                    .tag(index)
                    .padding(.horizontal)
            }
        }
        .frame(height: 160)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        .onReceive(timer) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % banners.count
            }
        }
    }
}
