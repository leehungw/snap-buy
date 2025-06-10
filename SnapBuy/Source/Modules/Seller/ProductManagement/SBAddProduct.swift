import SwiftUI
import PhotosUI

struct SBAddProductView: View {
    @Environment(\.dismiss) var dismiss
    var onDismiss: (() -> Void)?
    
    @State private var productName = ""
    @State private var description = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var selectedCategory: SBCategory?
    @State private var selectedImages: [UIImage] = []
    @State private var showPhotoPicker = false
    @State private var selectedColors: [Color] = []
    @State private var selectedSizes: [String] = []
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedColor = Color.red
    
    @State private var categories: [SBCategory] = []
    @State private var tags: [SBTag] = []
    
    var body: some View {
        VStack {
            Header(title: "Add Product", dismiss: dismiss)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        ProductTextField(title: "Product Name", placeholder: "Enter product name", text: $productName)
                        
                        ProductMultilineField(title: "Description", text: $description)
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Category")
                                .font(R.font.outfitMedium.font(size: 14))
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.id) { category in
                                    Text(category.name).tag(Optional(category))
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Colors Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colors")
                                .font(R.font.outfitMedium.font(size: 14))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(selectedColors, id: \.self) { color in
                                        Circle()
                                            .fill(color)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                if let index = selectedColors.firstIndex(of: color) {
                                                    selectedColors.remove(at: index)
                                                }
                                            }
                                    }
                                    
                                    ColorPicker("", selection: $selectedColor)
                                        .labelsHidden()
                                    
                                    Button(action: { selectedColors.append(selectedColor) }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.main)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Sizes Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sizes")
                                .font(R.font.outfitMedium.font(size: 14))
                            
                            let sizes = ["XS", "S", "M", "L", "XL", "XXL"]
                            FlowLayout(spacing: 8) {
                                ForEach(sizes, id: \.self) { size in
                                    Button(action: {
                                        if selectedSizes.contains(size) {
                                            selectedSizes.removeAll { $0 == size }
                                        } else {
                                            selectedSizes.append(size)
                                        }
                                    }) {
                                        Text(size)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedSizes.contains(size) ? Color.main : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedSizes.contains(size) ? .white : .black)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Tags Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(R.font.outfitMedium.font(size: 14))
                            
                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \.id) { tag in
                                    Button(action: {
                                        if selectedTags.contains(tag.tagName) {
                                            selectedTags.remove(tag.tagName)
                                        } else {
                                            selectedTags.insert(tag.tagName)
                                        }
                                    }) {
                                        Text(tag.tagName)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedTags.contains(tag.tagName) ? Color.main : Color.gray.opacity(0.2))
                                            .foregroundColor(selectedTags.contains(tag.tagName) ? .white : .black)
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        
                        HStack(spacing: 20) {
                            ProductTextField(title: "Price", placeholder: "Enter price", text: $price, keyboardType: .decimalPad)
                            ProductTextField(title: "Quantity", placeholder: "Enter quantity", text: $quantity, keyboardType: .numberPad)
                        }
                        
                        ImagePickerView(selectedImages: $selectedImages, showPicker: $showPhotoPicker)
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(R.font.outfitRegular.font(size: 14))
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                }
                
                Button(action: submitProduct) {
                    Text("Post Product")
                        .font(R.font.outfitMedium.font(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid() ? Color.main : Color.gray.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding()
                .disabled(!isValid())
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: Binding(get: { nil }, set: { item in
                if let item = item {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImages.append(image)
                        }
                    }
                }
            }),
            matching: .images
        )
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadInitialData()
        }
    }
    
    private func loadInitialData() {
        // Load categories
        CategoryRepository.shared.fetchCategories { result in
            switch result {
            case .success(let fetchedCategories):
                self.categories = fetchedCategories
                self.selectedCategory = fetchedCategories.first
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
        
        // Load tags
        TagRepository.shared.fetchTags { result in
            switch result {
            case .success(let fetchedTags):
                self.tags = fetchedTags
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func isValid() -> Bool {
        guard let _ = selectedCategory,
              !productName.isEmpty,
              !description.isEmpty,
              Double(price) != nil,
              Int(quantity) != nil,
              !selectedColors.isEmpty,
              !selectedSizes.isEmpty,
              !selectedImages.isEmpty else {
            return false
        }
        return true
    }
    
    func submitProduct() {
        isLoading = true
        errorMessage = nil
        
        // First upload images
        ImgurService.shared.uploadImages(selectedImages) { result in
            switch result {
            case .success(let imageUrls):
                // Create product variants
                var variants: [CreateProductVariant] = []
                for size in selectedSizes {
                    for color in selectedColors {
                        variants.append(CreateProductVariant(
                            size: size,
                            color: color.toHexString(),
                            price: Double(price) ?? 0
                        ))
                    }
                }
                
                // Create product request
                let request = CreateProductRequest(
                    sellerId: UserRepository.shared.currentUser?.id ?? "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                    name: productName,
                    description: description,
                    basePrice: Double(price) ?? 0,
                    categoryId: selectedCategory?.id ?? 1,
                    quantity: Int(quantity) ?? 0,
                    productImages: imageUrls,
                    productVariants: variants,
                    tags: Array(selectedTags)
                )
                
                // Create product
                ProductRepository.shared.createProduct(request: request) { result in
                    isLoading = false
                    switch result {
                    case .success:
                        onDismiss?()
                        dismiss()
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                    }
                }
                
            case .failure(let error):
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        // Calculate total size
        var maxWidth: CGFloat = 0
        var totalHeight: CGFloat = 0

        for row in rows {
            // Compute width of this row
            var rowWidth: CGFloat = 0
            var rowHeight: CGFloat = 0
            for view in row {
                let size = view.sizeThatFits(.unspecified)
                rowWidth += size.width
                rowHeight = max(rowHeight, size.height)
            }
            // Add spacing between items
            if row.count > 1 {
                rowWidth += CGFloat(row.count - 1) * spacing
            }
            // Update overall metrics
            maxWidth = max(maxWidth, rowWidth)
            totalHeight += rowHeight
        }
        // Add spacing between rows
        if rows.count > 1 {
            totalHeight += CGFloat(rows.count - 1) * spacing
        }
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            var x = bounds.minX
            
            for view in row {
                let size = view.sizeThatFits(.unspecified)
                view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            
            y += rowHeight + spacing
        }
    }
    
    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var rows: [[LayoutSubviews.Element]] = [[]]
        var currentRow = 0
        var x: CGFloat = 0
        
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            
            if x + size.width > (proposal.width ?? .infinity) {
                currentRow += 1
                rows.append([])
                x = size.width + spacing
            } else {
                x += size.width + spacing
            }
            
            rows[currentRow].append(view)
        }
        
        return rows
    }
}

extension Color {
    func toHexString() -> String {
        let components = UIColor(self).cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}

#Preview {
    SBAddProductView()
}
