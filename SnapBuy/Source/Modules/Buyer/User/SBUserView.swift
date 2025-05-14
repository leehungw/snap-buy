import SwiftUI

enum OrderTab {
    case myOrder
    case history
}

struct SBUserView: View {
    
    @State private var selectedTab: OrderTab = .myOrder
        
    var body: some View {
        SBBaseView {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Text(R.string.localizable.myOrder)
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding(.leading,30)
                    Spacer()
                    Image(systemName: "bag")
                        .padding(.trailing)
                }
                .padding()
                
                // Tabs
                HStack {
                    TabButton(title: "My Order", tab: .myOrder, selectedTab: selectedTab) {
                        selectedTab = .myOrder
                    }
                    Spacer()
                    TabButton(title: "History", tab: .history, selectedTab: selectedTab) {
                        selectedTab = .history
                    }
                }
                .padding(.horizontal, 50)
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedTab == .myOrder {
                            ForEach(orders) { order in
                                SBOrderCardView(order: order)
                            }
                        } else {
                            ForEach(purchased) { item in
                                SBPurchasedCardView(purchased: item)
                            }
                        }
                    }
                    .padding()
                }
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                Spacer()
            }
        }
    }
}

struct SBOrderCardView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(order.imageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.title)
                        .font(R.font.outfitBold.font(size: 18))
                    HStack {
                        Text("Color: ")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.gray)
                        + Text(order.color)
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.black)
                    }

                    HStack {
                        Text("Qty: ")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.gray)
                        + Text("\(order.quantity)")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(order.status)
                        .font(R.font.outfitSemiBold.font(size: 12))
                        .foregroundColor(order.status == "On Progress" ? Color.teal
                                         : order.status == "Complete" ? Color.green
                                         : Color.orange)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(order.status == "On Progress" ? Color.teal
                                        : order.status == "Complete" ? Color.green
                                        : Color.orange, lineWidth: 1)
                        )
                    Text(String(format: "$ %.2f", order.price))
                        .font(R.font.outfitSemiBold.font(size: 20))
                }
            }
            
            HStack {
                Button(action: {
                   
                }) {
                    Text("Detail")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .padding()
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.5))
                        )
                }
                Button(action: {
                   
                }) {
                    Text("Tracking")
                        .frame(maxWidth: .infinity)
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .padding()
                        .background(Color.main)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width*0.8, height: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2))
        )
    }
}


struct SBPurchasedCardView: View {
    @State private var navigateToReview = false
    let purchased: Purchased
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(purchased.imageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(purchased.title)
                        .font(R.font.outfitBold.font(size: 18))
                    HStack {
                        Text("Color: ")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.gray)
                        + Text(purchased.color)
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.black)
                    }
                    
                    HStack {
                        Text("Qty: ")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.gray)
                        + Text("\(purchased.quantity)")
                            .font(R.font.outfitSemiBold.font(size: 14))
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text(purchased.status)
                        .font(R.font.outfitSemiBold.font(size: 12))
                        .foregroundColor(purchased.status == "Complete" ? Color.green
                                         : Color.red)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(purchased.status == "Complete" ? Color.green
                                        : Color.red, lineWidth: 1)
                        )
                    Text(String(format: "$ %.2f", purchased.price))
                        .font(R.font.outfitSemiBold.font(size: 20))
                }
            }
            
            HStack {
                Button(action: {
                    
                }) {
                    Text("Detail")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .padding()
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.5))
                        )
                }
                Button(action: {
                    if purchased.status == "Complete" {
                        navigateToReview = true
                    }
                }) {
                    Text("Review")
                        .frame(maxWidth: .infinity)
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .padding()
                        .background(purchased.status == "Complete" ? Color.main : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .disabled(purchased.status != "Complete")
                NavigationLink(
                    destination: SBWriteReviewView(purchased: purchased),
                    isActive: $navigateToReview,
                    label: { EmptyView() }
                )
                .hidden()
            }
        }
        .frame(width: UIScreen.main.bounds.width*0.8, height: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.2))
        )
    }
}


#Preview {
    SBUserView()
}
