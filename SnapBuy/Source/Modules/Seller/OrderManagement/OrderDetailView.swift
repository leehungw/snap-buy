import SwiftUI

struct OrderDetailView: View {
    let order: sellerOrder
    @Environment(\.dismiss) var dismiss
    @State private var showAllItems = false

    var body: some View {
        VStack {
            Header(title: "Order #\(order.id.uuidString.prefix(6))", dismiss: dismiss)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Buyer Information")
                            .padding(.horizontal)
                        VStack(alignment: .leading, spacing: 12) {
                            
                            buyerInfoRow(label: "Name", value: order.buyer.name)
                            buyerInfoRow(label: "Phone", value: order.buyer.phone)
                            buyerInfoRow(label: "Address", value: order.buyer.address, multiline: true)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Order Items Section
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Order Items")
                        
                        let displayedItems = showAllItems ? order.items : Array(order.items.prefix(2))
                        
                        ForEach(displayedItems) { item in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 16) {
                                    Image(item.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(12)

                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(item.title)
                                            .font(.custom("Outfit", size: 18))
                                            .fontWeight(.semibold)

                                        VStack(spacing: 8) {
                                            itemInfoRow(label: "Color", value: item.color)
                                            itemInfoRow(label: "Quantity", value: "\(item.quantity)")
                                            itemInfoRow(label: "Price per item", value: String(format: "$%.2f", item.price))

                                            Divider()

                                            HStack {
                                                Text("Subtotal")
                                                    .font(.custom("Outfit", size: 16))
                                                    .fontWeight(.semibold)
                                                Spacer()
                                                Text(String(format: "$%.2f", item.price * Double(item.quantity)))
                                                    .font(.custom("Outfit", size: 16))
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        
                            if order.items.count > 2 {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            showAllItems.toggle()
                                        }
                                    }) {
                                        Text(showAllItems ? "Show Less" : "Show More")
                                            .font(.custom("Outfit", size: 16))
                                            .fontWeight(.medium)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        sectionTitle("Summary")
                            .padding(.horizontal)
                        VStack {
                            HStack {
                                Text("Total Quantity")
                                    .font(.custom("Outfit", size: 16))
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(order.totalQuantity)")
                                    .font(.custom("Outfit", size: 20))
                                    .fontWeight(.bold)
                            }
                            HStack {
                                Text("Total Amount")
                                    .font(.custom("Outfit", size: 16))
                                    .fontWeight(.bold)
                                Spacer()
                                Text(String(format: "$%.2f", order.totalAmount))
                                    .font(.custom("Outfit", size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Order Status Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            sectionTitle("Order Status")
                            Spacer()
                            Text(order.status.rawValue)
                                .font(.custom("Outfit", size: 16))
                                .foregroundColor(colorForStatus(order.status))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(colorForStatus(order.status).opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Section Title View
    @ViewBuilder
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(R.font.outfitBold.font(size: 18))
    }

    // MARK: - Buyer Info Row
    private func buyerInfoRow(label: String, value: String, multiline: Bool = false) -> some View {
        HStack(alignment: multiline ? .top : .center) {
            Text(label)
                .font(.custom("Outfit", size: 16))
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
                .font(.custom("Outfit", size: 16))
        }
    }

    // MARK: - Item Info Row
    private func itemInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.custom("Outfit", size: 16))
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .font(.custom("Outfit", size: 16))
        }
    }
}

#Preview {
    OrderDetailView(order: sellerOrder.sample[0])
}
