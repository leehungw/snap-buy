import SwiftUI

struct SBCategoryContent: View {
    @State private var categories: [SBCategory] = []
    
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        List(categories) { category in
            SBCategoryItemView(category: category)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 60)
        }
        .onAppear {
            CategoryRepository.shared.fetchCategories { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let list):
                        categories = list
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
}
