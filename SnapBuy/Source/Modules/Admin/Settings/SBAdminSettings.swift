import SwiftUI

struct SBAdminSettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Admin")) {
                    HStack {
                        Image(systemName: "person.fill")
                        Spacer()
                        Text("Minh Le")
                    }
                    HStack {
                        Image(systemName: "envelope.fill")
                        Spacer()
                        Text("admin@example.com")
                    }
                }
                Section {
                    HStack {
                        Spacer()
                        Button("Log Out", role: .destructive) {
                            
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
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SBAdminSettingsView()
}
