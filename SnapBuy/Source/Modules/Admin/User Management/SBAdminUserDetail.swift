import SwiftUI

struct SBAdminUserDetailView: View {
    let user: UserData
    let onUserUpdated: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var userData: UserData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isBlocked: Bool
    @State private var showingBlockAlert = false
    @State private var shouldDismiss = false
    @State private var sellerStats: SellerStats?
    @State private var buyerStats: BuyerStats?
    
    init(user: UserData, onUserUpdated: @escaping () -> Void) {
        self.user = user
        self.onUserUpdated = onUserUpdated
        self._isBlocked = State(initialValue: user.isBanned)
    }

    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 6) {
                HStack{
                    Button(action: {dismiss()}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                
                AsyncImage(url: URL(string: user.imageURL)) { image in
                    image.resizable()
                } placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.blue.opacity(0.8))
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
                Text(user.name)
                    .font(R.font.outfitBold.font(size: 22))
                
                Text(user.email)
                    .font(R.font.outfitRegular.font(size: 16))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 12) {
                detailRow(icon: "person.text.rectangle", 
                        title: "Role", 
                        value: user.isAdmin ? "Admin" : (user.isPremium ? "Seller" : "Buyer"), 
                        color: .purple)
                detailRow(icon: "lock.shield", 
                        title: "Status", 
                        value: user.isBanned ? "Blocked" : "Active", 
                        color: user.isBanned ? .red : .green)
            }
            
            if !user.isAdmin {
                if !user.isPremium {
                    if let stats = buyerStats {
                        statCard(title: "Purchase Count", value: "\(stats.purchaseCount)", icon: "cart.fill", color: .blue)
                        statCard(title: "Total Spent", value: formatCurrency(stats.totalSpent), icon: "creditcard.fill", color: .orange)
                        statCard(title: "Total Orders", value: "\(stats.totalOrders)", icon: "doc.plaintext", color: .green)
                    } else {
                        ProgressView()
                            .frame(height: 100)
                    }
                } else if let stats = sellerStats {
                    statCard(title: "Product Count", value: "\(stats.productCount)", icon: "bag.fill", color: .purple)
                    statCard(title: "Total Revenue", value: formatCurrency(stats.totalRevenue), icon: "dollarsign.circle.fill", color: .pink)
                    statCard(title: "Total Purchases", value: "\(stats.totalPurchases)", icon: "cart.badge.plus", color: .blue)
                } else {
                    ProgressView()
                        .frame(height: 100)
                }
            }
            
            Spacer()
            
            if !user.isAdmin {
                HStack {
                    Spacer()
                    Button(action: {
                        showingBlockAlert = true
                    }) {
                        Text(isBlocked ? "Unblock this User" : "Block this User")
                            .font(R.font.outfitMedium.font(size: 18))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                .background(RoundedRectangle(cornerRadius: 30).fill(isBlocked ? .green : .red))
                .alert(isBlocked ? "Unblock User" : "Block User", isPresented: $showingBlockAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button(isBlocked ? "Unblock" : "Block", role: .destructive) {
                        toggleBlock()
                    }
                } message: {
                    Text(isBlocked ? "Are you sure you want to unblock this user?" : "Are you sure you want to block this user?")
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .onChange(of: shouldDismiss) { newValue in
            if newValue {
                dismiss()
            }
        }
        .onAppear {
            if user.isPremium {
                fetchSellerStats()
            } else if !user.isAdmin {
                fetchBuyerStats()
            }
        }
    }

    private func fetchSellerStats() {
        UserRepository.shared.fetchSellerStats(userId: user.id) { result in
            switch result {
            case .success(let stats):
                self.sellerStats = stats
            case .failure(let error):
                print("Error fetching seller stats: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func fetchBuyerStats() {
        UserRepository.shared.fetchBuyerStats(userId: user.id) { result in
            switch result {
            case .success(let stats):
                self.buyerStats = stats
            case .failure(let error):
                print("Error fetching buyer stats: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }
    }

    @ViewBuilder
    private func detailRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding(10)
                .background(color)
                .clipShape(Circle())

            VStack(alignment: .leading) {
                Text(title)
                    .font(R.font.outfitRegular.font(size: 14))
                    .foregroundColor(.gray)
                Text(value)
                    .font(R.font.outfitMedium.font(size: 16))
            }

            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            VStack {
                Image(systemName: icon)
                    .font(.system(size:30))
                    .foregroundColor(.white)
                    .padding()
                   
            }
            .frame(width: 80, height: 80)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Text(title)
                    .font(R.font.outfitRegular.font(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
                    .font(R.font.outfitBold.font(size: 35))
            }
            .padding(.horizontal,10)

            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
    
    private func toggleBlock() {
        if isBlocked {
            UserRepository.shared.unbanUser(userId: user.id) { result in
                switch result {
                case .success(let response):
                    if response.result == 1 && response.data == 1 {
                        onUserUpdated()
                        shouldDismiss = true
                    } else if let error = response.error {
                        self.errorMessage = error.message
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        } else {
            UserRepository.shared.banUser(userId: user.id) { result in
                switch result {
                case .success(let response):
                    if response.result == 1 && response.data == 1 {
                        onUserUpdated()
                        shouldDismiss = true
                    } else if let error = response.error {
                        self.errorMessage = error.message
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    SBAdminUserDetailView(
        user: UserData(id: "1", 
                      name: "Lan Nguyen", 
                      imageURL: "", 
                      userName: "lan", 
                      email: "lan@example.com", 
                      isAdmin: false, 
                      isPremium: false, 
                      isBanned: true, 
                      lastProductId: 123),
        onUserUpdated: {}
    )
}

