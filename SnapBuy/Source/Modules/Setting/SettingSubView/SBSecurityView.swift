
import SwiftUI

struct SBSecurityView: View {
    @State private var isFaceIdEnabled = true
    @State private var isTouchIdEnabled = true
    @State private var isRememberPasswordEnabled = true
    var body: some View {
        SBSettingBaseView(title: "Security") {
            VStack(spacing: 24) {
                // Notification settings card
                VStack(spacing: 0) {
                    NotificationRow(title: "Remember Password", isOn: $isRememberPasswordEnabled)
                    Divider()
                    NotificationRow(title: "Face ID", isOn: $isFaceIdEnabled)
                    Divider()
                    NotificationRow(title: "Touch ID", isOn: $isTouchIdEnabled)                }
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

#Preview {
    SBSecurityView()
}
