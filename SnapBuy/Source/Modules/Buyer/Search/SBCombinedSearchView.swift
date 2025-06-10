import SwiftUI

struct SBCombinedSearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var lastSearches: [String] = UserDefaults.standard.get([String].self, key: "last_searches") ?? []
    @State private var isSheetPresented = false
    @State private var shouldShowSearchView = false

    var isSearching: Bool {
        !viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        SBBaseView {
            NavigationStack {
                VStack {
                    // Search Header
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black)
                            
                            TextField(R.string.localizable.search(), text: $viewModel.searchText, onCommit: {
                                let trimmed = viewModel.searchText.trimmingCharacters(in: .whitespaces)
                                guard !trimmed.isEmpty else { return }
                                // prepend, avoid duplicates, cap at 10
                                var updated = lastSearches.filter { $0 != trimmed }
                                updated.insert(trimmed, at: 0)
                                if updated.count > 10 { updated = Array(updated.prefix(10)) }
                                lastSearches = updated
                                // persist
                                UserDefaults.standard.set([String].self, value: updated, key: "last_searches")
                                // perform search and navigate
                                viewModel.performSearch()
                                shouldShowSearchView = true
                            })
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
                    if shouldShowSearchView {
                        SBSearchProductView(viewModel: viewModel)
                    } else if isSearching {
                        SBSearchContent(
                            searchText: $viewModel.searchText,
                            lastSearches: $lastSearches,
                            onSearchSelected: { search in
                                viewModel.searchText = search
                                viewModel.performSearch()
                                shouldShowSearchView = true
                            }
                        )
                    } else {
                        SBSearchProductView(viewModel: viewModel)
                    }
                }
                .font(R.font.outfitRegular.font(size: 16))
                .sheet(isPresented: $isSheetPresented) {
                    SBFilterSheetView(viewModel: viewModel, shouldNavigateToSearch: $shouldShowSearchView)
                        .presentationDetents([.fraction(0.4)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(50)
                }
                .onChange(of: viewModel.searchText) { newValue in
                    if newValue.isEmpty {
                        shouldShowSearchView = false
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadFilters()
        }
    }
}

#Preview {
    SBCombinedSearchView()
}

