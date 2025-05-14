import SwiftUI

struct SBEditNotiView: View {
    @State private var isPaymentEnabled = true
    @State private var isTrackingEnabled = true
    @State private var isOrderCompleteEnabled = true
    @State private var isGeneralNotificationEnabled = true
    
    var body: some View {
        SBSettingBaseView(title: "Notifications") {
            VStack(spacing: 24) {
                // Notification settings card
                VStack(spacing: 0) {
                    NotificationRow(title: "Payment", isOn: $isPaymentEnabled)
                    Divider()
                    NotificationRow(title: "Tracking", isOn: $isTrackingEnabled)
                    Divider()
                    NotificationRow(title: "Complete Order", isOn: $isOrderCompleteEnabled)
                    Divider()
                    NotificationRow(title: "Notification", isOn: $isGeneralNotificationEnabled)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                
                Spacer()
            }
            .padding(15)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct NotificationRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(R.font.outfitRegular.font(size: 16))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.main)
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    SBEditNotiView()
}
