import SwiftUI

struct HomeView: View {
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home, category
    }
    
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
                            .font(.custom("Outfit-Bold", size: 16))
                        Text("Let's go shopping")
                            .font(.custom("Outfit-Regular", size: 13))
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
                    VStack {
                        Text("Home")
                            .font(.custom("Outfit-Medium", size: 16))
                            .foregroundColor(selectedTab == .home ? .black : .gray)
                        
                        Divider()
                            .frame(height: 2)
                            .background(Color.main)
                            .padding(.horizontal, 15)
                            .opacity(selectedTab == .home ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .onTapGesture {
                        selectedTab = .home
                    }
                    Spacer()
                    VStack {
                        Text("Category")
                            .font(.custom("Outfit-Medium", size: 16))
                            .foregroundColor(selectedTab == .category ? .black : .gray)
                        
                        Divider()
                            .frame(height: 2)
                            .background(Color.main)
                            .padding(.horizontal, 15)
                            .opacity(selectedTab == .category ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    }
                    .onTapGesture {
                        selectedTab = .category
                    }
                }
                .padding(.horizontal, 50)
                ScrollView {
                    ZStack {
                        if selectedTab == .home {
                            HomeContent()
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            CategoryContent()
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
    HomeView()
}
struct HomeContent: View {
    var body: some View {
        VStack(spacing: 20) {
            SBBannerCarouselView(banners: Banner.samples)
                .padding(.vertical, 10)

            HStack {
                Text("New Arrivals")
                    .font(.custom("Outfit-Bold", size: 20))
                Spacer()
                Text("See All")
                    .foregroundColor(.main)
                    .font(.custom("Outfit-Semibold", size: 15))
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

struct CategoryContent: View {
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Category.samples) { category in
                SBCategoryItemView(category: category)
            }
        }
        .padding(.horizontal,30)
    }
}
