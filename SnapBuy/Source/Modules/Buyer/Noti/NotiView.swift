import SwiftUI


struct SBNotificationView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        SBBaseView {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                    Text("Notification")
                        .font(R.font.outfitRegular.font(size: 16))
                    Spacer()
                    NavigationLink(destination: SBSettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(Color.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                Text("Recent")
                    .font(R.font.outfitBold.font(size: 20))
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(notifications) { item in
                            SBNotificationRow(item: item)
                        }
                    }
                    .padding()
                    .padding(.horizontal,10)
                }
            }
        }
    }
}

struct SBNotificationRow: View {
    let item: NotificationItem
    
    var icon: some View {
        switch item.type {
        case .order:
            return Image(systemName: "cart")
                .foregroundColor(.black)
        case .message:
            return Image(systemName: "ellipsis.message")
                .foregroundColor(.black)
        case .sale:
            return Image(systemName: "tag")
                .foregroundColor(.black)
        case .shipment:
            return Image(systemName: "shippingbox")
                .foregroundColor(.black)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                icon
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .background( Color.gray.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Text(item.timeAgo)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Text(item.message)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    if let reply = item.replyText {
                        Text(reply)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            Divider()
        }
    }
}

#Preview {
    SBNotificationView()
}
