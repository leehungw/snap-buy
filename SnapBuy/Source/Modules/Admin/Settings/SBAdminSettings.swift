import SwiftUI

class SBAdminSettingsViewModel: ObservableObject {
    @Published var adminName: String = ""
    @Published var adminEmail: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        fetchAdminData()
    }
    
    func fetchAdminData() {
        isLoading = true
        if let currentUser = UserRepository.shared.currentUser {
            self.adminName = "\(currentUser.name)"
            self.adminEmail = currentUser.email
            isLoading = false
        }
    }
    
    func logout() {
        UserRepository.shared.logout()
        // Handle navigation after logout
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first {
            keyWindow.rootViewController = UIHostingController(rootView: SBLoginView(shouldShowBackButton: false))
            keyWindow.makeKeyAndVisible()
        }
    }
}

struct SBAdminSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SBAdminSettingsViewModel()
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Admin")) {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        HStack {
                            Image(systemName: "person.fill")
                            Spacer()
                            Text(viewModel.adminName)
                        }
                        HStack {
                            Image(systemName: "envelope.fill")
                            Spacer()
                            Text(viewModel.adminEmail)
                        }
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button("Log Out", role: .destructive) {
                            showLogoutAlert = true
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SBAdminSettingsView()
}
