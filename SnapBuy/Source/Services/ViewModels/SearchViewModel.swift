import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 0
    @Published var selectedCategoryId: Int? = -1 // -1 represents "All"
    @Published var selectedTagId: Int? = nil
    @Published var filteredProducts: [SBProduct] = []
    @Published var categories: [SBCategory] = []
    @Published var tags: [SBTag] = []
    @Published var isLoading: Bool = false
    
    private var selectedCategory: SBCategory? {
        categories.first { $0.id == selectedCategoryId }
    }
    
    private var selectedTag: SBTag? {
        tags.first { $0.id == selectedTagId }
    }
    
    func loadFilters() {
        // Load categories
        CategoryRepository.shared.fetchCategories { [weak self] result in
            if case .success(let categories) = result {
                DispatchQueue.main.async {
                    self?.categories = categories
                }
            }
        }
        
        // Load tags
        TagRepository.shared.fetchTags { [weak self] result in
            if case .success(let tags) = result {
                DispatchQueue.main.async {
                    self?.tags = tags
                }
            }
        }
    }
    
    func performSearch() {
        isLoading = true
        
        // Prepare filter parameters
        let name = searchText.isEmpty ? "null" : searchText
        let categoryName = selectedCategoryId == -1 ? "null" : (selectedCategory?.name ?? "null")
        let tag = selectedTag?.tagName ?? "null"
        
        ProductRepository.shared.fetchFilteredProducts(
            name: name,
            startPrice: minPrice,
            endPrice: maxPrice,
            categoryName: categoryName,
            tag: tag
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                if case .success(let products) = result {
                    self?.filteredProducts = products
                }
            }
        }
    }
    
    // Reset all filters
    func resetFilters() {
        minPrice = 0
        maxPrice = 60
        selectedCategoryId = -1 // Reset to "All"
        selectedTagId = nil
    }
} 
