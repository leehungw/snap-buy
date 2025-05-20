import SwiftUI
import PhotosUI

struct SBEditProductView: View {
    @Environment(\.dismiss) var dismiss

    @State private var productName: String
    @State private var description: String
    @State private var price: String
    @State private var quantity: String
    @State private var category: String
    @State private var selectedImages: [UIImage]
    @State private var colorInput = ""
    @State private var addedColors: [String]
    @State private var sizeInput = ""
    @State private var addedSizes: [String]
    @State private var showPhotoPicker = false
    @State private var photoSelections: [PhotosPickerItem] = []
    

    let categories = ["Clothes", "Shoes", "Accessories", "Other"]

    init(product: Product) {
        _productName = State(initialValue: product.name)
        _description = State(initialValue: product.description)
        _price = State(initialValue: String(format: "%.2f", product.price))
        _quantity = State(initialValue: String(product.stock))
        _category = State(initialValue: product.category)
        _selectedImages = State(initialValue: product.imageNames.compactMap { UIImage(named: $0) })
        _addedColors = State(initialValue: product.colors)
        _addedSizes = State(initialValue: product.sizes)
    }

    var body: some View {
        VStack {
            Header(title: "Edit Product", dismiss: dismiss)
            Spacer()
            ScrollView {
                VStack(spacing: 20) {
                    ProductTextField(title: "Product Name", placeholder: "Enter product name", text: $productName)
                    
                    ProductMultilineField(title: "Description", text: $description)
                    
                    ProductPicker(title: "Category", selection: $category, options: categories)
                    
                    TagInputField(title: "Colors", input: $colorInput, tags: $addedColors)
                    
                    TagInputField(title: "Sizes", input: $sizeInput, tags: $addedSizes)
                    
                    HStack(spacing: 20) {
                        ProductTextField(title: "Price", placeholder: "Enter price", text: $price, keyboardType: .decimalPad)
                        
                        ProductTextField(title: "Quantity", placeholder: "Enter quantity", text: $quantity, keyboardType: .numberPad)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Images")
                            .font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(selectedImages.indices, id: \.self) { index in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: selectedImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(10)

                                        Button(action: {
                                            selectedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .offset(x: 5, y: 0)
                                        .zIndex(20)
                                    }
                                }
                                Button(action: {
                                    showPhotoPicker = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                            .frame(width: 80, height: 80)
                                        Image(systemName: "plus")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
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
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoSelections,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: photoSelections) { newItems in
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    func isValid() -> Bool {
        !productName.isEmpty && !description.isEmpty &&
        !category.isEmpty && Double(price) != nil && Int(quantity) != nil
    }

    func updateProduct() {
        // Save edited product logic here
        dismiss()
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

#Preview {
    SBEditProductView(product: Product.sampleList[0])
}
