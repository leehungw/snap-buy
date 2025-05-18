import SwiftUI
enum Tab {
    case home, category
}

struct SBHomeView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        SBBaseView {  
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("img_a")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("Hi, Jonathan")
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
                ScrollView {
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
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)}
                
            }
            .padding(.top)
        }
    }
}
#Preview {
    SBHomeView()
}
struct SBHomeContent: View {
    var body: some View {
        VStack(spacing: 20) {
            SBBannerCarouselView(banners: Banner.samples)
                .padding(.vertical, 10)

            HStack {
                Text("New Arrivals")
                    .font(R.font.outfitBold.font(size: 20))
                Spacer()
                Text("See All")
                    .foregroundColor(.main)
                    .font(R.font.outfitSemiBold.font(size: 15))
            }
            .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(Product.sampleList) { product in
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

struct SBCategoryContent: View {
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Category.samples) { category in
                SBCategoryItemView(category: category)
            }
        }
        .padding(.horizontal,30)
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
