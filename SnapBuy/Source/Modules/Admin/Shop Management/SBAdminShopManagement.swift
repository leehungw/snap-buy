import SwiftUI

struct SBAdminShopManagementView: View {
    @State private var searchText = ""
    @State private var selectedFilter: ShopFilter = .all
    @State private var shops: [SellerShop] = sampleShops
    @Environment(\.dismiss) var dismiss
    
    var filteredShops: [SellerShop] {
        shops.filter { shop in
            (searchText.isEmpty || shop.name.localizedCaseInsensitiveContains(searchText) || shop.email.localizedCaseInsensitiveContains(searchText)) &&
            (selectedFilter == .all || (selectedFilter == .approved && shop.isApproved) || (selectedFilter == .pending && !shop.isApproved))
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AdminHeader(title: "Shope Management", dismiss: dismiss)
                // MARK: Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search shop name or email...", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1))
                .background(Color.white)
                .padding(.horizontal)
                
                // MARK: Filter
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(ShopFilter.allCases, id: \.self) { filter in
                        Text(filter.title)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                // MARK: Shop List
                List {
                    ForEach(filteredShops) { shop in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(shop.name)
                                    .font(R.font.outfitMedium.font(size: 16))
                                Text(shop.email)
                                    .font(R.font.outfitRegular.font(size: 13))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                            Toggle(isOn: .constant(shop.isApproved)) {
                                Text(shop.isApproved ? "Approved" : "Pending")
                                    .font(R.font.outfitMedium.font(size: 12))
                                    .foregroundColor(shop.isApproved ? .green : .orange)
                            }
                            .labelsHidden()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func approveShop(_ shop: SellerShop) {
        if let index = shops.firstIndex(where: { $0.id == shop.id }) {
            shops[index].isApproved = true
        }
    }
}

// MARK: Filter Enum
enum ShopFilter: String, CaseIterable {
    case all, approved, pending

    var title: String {
        switch self {
        case .all: "All"
        case .approved: "Approved"
        case .pending: "Pending"
        }
    }
}

// MARK: Sample Data
struct SellerShop: Identifiable {
    var id: String
    var name: String
    var email: String
    var isApproved: Bool
}

let sampleShops = [
    SellerShop(id: "1", name: "RetroStyle Store", email: "retro@example.com", isApproved: false),
    SellerShop(id: "2", name: "TechHub", email: "techhub@example.com", isApproved: true),
    SellerShop(id: "3", name: "Fashionista", email: "style@example.com", isApproved: false),
    SellerShop(id: "4", name: "GadgetHouse", email: "gadget@example.com", isApproved: true)
]

#Preview {
    SBAdminShopManagementView()
}
