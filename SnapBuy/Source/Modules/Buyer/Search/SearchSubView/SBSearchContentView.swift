import SwiftUI

struct SBSearchContent: View {
    @Binding var searchText: String
    @Binding var lastSearches: [String]
    var onSearchSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Last Search header
            HStack(alignment: .bottom) {
                Text(R.string.localizable.lastSearch())
                    .font(R.font.outfitBold.font(size: 20))
                Spacer()
                Button(R.string.localizable.clearAll()) {
                    lastSearches.removeAll()
                    UserDefaults.standard.set([String].self, value: [], key: "last_searches")
                }
                .font(R.font.outfitRegular.font(size: 13))
                .foregroundColor(Color.main)
            }
            .padding(.horizontal)

            // Wrap layout for last searches
            if !lastSearches.isEmpty {
                WrapLayout(data: lastSearches) { item in
                    HStack {
                        Text(item)
                            .foregroundColor(.gray)
                            .font(R.font.outfitRegular.font(size: 12))
                            .onTapGesture {
                                onSearchSelected(item)
                            }
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .onTapGesture {
                                lastSearches.removeAll { $0 == item }
                                UserDefaults.standard.set([String].self, value: lastSearches, key: "last_searches")
                            }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            } else {
                Text("No recent searches")
                    .foregroundColor(.gray)
                    .font(R.font.outfitRegular.font(size: 14))
                    .padding(.horizontal)
            }

            // Popular search header
            Text(R.string.localizable.popularSearch())
                .font(R.font.outfitBold.font(size: 20))
                .padding(.horizontal)

            // List of popular search items
            VStack(spacing: 20) {
                ForEach(PopularItem.sampleList) { item in
                    HStack(spacing: 12) {
                        Image(item.imageName)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(R.font.outfitSemiBold.font(size: 15))
                            Text(item.subtitle)
                                .font(R.font.outfitRegular.font(size: 13))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(item.badge)
                            .font(.caption)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(item.badgeColor.opacity(0.2))
                            .foregroundColor(item.badgeColor)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding(.top)
        .font(R.font.outfitRegular.font(size: 16))
    }
}
