import SwiftUI
import PayPal
import Kingfisher
import MapKit

struct LocationMapView: View {
    let coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map(coordinateRegion: .constant(MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )), annotationItems: [coordinate]) { location in
            MapMarker(coordinate: location)
        }
        .frame(height: 150)
        .cornerRadius(12)
    }
}

extension CLLocationCoordinate2D: Identifiable {
    public var id: String {
        "\(latitude)-\(longitude)"
    }
}

struct SBPaymentView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @State private var navigateToUserView = false
    
    let products: [CartItem]
    let totalPrice: Double
    @State private var navigateToAddress = false
    @State private var showMethodSheet = false
    @State private var selectedAddress: String = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedPayment: UUID? = paymentMethods[0].id
    @StateObject private var addressViewModel = SBAddressViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    @State private var phoneNumber: String = ""
    @State private var showPhoneAlert = false
    @State private var sellerMerchantId: String? = nil
    @State private var availablePaymentMethods: [PaymentMethod] = paymentMethods
    
    private var selectedPaymentMethod: PaymentMethod? {
        paymentMethods.first { $0.id == selectedPayment }
    }
    
    private func handleCheckout() {
        if phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showPhoneAlert = true
            return
        }
        guard let selectedMethod = selectedPaymentMethod else { return }
        
        let shippingAddress = selectedAddress.isEmpty ? addressViewModel.currentAddress : selectedAddress
        let total = totalPrice + 6
        if selectedMethod.name == "COD" {
            paymentViewModel.createOrder(products: products, totalAmount: total, shippingAddress: shippingAddress, phoneNumber: phoneNumber) { success, error in
                if success {
                            navigateToUserView = true
                        }
            }
        } else if selectedMethod.name == "PayPal" {
            Task {
                await paymentViewModel.processPayment(products: products, totalAmount: total)
                if paymentViewModel.errorMessage == nil {
                    paymentViewModel.createOrder(products: products, totalAmount: total, shippingAddress: shippingAddress, phoneNumber: phoneNumber) { success, error in
                        if success {
                                    navigateToUserView = true
                                }
                    }
                }
            }
        }
    }
    
    var body: some View {
        SBBaseView {
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text(R.string.localizable.payment())
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding(.trailing,10)
                    Spacer()
                }
                .padding(.bottom, 10)
                
                // Address Section
                ScrollView(showsIndicators: false) {
                    VStack {
                        HStack {
                            Text(R.string.localizable.address)
                                .font(R.font.outfitBold.font(size: 20))
                            Spacer()
                            Button(action: {
                                navigateToAddress = true
                            }) {
                                Text(R.string.localizable.edit)
                                    .font(R.font.outfitRegular.font(size: 13))
                                    .foregroundColor(Color.main)
                            }
                        }
                        
                        if addressViewModel.isLoadingLocation {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                        } else if let coordinate = selectedCoordinate ?? addressViewModel.coordinate {
                            LocationMapView(coordinate: coordinate)
                        }
                        
                        if !addressViewModel.currentAddress.isEmpty || !selectedAddress.isEmpty {
                            Text(selectedAddress.isEmpty ? addressViewModel.currentAddress : selectedAddress)
                                .font(R.font.outfitRegular.font(size: 16))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                    }
                    NavigationLink(
                        destination: SBAddressView(
                            selectedAddress: $selectedAddress,
                            selectedCoordinate: $selectedCoordinate
                        ),
                        isActive: $navigateToAddress
                    ) {
                        EmptyView()
                    }
                    // Phone number input
                    HStack {
                        Text("Phone Number")
                            .font(R.font.outfitRegular.font(size: 16))
                        TextField("Enter your phone number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.top, 8)
                    
                    // Products Section
                    VStack(alignment: .leading) {
                        Text(String(R.string.localizable.countProductFormat(products.count)))
                            .font(R.font.outfitBold.font(size: 20))
                            .padding(.vertical, 8)
                        
                        ForEach(products) { product in
                            HStack(spacing: 12) {
                                if let url = URL(string: product.imageName) {
                                    KFImage(url)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(10)
                                } else {
                                    Image(product.imageName)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(10)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.title)
                                        .font(R.font.outfitMedium.font(size: 18))
                                    HStack(spacing: 8) {
                                        Text("Color:")
                                            .font(R.font.outfitRegular.font(size: 13))
                                            .foregroundColor(.gray)
                                        Circle()
                                            .fill(Color(hex: product.color) ?? .gray)
                                            .frame(width: 16, height: 16)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.gray, lineWidth: 0.5)
                                            )
                                        Text("Size: \(product.size)")
                                            .font(R.font.outfitRegular.font(size: 13))
                                            .foregroundColor(.gray)
                                        Text("Qty: \(product.quantity)")
                                            .font(R.font.outfitRegular.font(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                                Text(String(format: "$%.2f", product.price * Double(product.quantity)))
                                    .font(R.font.outfitBold.font(size: 15))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    
                    
                    
                    NavigationLink(
                        destination: SBAddressView(
                            selectedAddress: $selectedAddress,
                            selectedCoordinate: $selectedCoordinate
                        ),
                        isActive: $navigateToAddress
                    ) {
                        EmptyView()
                    }
                    
                    // Payment Method
                    VStack(alignment: .leading) {
                        Text(R.string.localizable.paymentMethod)
                            .font(R.font.outfitBold.font(size: 20))
                        
                        if let selected = paymentMethods.first(where: { $0.id == selectedPayment }) {
                            HStack {
                                Image(selected.imageName)
                                    .resizable()
                                    .frame(width: 40, height: 30)
                                
                                VStack(alignment: .leading) {
                                    Text(selected.name)
                                        .font(R.font.outfitMedium.font(size: 16))
                                    Text(selected.subtitle)
                                        .font(R.font.outfitRegular.font(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                            .onTapGesture {
                                showMethodSheet = true
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Total Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Order Summary")
                            .font(R.font.outfitBold.font(size: 20))
                            .padding(.bottom, 5)
                        
                        // Subtotal
                        if let selected = availablePaymentMethods.first(where: { $0.id == selectedPayment }) {
                            HStack {
                                Text("Subtotal")
                                    .font(R.font.outfitMedium.font(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "$%.1f", products.reduce(0) { $0 + $1.price * Double($1.quantity) }))
                                    .font(R.font.outfitMedium.font(size: 16))
                            }
                            
                            // Shipping Fee
                            HStack {
                                Text("Shipping Fee")
                                    .font(R.font.outfitMedium.font(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$6.0")
                                    .font(R.font.outfitMedium.font(size: 16))
                            }
                            
                            // Discount (if any)
                            let subtotal = products.reduce(0) { $0 + $1.price * Double($1.quantity) }
                            if totalPrice < subtotal + 6.0 {
                                HStack {
                                    Text("Discount")
                                        .font(R.font.outfitMedium.font(size: 16))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "-$%.1f", (subtotal + 6.0) - totalPrice))
                                        .font(R.font.outfitMedium.font(size: 16))
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 5)
                            
                            // Total
                            HStack {
                                Text("Total Amount")
                                    .font(R.font.outfitMedium.font(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "$%.1f", totalPrice))
                                    .font(R.font.outfitBold.font(size: 20))
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    //                    .shadow(color: .gray.opacity(0.1), radius: 5)
                    
                    if paymentViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        
                        if let error = paymentViewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(R.font.outfitRegular.font(size: 14))
                                .padding(.horizontal)
                        }
                        
                        // Checkout Button
                        Button(action: handleCheckout) {
                            Text(R.string.localizable.checkoutNow())
                                .font(R.font.outfitMedium.font(size: 20))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.main)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                        .disabled(paymentViewModel.isLoading)
                        .padding()
                        NavigationLink(destination: SBUserView(), isActive: $navigateToUserView) {
                            EmptyView()
                        }
                    }
                }
            }
            .padding()
            .padding(.horizontal,10)
        }
        .sheet(isPresented: $showMethodSheet) {
            VStack {
                SBPaymentMethodView(selectedPayment: $selectedPayment, paymentMethods: availablePaymentMethods)
            }
            .presentationDetents([.fraction(0.6)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(50)
        }
        .sheet(isPresented: $paymentViewModel.showSuccessfullyOrderSheet) {
            VStack {
                SBSuccessfulOrderView()
            }
            .presentationDetents([.fraction(0.6)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(50)
        }
        .onAppear {
            if selectedPayment == nil {
                selectedPayment = paymentMethods[0].id
            }
            addressViewModel.requestLocation()
            // Post notification to hide tab bar
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
            
            // Fetch seller merchant id
            if let sellerId = products.first?.sellerId {
                UserRepository.shared.fetchUserById(userId: sellerId) { result in
                    switch result {
                    case .success(let user):
                        sellerMerchantId = user.sellerMerchantId
                        if let merchantId = user.sellerMerchantId, !merchantId.isEmpty {
                            availablePaymentMethods = paymentMethods
                        } else {
                            availablePaymentMethods = paymentMethods.filter { $0.name == "COD" }
                            // If current selection is not COD, reset
                            if let selected = selectedPayment, !availablePaymentMethods.contains(where: { $0.id == selected }) {
                                selectedPayment = availablePaymentMethods.first?.id
                            }
                        }
                    case .failure:
                        availablePaymentMethods = paymentMethods.filter { $0.name == "COD" }
                        if let selected = selectedPayment, !availablePaymentMethods.contains(where: { $0.id == selected }) {
                            selectedPayment = availablePaymentMethods.first?.id
                        }
                    }
                }
            }
        }
        .onDisappear {
            // Post notification to show tab bar
            NotificationCenter.default.post(name: .showTabBar, object: nil)
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showPhoneAlert) {
            Alert(
                title: Text("Phone Number Required"),
                message: Text("Please enter your phone number before checking out."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct SBSuccessfulOrderView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("img_successfulorder")
                .resizable()
                .frame(width: 200, height: 200)
            Text(R.string.localizable.orderSuccessfully)
                .font(R.font.outfitBold.font(size: 25))
                .padding(.vertical,10)
            Text(R.string.localizable.successfulOrder)
                .font(R.font.outfitRegular.font(size: 15))
                .foregroundColor(.gray)
                .frame(maxWidth: 300, alignment: .center)
            Spacer()
        }
        .padding()
    }
}

struct SBPaymentMethodView: View {
    @SwiftUI.Environment(\.dismiss) var dismiss
    @State private var selectedPaymentID: UUID?
    @Binding var selectedPayment: UUID?
    let paymentMethods: [PaymentMethod]
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Text(R.string.localizable.paymentMethod)
                .font(R.font.outfitBold.font(size: 20))
                .padding()
            VStack(spacing: 12) {
                ForEach(paymentMethods) { method in
                    HStack {
                        Image(method.imageName)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding(.trailing, 10)
                        VStack(alignment: .leading) {
                            Text(method.name)
                                .font(R.font.outfitMedium.font(size: 16))
                            Text(method.subtitle)
                                .font(R.font.outfitRegular.font(size: 14))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: selectedPaymentID == method.id ? "checkmark.square.fill" : "square")
                            .font(.title2)
                            .foregroundColor(selectedPaymentID == method.id ? Color.main : Color.gray.opacity(0.2))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedPaymentID == method.id ? Color.main : Color.gray.opacity(0.2), lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedPaymentID = method.id
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()

            Button(action: {
                if let selectedID = selectedPaymentID {
                    selectedPayment = selectedID
                    dismiss()
                }
            }) {
                Text(R.string.localizable.confirmPayment)
                    .font(R.font.outfitMedium.font(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
        }
        .padding()
        .onAppear {
            selectedPaymentID = selectedPayment
        }
    }
}
#Preview {
    SBPaymentView(
        products: [
            CartItem(
                productId: 1,
                variantId: 1,
                sellerId: "seller1",
                imageName: "product_1",
                title: "Sample Product",
                color: "FF0000",
                size: "M",
                price: 29.99,
                quantity: 2
            )
        ],
        totalPrice: 59.98
    )
}
