import SwiftUI
import PhotosUI

struct SBAddProductView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var productName = ""
    @State private var description = ""
    @State private var price = ""
    @State private var quantity = ""
    @State private var category = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showPhotoPicker = false
    @State private var colorInput = ""
    @State private var addedColors: [String] = []
    @State private var sizeInput = ""
    @State private var addedSizes: [String] = []

    let categories = ["Clothes", "Shoes", "Accessories", "Other"]
    
    var body: some View {
        VStack {
            Header(title: "Add Product", dismiss: dismiss)
            Spacer()
                VStack(spacing: 20) {
                    ProductTextField(title: "Product Name", placeholder: "Enter product name", text: $productName)
                    
                    ProductMultilineField(title: "Description", text: $description)
                    
                    ProductPicker(title: "Category", selection: $category, options: categories)
                    
                    TagInputField(title: "Colors", input: $colorInput, tags: $addedColors)
                    
                    TagInputField(title: "Sizes", input: $sizeInput, tags: $addedSizes)
                    
                    HStack (spacing: 20) {
                        ProductTextField(title: "Price", placeholder: "Enter price", text: $price, keyboardType: .decimalPad)
                        
                        ProductTextField(title: "Quantity", placeholder: "Enter quantity", text: $quantity, keyboardType: .numberPad)
                    }
                    
                    ImagePickerView(selectedImages: $selectedImages, showPicker: $showPhotoPicker)
                }
                .padding(.top,10)
                .padding(.horizontal)
            
            
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
    }

    func isValid() -> Bool {
        !productName.isEmpty && !description.isEmpty &&
        !category.isEmpty && Double(price) != nil && Int(quantity) != nil
    }

    func submitProduct() {
        dismiss()
    }
}


struct ProductTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(R.font.outfitMedium.font(size: 14))
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(R.font.outfitRegular.font(size: 14))
        }
    }
}

struct ProductMultilineField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(R.font.outfitMedium.font(size: 14))
            TextField("Enter \(title.lowercased())", text: $text, axis: .vertical)
                .lineLimit(4...8)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .font(R.font.outfitRegular.font(size: 14))
        }
    }
}

struct ProductPicker: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                
                Text(title)
                    .font(R.font.outfitMedium.font(size: 14))
                Picker("Select \(title)", selection: $selection) {
                    Text("Select \(title)").tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .font(R.font.outfitRegular.font(size: 14))
            }
            Spacer()
        }
    }
}

struct TagInputField: View {
    let title: String
    @Binding var input: String
    @Binding var tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(R.font.outfitMedium.font(size: 14))
            
            HStack {
                TextField("Enter a \(title.lowercased())", text: $input)
                    .font(R.font.outfitRegular.font(size: 14))
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button {
                    if !input.trimmingCharacters(in: .whitespaces).isEmpty {
                        tags.append(input)
                        input = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Image(systemName: "xmark.circle.fill")
                                    .onTapGesture {
                                        tags.removeAll { $0 == tag }
                                    }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }
}

struct ImagePickerView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var showPicker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Product Images")
                .font(R.font.outfitMedium.font(size: 15))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                    }
                    
                    Button {
                        showPicker = true
                    } label: {
                        VStack {
                            Image(systemName: "plus")
                                .font(.title2)
                            Text("Add")
                                .font(R.font.outfitRegular.font(size: 12))
                        }
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

#Preview {
    SBAddProductView()
}
