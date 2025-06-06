import SwiftUI
import Kingfisher

extension ChatRoom {
    init(chatRoomId: String, userId: String, name: String, avatar: String) {
        self.id = Int(chatRoomId.replacingOccurrences(of: "-", with: "")) ?? 0
        self.userId = userId
        self.name = name
        self.avatar = avatar
        self.lastMessage = nil
        self.lastMessageTime = Date()
        self.type = .text
    }
}

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
    @State private var showChat = false
    @State private var isInitializingChat = false
    let sellerId: String
    
    private func createChatRoom(with user: UserData) -> ChatRoom {
        let chatRoomId = "\(UserRepository.shared.currentUser?.id ?? "")_\(sellerId)"
        return ChatRoom(
            chatRoomId: chatRoomId,
            userId: sellerId,
            name: user.name,
            avatar: user.imageURL
        )
    }
    
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
                        
                        if isInitializingChat {
                            ProgressView()
                        } else {
                            NavigationLink(destination: SBChatView(chatRoom: createChatRoom(with: user)), isActive: $showChat) {
                                Button(action: {
                                    initializeChat(with: user)
                                }) {
                                    Image(systemName: "ellipsis.message")
                                }
                            }
                        }
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
    
    private func initializeChat(with user: UserData) {
        guard let currentUserId = UserRepository.shared.currentUser?.id else { return }
        
        isInitializingChat = true
        
        // First check if chat exists
        let chatRoomId = "\(currentUserId)_\(sellerId)"
        
        ChatRepository.shared.fetchChatMessages(chatRoomId: chatRoomId) { result in
            switch result {
            case .success(let response):
                if let messages = response.data, !messages.isEmpty {
                    // Chat exists, just navigate
                    DispatchQueue.main.async {
                        isInitializingChat = false
                        showChat = true
                    }
                } else {
                    // Chat doesn't exist, send greeting
                    let request = SendTextRequest(
                        userSendId: currentUserId,
                        userReceiveId: sellerId,
                        message: "👋"
                    )
                    
                    ChatRepository.shared.sendText(request: request) { result in
                        DispatchQueue.main.async {
                            isInitializingChat = false
                            switch result {
                            case .success(_):
                                showChat = true
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            case .failure(_):
                // If error fetching messages, try to create new chat anyway
                let request = SendTextRequest(
                    userSendId: currentUserId,
                    userReceiveId: sellerId,
                    message: "👋"
                )
                
                ChatRepository.shared.sendText(request: request) { result in
                    DispatchQueue.main.async {
                        isInitializingChat = false
                        switch result {
                        case .success(_):
                            showChat = true
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
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
