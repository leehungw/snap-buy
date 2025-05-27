import SwiftUI

struct SBSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutAlert = false
    @State private var navigateToLogin = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                    Text("Setting")
                        .font(R.font.outfitRegular.font(size:16))
                        .padding(.trailing,10)
                    Spacer()
                }
                .padding()
                List {
                    Section(header: Text("General")) {
                        NavigationLink(destination: SBEditProfileView()) {
                            SettingsRow(icon: "person", title: "Edit Profile")
                        }
                        NavigationLink(destination: SBChangePasswordView()) {
                            SettingsRow(icon: "lock", title: "Change Password")
                        }
                        NavigationLink(destination: SBEditNotiView()) {
                            SettingsRow(icon: "bell", title: "Notifications")
                        }
                        NavigationLink(destination: SBSecurityView()) {
                            SettingsRow(icon: "shield", title: "Security")
                        }
                    }
                    
                    Section(header: Text("Preferences".capitalized)
                        .font(R.font.outfitSemiBold.font(size: 16))) {
                        
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward.circle")
                                    .foregroundColor(.red)
                                Text("Logout")
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .font(R.font.outfitRegular.font(size: 16))
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    UserRepository.shared.logout()
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let keyWindow = windowScene.windows.first {
                        keyWindow.rootViewController = UIHostingController(rootView: SBLoginView(shouldShowBackButton: false))
                        keyWindow.makeKeyAndVisible()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
struct SettingsRow: View {
    let icon: String
    let title: String
    var trailingText: String?

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(.black)
            Text(title)
            Spacer()
            if let trailing = trailingText {
                Text(trailing)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SBSettingsView()
}
