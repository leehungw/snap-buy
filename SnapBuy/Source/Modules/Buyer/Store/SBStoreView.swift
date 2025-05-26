import SwiftUI
import Kingfisher

//enum StoreTab: String, CaseIterable {
//    case main = "Mainpage"
//
//    static var allCases: [StoreTab] {
//        return [.main]
//    }
//}

struct SBStoreView: View {
    @Environment(\.dismiss) var dismiss
    @State private var userData: UserData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var products: [SBProduct] = []
    @State private var isLoadingProducts = true
    @State private var productsError: String?
    let sellerId: String
    
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
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let user = userData {
                    // Store Info
                    HStack {
                        KFImage(URL(string: user.imageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .cornerRadius(24)
                            .padding(.trailing, 10)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text(user.name)
                                    .font(R.font.outfitBold.font(size: 16))
                                if user.isPremium {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color.main)
                                        .font(.caption)
                                }
                            }
                            
                            Text(user.userName)
                                .font(R.font.outfitRegular.font(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
//                        Button(action: {}) {
//                            Text(R.string.localizable.follow())
//                                .font(R.font.outfitSemiBold.font(size: 14))
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 8)
//                                .background(Color.main)
//                                .foregroundColor(.white)
//                                .cornerRadius(20)
//                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        SBBannerCarouselView(banners: Banner.samples)
                            .padding(.vertical, 20)
                        if let error = productsError {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else if isLoadingProducts {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            HStack {
                                Text(R.string.localizable.allProducts())
                                    .font(R.font.outfitBold.font(size: 20))
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(products) { product in
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
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchUserData()
            fetchProducts()
        }
    }
    
    private func fetchUserData() {
        isLoading = true
        errorMessage = nil
        
        UserRepository.shared.fetchUserById(userId: sellerId) { result in
            isLoading = false
            switch result {
            case .success(let user):
                userData = user
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func fetchProducts() {
        isLoadingProducts = true
        productsError = nil
        
        ProductRepository.shared.fetchProductsBySellerId(sellerId: sellerId) { result in
            isLoadingProducts = false
            switch result {
            case .success(let fetchedProducts):
                products = fetchedProducts
            case .failure(let error):
                productsError = error.localizedDescription
            }
        }
    }
}

struct MainView: View {
    var body: some View {
        VStack {
            SBBannerCarouselView(banners: Banner.samples)
                .padding(.vertical, 20)
            
            HStack {
                Text(R.string.localizable.allProducts())
                    .font(R.font.outfitBold.font(size: 20))
//                Spacer()
//                Text(R.string.localizable.seeAll())
//                    .foregroundColor(.main)
//                    .font(R.font.outfitRegular.font(size: 15))
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
    SBStoreView(sellerId: "")
}
