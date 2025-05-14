import SwiftUI

struct SBCartView: View {
    @State private var quantities: [UUID: Int] = [:]
    @State private var selectedItems: Set<UUID> = []
    @State private var showFooterSheet = false
    @State private var navigateToPayment = false
    @State private var promoText = ""
    @Environment(\.dismiss) var dismiss
    
    enum CartViewStyle {
        case full, delete
    }
    
    @State private var viewStyle: CartViewStyle = .full
    
    var body: some View {
        SBBaseView {
            headerView
            ScrollView(showsIndicators: false) {
                ForEach(CartItem.cartitems) { item in
                    if viewStyle == .full {
                        fullCartItemView(item: item)
                    } else {
                        deleteCartItemView(item: item)
                    }
                }
                .padding(.horizontal, 20)
                NavigationLink(
                    destination: SBPaymentView(products: selectedCartItems(), totalPrice: totalPrice()),
                    isActive: $navigateToPayment
                ) {
                    EmptyView()
                }
            }
        }
        .onAppear {
            for item in CartItem.cartitems {
                if quantities[item.id] == nil {
                    quantities[item.id] = 1
                }
            }
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
    // MARK: - Header
    var headerView: some View {
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
                .padding(.trailing, 80)

            Spacer()

            Button(action: {
                if viewStyle == .delete && !selectedItems.isEmpty {
                    deleteSelectedItems()
                } else {
                    viewStyle = viewStyle == .full ? .delete : .full
                }
            }) {
                Image(systemName: viewStyle == .delete && !selectedItems.isEmpty ? "trash" : "bag")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
    
    func deleteSelectedItems() {
        for id in selectedItems {
            quantities.removeValue(forKey: id)
        }
        selectedItems.removeAll()
    }
    
    func allItemsSelected() -> Bool {
        CartItem.cartitems.allSatisfy { selectedItems.contains($0.id) }
    }

    func toggleSelectAll() {
        if allItemsSelected() {
            selectedItems.removeAll()
        } else {
            selectedItems = Set(CartItem.cartitems.map { $0.id })
        }
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
        CartItem.cartitems.reduce(0) { result, item in
            if selectedItems.contains(item.id) {
                let quantity = quantities[item.id, default: 1]
                return result + item.price * Double(quantity)
            } else {
                return result
            }
        }
    }
    // MARK: - Total Selected Items
    func selectedCartItems() -> [CartItem] {
        return CartItem.cartitems.filter { selectedItems.contains($0.id) }
    }
    

    // MARK: - Full View
    @ViewBuilder
    func fullCartItemView(item: CartItem) -> some View {
        let bindingQuantity = quantityBinding(for: item)
        VStack {
            HStack(alignment: .center, spacing: 12) {
                Toggle("", isOn: Binding(
                    get: { selectedItems.contains(item.id) },
                    set: { isOn in
                        if isOn {
                            selectedItems.insert(item.id)
                        } else {
                            selectedItems.remove(item.id)
                        }
                    }
                ))
                .toggleStyle(CheckboxToggleStyle())
                .frame(width: 30)
                .padding(.top, 10)
                
                HStack(spacing: 12) {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 100)
                        .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.title)
                            .font(R.font.outfitMedium.font(size: 18))
                        Text(R.string.localizable.colorFormat(item.color))
                            .font(R.font.outfitRegular.font(size: 13))
                            .foregroundColor(.gray)
                        Spacer()
                       
                        HStack(alignment: .bottom) {
                            quantityControl(bindingQuantity)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(20)
                            Spacer()
                            HStack(alignment: .top) {
                                Text("$")
                                    .font(R.font.outfitBold.font(size: 15))
                                Text(String(format: "%.2f", item.price))
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
    // MARK: - Delete View
    @ViewBuilder
    func deleteCartItemView(item: CartItem) -> some View {
        let bindingQuantity = quantityBinding(for: item)

        VStack {
            ZStack() {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipped()
                    
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedItems.remove(item.id)
                            quantities.removeValue(forKey: item.id)
                        }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.system(size: 25))
                                .foregroundColor(.red)
                        }
                        .padding(5)
                        .zIndex(2)
                    }
                    quantityControl(bindingQuantity)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                        .padding(10)
                        .shadow(radius: 10)
                        .zIndex(2)
                }
            }
            .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 0)
                )

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(R.font.outfitMedium.font(size: 18))
                    Text("Color: \(item.color)")
                        .font(R.font.outfitRegular.font(size: 15))
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(alignment: .top) {
                    Text("$")
                        .font(R.font.outfitBold.font(size: 15))
                    Text(String(format: "%.2f", item.price))
                        .font(R.font.outfitSemiBold.font(size: 30))
                }
            }
            
            .padding(.bottom, 30)
        }
    }

    // MARK: - Quantity Binding Helper
    func quantityBinding(for item: CartItem) -> Binding<Int> {
        Binding<Int>(
            get: { quantities[item.id, default: item.quantity] },
            set: { quantities[item.id] = $0 }
        )
    }

    // MARK: - Quantity Control UI
    func quantityControl(_ quantity: Binding<Int>) -> some View {
        HStack(spacing: 10) {
            Button(action: {
                if quantity.wrappedValue > 1 {
                    quantity.wrappedValue -= 1
                }
            }) {
                Image(systemName: "minus")
                    .frame(width: 12, height: 12)
                    .padding(8)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
            }

            Text("\(quantity.wrappedValue)")
                .frame(width: 18)
                .font(R.font.outfitBold.font(size: 15))

            Button(action: {
                quantity.wrappedValue += 1
            }) {
                Image(systemName: "plus")
                    .frame(width: 12, height: 12)
                    .padding(8)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
        .frame(width: 100, height: 35)
        .background(Color.gray.opacity(0.2))
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
