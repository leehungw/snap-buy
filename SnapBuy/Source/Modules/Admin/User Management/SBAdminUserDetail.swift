import SwiftUI

struct SBAdminUserDetailView: View {
    let user: UserAdmin
    @Environment(\.dismiss) var dismiss
    // Giả lập dữ liệu thống kê
    let buyerStats = (purchaseCount: 12, totalSpent: 35400, totalOrders: 10)
    let sellerStats = (productCount: 24, totalRevenue: 12500, totalPurchases: 76)

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
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue.opacity(0.8))
                
                Text(user.name)
                    .font(R.font.outfitBold.font(size: 22))
                
                Text(user.email)
                    .font(R.font.outfitRegular.font(size: 16))
                    .foregroundColor(.gray)
            }
            HStack(spacing: 12) {
                detailRow(icon: "person.text.rectangle", title: "Role", value: user.role.capitalized, color: .purple)
                detailRow(icon: "lock.shield", title: "Status", value: user.isBlocked ? "Blocked" : "Active", color: user.isBlocked ? .red : .green)
            }
            
            if user.role.lowercased() == "buyer" {
                statCard(title: "Purchase Count", value: "\(buyerStats.purchaseCount)", icon: "cart.fill", color: .blue)
                statCard(title: "Total Spent", value: formatCurrency(buyerStats.totalSpent), icon: "creditcard.fill", color: .orange)
                statCard(title: "Total Orders", value: "\(buyerStats.totalOrders)", icon: "doc.plaintext", color: .green)
            } else if user.role.lowercased() == "seller" {
                statCard(title: "Product Count", value: "\(sellerStats.productCount)", icon: "bag.fill", color: .purple)
                statCard(title: "Total Revenue", value: formatCurrency(sellerStats.totalRevenue), icon: "dollarsign.circle.fill", color: .pink)
                statCard(title: "Total Purchases", value: "\(sellerStats.totalPurchases)", icon: "cart.badge.plus", color: .blue)
            }
            
            Spacer()
            HStack {
                Spacer()
                Button(action: {}) {
                    Text(user.isBlocked ? "Unblock this User" : "Block this User")
                        .font(R.font.outfitMedium.font(size: 18))
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
            }
            .background(RoundedRectangle(cornerRadius: 30).fill(user.isBlocked ? .green : .red))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
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

    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)₫"
    }
}

#Preview {
    SBAdminUserDetailView(user:  UserAdmin(id: UUID(), name: "Lan Nguyen", email: "lan@example.com", role: "buyer", isBlocked: true))
}
