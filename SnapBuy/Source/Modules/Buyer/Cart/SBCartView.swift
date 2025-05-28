import SwiftUI
import Kingfisher

struct SBCartView: View {
    @State private var quantities: [Int: Int] = [:]
    @State private var selectedItems: Set<Int> = []
    @State private var showFooterSheet = false
    @State private var navigateToPayment = false
    @State private var promoText = ""
    @State private var cartProducts: [SBProduct] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showDeleteConfirmation = false
    @State private var productToDelete: SBProduct?
    @Environment(\.dismiss) var dismiss
    
    enum CartViewStyle {
        case full, delete
    }
    
    @State private var viewStyle: CartViewStyle = .full
    
    var body: some View {
        SBBaseView {
            HStack {
                Button(action: {
                    toggleSelectAll()
                }) {
                    HStack {
                        Image(systemName: allItemsSelected() ? "checkmark.square.fill" : "square")
                        Text(allItemsSelected() ? "Unselect All" : "Select All")
                            .font(R.font.outfitMedium.font(size: 14))
                    }
                    .foregroundColor(.main)
                    .frame(width: 105)
                }

                Spacer()

                Text(R.string.localizable.myCart())
                    .font(R.font.outfitRegular.font(size: 16))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if cartProducts.isEmpty {
                Text("Your cart is empty")
                    .font(R.font.outfitMedium.font(size: 16))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    ForEach(cartProducts) { product in
                        fullCartItemView(product: product)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .alert("Remove from Cart", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                if let product = productToDelete {
                    quantities[product.id] = 1
                }
                productToDelete = nil
            }
            Button("Remove", role: .destructive) {
                if let product = productToDelete {
                    deleteProduct(product)
                }
                productToDelete = nil
            }
        } message: {
            Text("Do you want to remove this item from your cart?")
        }
        .onAppear {
            loadCartProducts()
        }
        .onChange(of: selectedItems) { newValue in
            showFooterSheet = !newValue.isEmpty
        }
        .sheet(isPresented: $showFooterSheet) {
            footerView
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func loadCartProducts() {
        isLoading = true
        errorMessage = nil
        
        let cartItems = SBUserDefaultService.instance.cartItems
        var loadedProducts: [SBProduct] = []
        let group = DispatchGroup()
        
        for item in cartItems {
            group.enter()
            ProductRepository.shared.fetchProductById(productId: item.productId) { result in
                switch result {
                case .success(let product):
                    loadedProducts.append(product)
                    quantities[product.id] = item.quantity
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.cartProducts = loadedProducts
            self.isLoading = false
        }
    }
    
    private func deleteProduct(_ product: SBProduct) {
        var currentCartItems = SBUserDefaultService.instance.cartItems
        currentCartItems.removeAll { item in
            item.productId == product.id
        }
        SBUserDefaultService.instance.cartItems = currentCartItems
        cartProducts.removeAll { $0.id == product.id }
        quantities.removeValue(forKey: product.id)
        selectedItems.remove(product.id)
    }
    
    // MARK: - Full View
    @ViewBuilder
    func fullCartItemView(product: SBProduct) -> some View {
        let bindingQuantity = Binding<Int>(
            get: { quantities[product.id, default: 1] },
            set: { newValue in
                if newValue == 0 {
                    productToDelete = product
                    showDeleteConfirmation = true
                } else {
                    quantities[product.id] = newValue
                    // Update quantity in UserDefaults
                    var currentCartItems = SBUserDefaultService.instance.cartItems
                    if let index = currentCartItems.firstIndex(where: { $0.productId == product.id }) {
                        currentCartItems[index] = SBCartStorageItem(
                            productId: product.id,
                            variantId: currentCartItems[index].variantId,
                            quantity: newValue
                        )
                        SBUserDefaultService.instance.cartItems = currentCartItems
                    }
                }
            }
        )
        
        VStack {
            HStack(alignment: .center, spacing: 12) {
                Toggle("", isOn: Binding(
                    get: { selectedItems.contains(product.id) },
                    set: { isOn in
                        if isOn {
                            selectedItems.insert(product.id)
                        } else {
                            selectedItems.remove(product.id)
                        }
                    }
                ))
                .toggleStyle(CheckboxToggleStyle())
                .frame(width: 30)
                .padding(.top, 10)
                
                HStack(spacing: 12) {
                    if let imageUrl = product.productImages.first?.url {
                        KFImage(URL(string: imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 100)
                            .cornerRadius(15)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(product.name)
                            .font(R.font.outfitMedium.font(size: 18))
                        if let variant = product.productVariants.first {
                            HStack(spacing: 8) {
                                Text("Color: ")
                                    .font(R.font.outfitRegular.font(size: 13))
                                    .foregroundColor(.gray)
                                Circle()
                                    .fill(Color(hex: variant.color) ?? .gray)
                                    .frame(width: 16, height: 16)
                                Text("Size: \(variant.size)")
                                    .font(R.font.outfitRegular.font(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        Spacer()
                       
                        HStack(alignment: .bottom) {
                            HStack(spacing: 10) {
                                Button(action: {
                                    if bindingQuantity.wrappedValue > 0 {
                                        bindingQuantity.wrappedValue -= 1
                                    }
                                }) {
                                    Image(systemName: "minus")
                                        .frame(width: 12, height: 12)
                                        .padding(8)
                                        .foregroundColor(.black)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }

                                Text("\(bindingQuantity.wrappedValue)")
                                    .frame(width: 18)
                                    .font(R.font.outfitBold.font(size: 15))

                                Button(action: {
                                    if bindingQuantity.wrappedValue < product.quantity {
                                        bindingQuantity.wrappedValue += 1
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .frame(width: 12, height: 12)
                                        .padding(8)
                                        .foregroundColor(bindingQuantity.wrappedValue >= product.quantity ? .gray : .black)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                            }
                            .frame(width: 100, height: 35)
                            
                            Spacer()
                            HStack(alignment: .top) {
                                Text("$")
                                    .font(R.font.outfitBold.font(size: 15))
                                Text(String(format: "%.2f", product.basePrice * Double(bindingQuantity.wrappedValue)))
                                    .font(R.font.outfitSemiBold.font(size: 30))
                            }
                        }
                    }
                }
            }
            Divider()
        }
        .padding(.vertical, 15)
    }
    
    // MARK: - Footer
    var footerView: some View {
        NavigationView {
            VStack {
                VStack(spacing: 20){
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.title2)
                        TextField(R.string.localizable.enterYourPromoCode(), text: $promoText)
                            .foregroundColor(.black)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray.opacity(0.7))
                            .font(.title3)
                    }
                    .padding(.horizontal)
                    .padding(.vertical,15)
                    
                    .background(.gray.opacity(0.1))
                    .frame(maxWidth: 380)
                    .cornerRadius(15)
                    HStack {
                        Text(R.string.localizable.subtotal)
                            .font(R.font.outfitMedium.font(size: 16))
                            .foregroundColor(.gray)
                        Spacer()
                        HStack(alignment: .top) {
                            Text("$")
                                .font(R.font.outfitBold.font(size: 15))
                            Text(String(format: "%.2f", totalPrice()))
                                .font(R.font.outfitBold.font(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    HStack {
                        Text(R.string.localizable.shipping)
                            .font(R.font.outfitMedium.font(size: 16))
                            .foregroundColor(.gray)
                        Spacer()
                        HStack(alignment: .top) {
                            Text("$")
                                .font(R.font.outfitBold.font(size: 15))
                            Text(String(format: "%.2f", 6.00))
                                .font(R.font.outfitBold.font(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    HStack {
                        Text(R.string.localizable.totalAmount)
                            .font(R.font.outfitMedium.font(size: 16))
                            .foregroundColor(.gray)
                        Spacer()
                        HStack(alignment: .top) {
                            Text("$")
                                .font(R.font.outfitBold.font(size: 15))
                            Text(String(format: "%.2f", totalPrice() + 6))
                                .font(R.font.outfitBold.font(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                Spacer()
                Button {
                    navigateToPayment = true
                    showFooterSheet = false
                } label: {
                    
                    Text("Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(R.font.outfitMedium.font(size: 20))
                        .background(Color.main)
                        .foregroundColor(.white)
                        .cornerRadius(50)
                        .padding(.horizontal)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Total
    func totalPrice() -> Double {
        cartProducts.reduce(0) { result, product in
            if selectedItems.contains(product.id) {
                let quantity = quantities[product.id, default: 1]
                return result + product.basePrice * Double(quantity)
            } else {
                return result
            }
        }
    }
    
    // MARK: - Total Selected Products
    func selectedCartProducts() -> [SBProduct] {
        return cartProducts.filter { selectedItems.contains($0.id) }
    }
    
    func allItemsSelected() -> Bool {
        !cartProducts.isEmpty && cartProducts.allSatisfy { selectedItems.contains($0.id) }
    }

    func toggleSelectAll() {
        if allItemsSelected() {
            selectedItems.removeAll()
        } else {
            selectedItems = Set(cartProducts.map { $0.id })
        }
    }
}

// MARK: - Checkbox Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .font(.system(size: 25))
                .foregroundColor(configuration.isOn ? .main : .gray)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Preview
#Preview {
    SBCartView()
}

