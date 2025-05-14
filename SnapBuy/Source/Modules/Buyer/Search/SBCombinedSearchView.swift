import SwiftUI

struct SBCombinedSearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var lastSearches: [String] = ["Electronics", "Pants", "Three Second", "Long shirt"]
    @State private var isSheetPresented = false

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        SBBaseView {
            NavigationStack {
                VStack {
                    // Search Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                            
                            TextField(R.string.localizable.search(), text: $searchText)
                                .foregroundColor(.black)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            
                            Spacer()
                            
                            if !isSearching {
                                Button(action: {
                                    isSheetPresented = true
                                }) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.main, lineWidth: 1)
                        )
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal)

                    // Main content
                    if isSearching {
                        SBSearchContent(
                            searchText: $searchText,
                            lastSearches: $lastSearches
                        )
                    } else {
                        SBSearchProductView()
                    }
                }
                .font(R.font.outfitRegular.font(size: 16))
                .sheet(isPresented: $isSheetPresented) {
                    SBFilterSheetView()
                        .presentationDetents([.fraction(0.6)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(50)
                }
            }
        }
    }
}

#Preview {
    SBCombinedSearchView()
}
