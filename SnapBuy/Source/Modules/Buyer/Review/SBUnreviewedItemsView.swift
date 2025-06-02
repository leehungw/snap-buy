import SwiftUI

struct SBUnreviewedItemsView: View {
    let orderItems: [SBOrderItemModel]
    @Environment(\.dismiss) var dismiss
    
    private var unreviewedItems: [SBOrderItemModel] {
        orderItems.filter { !$0.isReviewed }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Items to Review")
                    .font(R.font.outfitRegular.font(size: 16))
                    .padding(.trailing, 15)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            if unreviewedItems.isEmpty {
                Spacer()
                Text("No items to review")
                    .font(R.font.outfitRegular.font(size: 16))
                    .foregroundColor(.gray)
                Spacer()
            } else {
                // Items List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(unreviewedItems) { item in
                            NavigationLink(destination: SBWriteReviewView(order: item)) {
                                UnreviewedItemRow(item: item)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct UnreviewedItemRow: View {
    let item: SBOrderItemModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Product Image
            AsyncImage(url: URL(string: item.productImageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            
            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.productName)
                    .font(R.font.outfitSemiBold.font(size: 16))
                    .foregroundColor(.black)
                
                if !item.productNote.isEmpty {
                    Text(item.productNote)
                        .font(R.font.outfitRegular.font(size: 14))
                        .foregroundColor(.gray)
                }
                
                Text("Quantity: \(item.quantity)")
                    .font(R.font.outfitRegular.font(size: 14))
                    .foregroundColor(.gray)
                
                Text("$\(String(format: "%.2f", item.unitPrice))")
                    .font(R.font.outfitSemiBold.font(size: 14))
                    .foregroundColor(.main)
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
} 