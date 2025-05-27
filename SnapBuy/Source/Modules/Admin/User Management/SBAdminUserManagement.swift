import SwiftUI


struct SBAdminUserManagementView: View {
    @State private var searchText = ""
    @State private var selectedRole: String = "All"
    @Environment(\.dismiss) var dismiss
    @State private var users: [UserData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let roles = ["All", "Admin", "Seller", "Buyer"]

    var filteredUsers: [UserData] {
        users.filter {
            let userRole = $0.isAdmin ? "Admin" : ($0.isPremium ? "Seller" : "Buyer")
            return (selectedRole == "All" || userRole == selectedRole) &&
            (searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) || $0.email.lowercased().contains(searchText.lowercased()))
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                AdminHeader(title: "User Management", dismiss: dismiss)
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search by name or email", text: $searchText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1))
                .background(Color.white)
                .padding(.horizontal)
                
                Picker("Role", selection: $selectedRole) {
                    ForEach(roles, id: \.self) { role in
                        Text(role).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button("Try Again") {
                        reloadUsers()
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredUsers, id: \.id) { user in
                            NavigationLink(destination: SBAdminUserDetailView(user: user, onUserUpdated: reloadUsers)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.name)
                                            .font(R.font.outfitMedium.font(size: 16))
                                        Text(user.email)
                                            .font(R.font.outfitRegular.font(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    HStack(alignment: .center) {
                                        Text(user.isAdmin ? "Admin" : (user.isPremium ? "Seller" : "Buyer"))
                                            .font(R.font.outfitMedium.font(size: 14))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(roleColor(user))
                                            .cornerRadius(8)
                                        Spacer()
                                        if !user.isAdmin {
                                            Button(action: {
                                                toggleBlock(user)
                                            }) {
                                                Image(systemName: user.isBanned ? "lock.fill" : "lock.open")
                                                    .foregroundColor(user.isBanned ? .red : .green)
                                                    .padding(.leading, 8)
                                            }
                                        }
                                    }
                                    .frame(width: 100)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if users.isEmpty {
                reloadUsers()
            }
        }
    }

    private func reloadUsers() {
        isLoading = true
        errorMessage = nil
        
        UserRepository.shared.fetchAllUsers { result in
            isLoading = false
            switch result {
            case .success(let response):
                if response.result == 1 {
                    self.users = response.data
                } else if let error = response.error {
                    self.errorMessage = error.message
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func toggleBlock(_ user: UserData) {
        if user.isBanned {
            UserRepository.shared.unbanUser(userId: user.id) { result in
                switch result {
                case .success(let response):
                    if response.result == 1 && response.data == 1 {
                        reloadUsers()
                    }
                case .failure(let error):
                    print("Error unblocking user: \(error.localizedDescription)")
                }
            }
        } else {
            UserRepository.shared.banUser(userId: user.id) { result in
                switch result {
                case .success(let response):
                    if response.result == 1 && response.data == 1 {
                        reloadUsers()
                    }
                case .failure(let error):
                    print("Error blocking user: \(error.localizedDescription)")
                }
            }
        }
    }

    private func roleColor(_ user: UserData) -> Color {
        if user.isAdmin {
            return .red
        } else if user.isPremium {
            return .orange
        } else {
            return .blue
        }
    }
}

#Preview {
    SBAdminUserManagementView()
}

