import SwiftUI
import PhotosUI
import Kingfisher

struct SBEditProductView: View {
    @Environment(\.dismiss) var dismiss
    var onDismiss: (() -> Void)?
    let product: SBProduct

    @State private var productName: String
    @State private var description: String
    @State private var price: String
    @State private var quantity: String
    @State private var selectedCategory: SBCategory?
    @State private var selectedImages: [UIImage] = []
    @State private var existingImageUrls: [String] = []
    @State private var showPhotoPicker = false
    @State private var selectedColors: [Color] = []
    @State private var selectedSizes: [String] = []
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedColor = Color.red
    
    @State private var categories: [SBCategory] = []
    @State private var tags: [SBTag] = []

    init(product: SBProduct, onDismiss: (() -> Void)? = nil) {
        self.product = product
        self.onDismiss = onDismiss
        
        // Initialize state variables with product data
        _productName = State(initialValue: product.name)
        _description = State(initialValue: product.description)
        _price = State(initialValue: String(format: "%.2f", product.basePrice))
        _quantity = State(initialValue: String(product.quantity))
        _existingImageUrls = State(initialValue: product.productImages.map { $0.url })
        _selectedTags = State(initialValue: Set(product.listTag))
        
        // Convert product variants to colors and sizes
        let colors = Set(product.productVariants.map { $0.color })
        let sizes = Set(product.productVariants.map { $0.size })
        _selectedSizes = State(initialValue: Array(sizes))
        
        // Convert hex colors to Color objects
        _selectedColors = State(initialValue: colors.compactMap { hexString in
            if hexString.hasPrefix("#") {
                let hex = String(hexString.dropFirst())
                var rgbValue: UInt64 = 0
                Scanner(string: hex).scanHexInt64(&rgbValue)
                let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
                let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
                let b = Double(rgbValue & 0x0000FF) / 255.0
                return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
            }
            return nil
        })
    }

    var body: some View {
        VStack {
            Header(title: "Edit Product", dismiss: dismiss)
            
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
                        
                        // Existing Images
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current Images")
                                .font(R.font.outfitMedium.font(size: 14))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(existingImageUrls, id: \.self) { url in
                                        ZStack(alignment: .topTrailing) {
                                            KFImage(URL(string: url))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipped()
                                                .cornerRadius(8)
                                            
                                            Button(action: {
                                                if let index = existingImageUrls.firstIndex(of: url) {
                                                    existingImageUrls.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white.clipShape(Circle()))
                                            }
                                            .offset(x: 5, y: -5)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // New Images
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
                
                Button(action: updateProduct) {
                    Text("Update Product")
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
                // Set the current category
                self.selectedCategory = fetchedCategories.first { $0.id == self.product.categoryId }
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
              !existingImageUrls.isEmpty || !selectedImages.isEmpty else {
            return false
        }
        return true
    }
    
    func updateProduct() {
        isLoading = true
        errorMessage = nil
        
        let updateImages = { (imageUrls: [String]) in
            // Create product variants
            var variants: [CreateProductVariant] = []
            for size in selectedSizes {
                for color in selectedColors {
                    variants.append(CreateProductVariant(
                        productId: product.id,
                        size: size,
                        color: color.toHexString(),
                        price: Double(price) ?? 0,
                        status: 0
                    ))
                }
            }
            
            // Create product request
            let request = CreateProductRequest(
                id: product.id,
                sellerId: UserRepository.shared.currentUser?.id ?? "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                name: productName,
                description: description,
                basePrice: Double(price) ?? 0,
                status: 0,
                categoryId: selectedCategory?.id ?? 1,
                quantity: Int(quantity) ?? 0,
                productImages: imageUrls,
                productVariants: variants,
                tags: Array(selectedTags)
            )
            
            // Update product
            ProductRepository.shared.updateProduct(request: request) { result in
                isLoading = false
                switch result {
                case .success:
                    onDismiss?()
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        // If there are new images to upload
        if !selectedImages.isEmpty {
            ImgurService.shared.uploadImages(selectedImages) { result in
                switch result {
                case .success(let newImageUrls):
                    // Combine existing and new image URLs
                    let allImageUrls = existingImageUrls + newImageUrls
                    updateImages(allImageUrls)
                case .failure(let error):
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        } else {
            // Use only existing images
            updateImages(existingImageUrls)
        }
    }
}

struct Header: View {
    let title: String
    let dismiss: DismissAction

    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            Spacer()
            Text(title)
                .font(R.font.outfitBold.font(size: 20))
                .padding(.trailing, 15)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(.main)
    }
}
