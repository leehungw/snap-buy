import SwiftUI

struct SBAdminOrderDetail: View {
    @State var order: sellerOrder
    let onUpdateStatus: (sellerOrder) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Buyer Information").font(R.font.outfitMedium.font(size: 16))) {
                    Text("Name: \(order.buyer.name)")
                        .font(R.font.outfitRegular.font(size: 14))
                    Text("Address: \(order.buyer.address)")
                        .font(R.font.outfitRegular.font(size: 14))
                    Text("Phone: \(order.buyer.phone)")
                        .font(R.font.outfitRegular.font(size: 14))
                }
                Section(header: Text("Order Items").font(R.font.outfitMedium.font(size: 16))) {
                    ForEach(order.items) { item in
                        HStack {
                            Image(item.imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(R.font.outfitMedium.font(size: 16))
                                Text("Color: \(item.color)")
                                    .font(R.font.outfitRegular.font(size: 13))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text("Qty: \(item.quantity)")
                                .font(R.font.outfitRegular.font(size: 14))
                            Text(formatCurrency(item.price * Double(item.quantity)))
                                .font(R.font.outfitMedium.font(size: 14))
                                .bold()
                        }
                        .padding(.vertical, 4)
                    }
                }
                Section(header: Text("Order Status").font(R.font.outfitMedium.font(size: 16))) {
                    Picker("Status", selection: $order.status) {
                        ForEach(OrderStatus.allCases) { status in
                            Text(status.rawValue).font(R.font.outfitRegular.font(size: 14)).tag(status)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    HStack {
                        Spacer()
                        Button("Save Changes") {
                            onUpdateStatus(order)
                            dismiss()
                        }
                        .font(R.font.outfitMedium.font(size: 16))
                        .foregroundColor(.blue)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
