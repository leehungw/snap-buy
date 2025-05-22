import SwiftUI

struct UserAdmin: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var role: String
    var isBlocked: Bool
}


struct SBAdminUserManagementView: View {
    @State private var searchText = ""
    @State private var selectedRole: String = "All"
    @Environment(\.dismiss) var dismiss
    @State private var users: [UserAdmin] = [
        UserAdmin(id: UUID(), name: "Minh Le", email: "minh@example.com", role: "seller", isBlocked: false),
        UserAdmin(id: UUID(), name: "Lan Nguyen", email: "lan@example.com", role: "buyer", isBlocked: true),
        UserAdmin(id: UUID(), name: "Admin", email: "admin@example.com", role: "admin", isBlocked: false),
    ]
    
    let roles = ["All", "Admin", "Seller", "Buyer"]

    var filteredUsers: [UserAdmin] {
        users.filter {
            (selectedRole == "All" || $0.role.lowercased() == selectedRole.lowercased()) &&
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
                // Role Filter
                Picker("Role", selection: $selectedRole) {
                    ForEach(roles, id: \.self) { role in
                        Text(role).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEach(filteredUsers) { user in
                        NavigationLink(destination: SBAdminUserDetailView(user: user)) {
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
                                    Text(user.role.capitalized)
                                        .font(R.font.outfitMedium.font(size: 14))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(roleColor(user.role))
                                        .cornerRadius(8)
                                    Spacer()
                                    Button(action: {
                                        toggleBlock(user)
                                    }) {
                                        Image(systemName: user.isBlocked ? "lock.fill" : "lock.open")
                                            .foregroundColor(user.isBlocked ? .red : .green)
                                            .padding(.leading, 8)
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
        .navigationBarBackButtonHidden(true)
    }

    private func toggleBlock(_ user: UserAdmin) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isBlocked.toggle()
        }
    }

    private func roleColor(_ role: String) -> Color {
        switch role.lowercased() {
        case "admin": return .red
        case "seller": return .orange
        default: return .blue
        }
    }
}

#Preview {
    SBAdminUserManagementView()
}

