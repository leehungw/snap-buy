import SwiftUI

struct SBFilterSheetView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var shouldNavigateToSearch: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text(R.string.localizable.filterBy())
                .font(R.font.outfitBold.font(size: 20))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 50)

            // PRICE
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text(R.string.localizable.price())
                        .font(R.font.outfitBold.font(size: 20))
                    Spacer()
                    Text("$\(Int(viewModel.minPrice)) – $\(Int(viewModel.maxPrice))")
                        .foregroundColor(.gray)
                        .font(R.font.outfitRegular.font(size: 14))
                }

                SBRangeSlider(
                    lowerValue: $viewModel.minPrice,
                    upperValue: $viewModel.maxPrice,
                    minValue: 0,
                    maxValue: 1000
                )
                .padding(.horizontal, 20)
            }

            // CATEGORY
            VStack(alignment: .leading, spacing: 20) {
                Text("Category")
                    .font(R.font.outfitBold.font(size: 16))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // "All" category option
                        Text("All")
                            .font(R.font.outfitMedium.font(size: 14))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(
                                (viewModel.selectedCategoryId == -1)
                                    ? Color.main
                                    : Color.white
                            )
                            .foregroundColor(
                                (viewModel.selectedCategoryId == -1)
                                    ? .white
                                    : .main
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.main, lineWidth: 1)
                            )
                            .cornerRadius(20)
                            .onTapGesture {
                                viewModel.selectedCategoryId = -1
                            }
                        
                        ForEach(viewModel.categories, id: \.id) { category in
                            Text(category.name)
                                .font(R.font.outfitMedium.font(size: 14))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(
                                    (viewModel.selectedCategoryId == category.id)
                                        ? Color.main
                                        : Color.white
                                )
                                .foregroundColor(
                                    (viewModel.selectedCategoryId == category.id)
                                        ? .white
                                        : .main
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.main, lineWidth: 1)
                                )
                                .cornerRadius(20)
                                .onTapGesture {
                                    viewModel.selectedCategoryId = category.id
                                }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            
            // Buttons
            HStack(spacing: 15) {
                // Reset button
                Button(action: {
                    viewModel.resetFilters()
                }) {
                    Text("Reset")
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .foregroundColor(.main)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.main, lineWidth: 1)
                        )
                }
                
                // Apply button
                Button(action: {
                    viewModel.performSearch()
                    shouldNavigateToSearch = true
                    dismiss()
                }) {
                    Text("Apply Filters")
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.main)
                        .cornerRadius(25)
                }
            }
            .padding(.top, 20)
        }
        .font(R.font.outfitRegular.font(size: 16))
        .padding(.horizontal, 25)
        .padding(.bottom,20)
    }
}
