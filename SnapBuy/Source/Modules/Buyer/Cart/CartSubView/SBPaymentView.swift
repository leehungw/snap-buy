import SwiftUI

struct SBPaymentView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let products: [CartItem]
    let totalPrice: Double
    @State private var navigateToAddress = false
    @State private var showMethodSheet = false
    @State private var showSuccessfullyOrderSheet = false
    @State private var selectedAddress: String = "San Diego, CA"
    @State private var selectedPayment: UUID? = nil
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
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.red)
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text(R.string.localizable.house)
                                .font(R.font.outfitBold.font(size: 16))
                            Text(selectedAddress)
                                .font(R.font.outfitRegular.font(size: 16))
                                .foregroundColor(.gray)
                        }
                        .frame(width: 200)
                    }
                }
                NavigationLink(
                                    destination: SBAddressView(selectedAddress: $selectedAddress),
                                    isActive: $navigateToAddress
                ) {
                    EmptyView()
                }
                
                // Products Section
                VStack(alignment: .leading) {
                    Text(String(R.string.localizable.countProductFormat(products.count)))
                        .font(R.font.outfitBold.font(size: 20))
                    
                    ForEach(products) { product in
                        HStack(spacing: 12) {
                            Image(product.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(R.font.outfitMedium.font(size: 18))
                                Text(R.string.localizable.colorFormat(product.color))
                                    .font(R.font.outfitRegular.font(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            Text(String(format: "$ %.2f", product.price * Double(product.quantity)))
                                .font(R.font.outfitBold.font(size: 15))
                        }
                    }
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
                
                // Total
                VStack(alignment: .leading) {
                    HStack {
                        Text(R.string.localizable.totalAmount())
                            .font(R.font.outfitMedium.font(size: 16))
                            .foregroundColor(.gray)
                        Spacer()
                        HStack(alignment: .top) {
                            Text("$")
                                .font(R.font.outfitBold.font(size: 15))
                            Text(String(format: "%.2f", totalPrice + 6))
                                .font(R.font.outfitBold.font(size: 20))
                        }
                    }
                }
                
                // Checkout Button
                Button(action: {
                    showSuccessfullyOrderSheet = true
                }) {
                    Text(R.string.localizable.checkoutNow())
                        .font(R.font.outfitMedium.font(size: 20))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.main)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                
                Spacer()
            }
            .padding()
            .padding(.horizontal,10)
        }
        .sheet(isPresented: $showMethodSheet) {
                VStack {
                    SBPaymentMethodView(selectedPayment: $selectedPayment)
                }
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
            }
        .sheet(isPresented: $showSuccessfullyOrderSheet) {
                VStack {
                    SBSuccessfulOrderView()
                }
                .presentationDetents([.fraction(0.6)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
            }
        .onAppear {
            if selectedPayment == nil {
                selectedPayment = paymentMethods.first?.id
            }
        }

        .navigationBarBackButtonHidden(true)
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
            Button(action: {
                
            }) {
                Text(R.string.localizable.orderTracking)
                    .font(R.font.outfitMedium.font(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            
        }
        .padding()
        
    }
}

struct SBPaymentMethodView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedPaymentID: UUID? = nil
    @Binding var selectedPayment: UUID?
    
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
    }
}
#Preview {
    SBPaymentView(
        products: Array(CartItem.cartitems.prefix(3)),
        totalPrice: 59.98
    )
}
