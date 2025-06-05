import SwiftUI
import PhotosUI

struct SBSellerSettingsView: View {
    @State private var shopName: String = "Minh's Fashion"
    @State private var description: String = "We offer high-quality fashion products for both men and women with a youthful and dynamic style."
    @State private var facebookURL: String = "https://facebook.com/minhsfashion"
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var avatarImage: Image? = nil
    @State private var avatarData: Data? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Header
            Header(title: "Settings", dismiss: dismiss)
            
            // MARK: - Avatar Picker
            ZStack(alignment: .bottomTrailing) {
                if let avatarImage = avatarImage {
                    avatarImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "bag.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .foregroundColor(.gray)
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.blue)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            avatarData = data
                            avatarImage = Image(uiImage: uiImage)
                        }
                    }
                }
            }
            
            // MARK: - Input Fields
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Shop Name")
                        .font(R.font.outfitMedium.font(size: 14))
                        .foregroundColor(.gray)
                    TextField("Enter your shop name", text: $shopName)
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(R.font.outfitMedium.font(size: 14))
                        .foregroundColor(.gray)
                    TextField("Write a short description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Facebook Link")
                        .font(R.font.outfitMedium.font(size: 14))
                        .foregroundColor(.gray)
                    TextField("https://facebook.com/yourpage", text: $facebookURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // MARK: - Save Button
            Button(action: {
                dismiss
            }) {
                Text("Save Changes")
                    .font(R.font.outfitBold.font(size: 16))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SBSellerSettingsView()
}
