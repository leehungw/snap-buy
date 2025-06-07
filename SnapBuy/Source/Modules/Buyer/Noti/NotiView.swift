import SwiftUI


struct SBNotificationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var notifications: [SBNotification] = []
    @State private var isLoading = false
    @State private var error: String?
    
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
                
                if isLoading {
                    ProgressView().padding()
                } else if let error = error {
                    Text(error).foregroundColor(.red).padding()
                } else {
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
        .onAppear(perform: fetchNotifications)
    }
    
    private func fetchNotifications() {
        guard let userId = UserRepository.shared.currentUser?.id else { return }
        isLoading = true
        error = nil
        NotificationRepository.shared.fetchNotifications(for: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let notis):
                    notifications = notis
                case .failure(let err):
                    error = err.localizedDescription
                }
            }
        }
    }
}

struct SBNotificationRow: View {
    let item: SBNotification
    
    var icon: some View {
        switch item.eventType.lowercased() {
        case "neworder":
            return Image(systemName: "cart").foregroundColor(.black)
        case "message":
            return Image(systemName: "ellipsis.message").foregroundColor(.black)
        case "sale":
            return Image(systemName: "tag").foregroundColor(.black)
        case "shipment":
            return Image(systemName: "shippingbox").foregroundColor(.black)
        default:
            return Image(systemName: "bell").foregroundColor(.black)
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
                        Text(item.eventType)
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        // No timeAgo in backend, could add if needed
                    }
                    
                    Text(item.message)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            Divider()
        }
    }
}

#Preview {
    SBNotificationView()
}
