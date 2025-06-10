import SwiftUI

struct SBSearchProductView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State private var navigateToStore = false
    
    var body: some View {
        SBBaseView {
            VStack(spacing: 16) {
                // Horizontal Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // "All" filter option
                        Button {
                            viewModel.selectedTagId = nil
                            viewModel.performSearch()
                        } label: {
                            Text("All")
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    (viewModel.selectedTagId == nil) ? Color.main : Color(.systemGray6)
                                )
                                .foregroundColor(
                                    (viewModel.selectedTagId == nil) ? .white : .black
                                )
                                .cornerRadius(14)
                        }
                        .buttonStyle(PlainButtonStyle())

                        ForEach(viewModel.tags, id: \.id) { tag in
                            Button {
                                viewModel.selectedTagId = tag.id
                                viewModel.performSearch()
                            } label: {
                                Text(tag.tagName)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        (viewModel.selectedTagId == tag.id) ? Color.main : Color(.systemGray6)
                                    )
                                    .foregroundColor(
                                        (viewModel.selectedTagId == tag.id) ? .white : .black
                                    )
                                    .cornerRadius(14)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredProducts.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No products found")
                            .font(R.font.outfitRegular.font(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(viewModel.filteredProducts) { product in
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
            .font(R.font.outfitRegular.font(size: 16))
        }
    }
}

#Preview {
    SBSearchProductView(viewModel: SearchViewModel())
}
