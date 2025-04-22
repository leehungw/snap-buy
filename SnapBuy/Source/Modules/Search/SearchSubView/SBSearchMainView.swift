import SwiftUI

struct SBSearchProductView: View {
    @State private var searchText = ""
    @State private var navigateToStore = false

    var body: some View {
        SBBaseView {
            VStack(spacing: 16) {
                // Horizontal Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["All", "Latest", "Most Popular", "Cheapest", "Most Expensive"], id: \.self) { title in
                            Text(title)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(title == "All" ? Color.main : Color(.systemGray6))
                                .foregroundColor(title == "All" ? .white : .black)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                // Store Card with tap to navigate
                Button {
                    navigateToStore = true
                } label: {
                    HStack {
                        Image(systemName: "cube.box")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(24)
                            .padding(.trailing,10)
                        VStack(alignment: .leading) {
                            HStack {
                                Text(R.string.localizable.upboxBag())
                                    .font(R.font.outfitSemiBold.font(size: 20))
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(Color.main)
                                    .font(.caption)
                            }
                            Text(R.string.localizable.storeStatsFormat("104", "1.3k"))
                                .font(R.font.outfitRegular.font(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.gray)
                    }
                    .padding(.horizontal,30)
                    .padding(.bottom,10)
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: SBStoreView(), isActive: $navigateToStore) {
                    EmptyView()
                }

                ScrollView {
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
                .padding(.top,10)
            }
            .font(R.font.outfitRegular.font(size: 16))
        }
    }
}
#Preview {
    SBSearchProductView()
}
