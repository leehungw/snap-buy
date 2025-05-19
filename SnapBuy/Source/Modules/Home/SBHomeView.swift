import SwiftUI
import Foundation

enum Tab {
    case home, category
}

struct SBHomeView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        SBBaseView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    RImage.img_default_user_profile.image
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(RLocalizable.hi(UserRepository.shared.currentUser?.name ?? ""))
                            .font(R.font.outfitBold.font(size: 16))
                        Text("Let's go shopping")
                            .font(R.font.outfitRegular.font(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .font(.title3)
                }
                .padding(.horizontal)
                
                HStack {
                    TabButton(title: "Home", tab: .home, selectedTab: selectedTab) {
                        selectedTab = .home
                    }
                    Spacer()
                    TabButton(title: "Category", tab: .category, selectedTab: selectedTab) {
                        selectedTab = .category
                    }
                }
                .padding(.horizontal, 50)
                ZStack {
                    if selectedTab == .home {
                        SBHomeContent()
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    } else {
                        SBCategoryContent()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .id(selectedTab)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
            }
            .padding(.top)
        }
    }
}
#Preview {
    SBHomeView()
}

struct SBHomeContent: View {
    let sections: [(title: String, products: [SBProduct])] = [
        ("New Arrivals", SBProduct.sampleList),
        ("Best Sellers", SBProduct.sampleList),
        ("Trending Now", SBProduct.sampleList),
        ("Recommended", SBProduct.sampleList)
    ]
    
    var body: some View {
        List {
            Section {
                SBBannerCarouselView(banners: Banner.samples)
                    .listRowInsets(EdgeInsets())
            }
            .listRowSeparator(.hidden)

            ForEach(sections, id: \.title) { section in
                Section(header:
                    HStack {
                        Text(section.title)
                            .font(R.font.outfitBold.font(size: 20))
                        Spacer()
                        Text("See All")
                            .foregroundColor(.main)
                            .font(R.font.outfitSemiBold.font(size: 15))
                    }
                ) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(section.products) { product in
                            SBProductCard(product: product)
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(PlainListStyle())
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 30)
        }
    }
}

func TabButton<T: Equatable>(title: String, tab: T, selectedTab: T, action: @escaping () -> Void) -> some View {
    VStack {
        Text(title)
            .font(R.font.outfitMedium.font(size: 16))
            .foregroundColor(selectedTab == tab ? .black : .gray)
        
        Divider()
            .frame(height: 2)
            .background(Color.main)
            .padding(.horizontal, 15)
            .opacity(selectedTab == tab ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
    .onTapGesture {
        action()
    }
}
