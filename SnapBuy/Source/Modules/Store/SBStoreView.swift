import SwiftUI

enum StoreTab: String, CaseIterable {
    case main = "Mainpage"
    case allProducts = "All Products"
    case bestSellers = "Best Sellers"
}

struct SBStoreView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: StoreTab = .main

    var body: some View {
        SBBaseView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                    Text(R.string.localizable.store())
                        .font(R.font.outfitRegular.font(size: 16))
                    Spacer()
                    Image(systemName: "bag")
                        .font(.title2)
                        .foregroundColor(Color.black)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

                // Store Info
                HStack {
                    Image(systemName: "cube.box")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(24)
                        .padding(.trailing, 10)

                    VStack(alignment: .leading) {
                        HStack {
                            Text(R.string.localizable.upboxBag())
                                .font(R.font.outfitBold.font(size: 16))
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(Color.main)
                                .font(.caption)
                        }

                        Text(R.string.localizable.storeStatsFormat("104", "1.3k"))
                            .font(R.font.outfitRegular.font(size: 12))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: {}) {
                        Text(R.string.localizable.follow())
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.main)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

                // Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(StoreTab.allCases, id: \.self) { tab in
                            VStack {
                                Text(NSLocalizedString(tab.rawValue, comment: ""))
                                    .font(R.font.outfitMedium.font(size: 16))
                                    .foregroundColor(selectedTab == tab ? .black : .gray)

                                Divider()
                                    .frame(width: 100, height: 2)
                                    .background(Color.main)
                                    .opacity(selectedTab == tab ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                            }
                            .padding(.trailing, 40)
                            .onTapGesture {
                                selectedTab = tab
                            }

                            if tab != StoreTab.allCases.last {
                                Spacer()
                            }
                        }
                    }
                    .padding(.leading, 50)
                }

                // Content
                ScrollView {
                    Group {
                        switch selectedTab {
                        case .main:
                            MainView()
                        case .allProducts:
                            AllProductsView()
                        case .bestSellers:
                            BestSellersView()
                        }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                }
            }
            .padding(.top)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct MainView: View {
    var body: some View {
        VStack {
            SBBannerCarouselView(banners: Banner.samples)
                .padding(.vertical, 20)

            HStack {
                Text(R.string.localizable.popularProducts())
                    .font(R.font.outfitBold.font(size: 20))
                Spacer()
                Text(R.string.localizable.seeAll())
                    .foregroundColor(.main)
                    .font(R.font.outfitRegular.font(size: 15))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(SBProduct.sampleList) { product in
                    NavigationLink(destination: SBProductDetailView(product: product)) {
                        SBProductCard(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
            .padding(.horizontal)
        }
    }
}

struct AllProductsView: View {
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(SBProduct.sampleList) { product in
                    NavigationLink(destination: SBProductDetailView(product: product)) {
                        SBProductCard(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
            .padding(.horizontal)
        }
    }
}

struct BestSellersView: View {
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(SBProduct.sampleList) { product in
                    NavigationLink(destination: SBProductDetailView(product: product)) {
                        SBProductCard(product: product)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SBStoreView()
}
