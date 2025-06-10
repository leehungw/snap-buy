import SwiftUI

struct SBEditProfileView: View {
    @State private var name: String = ""
    @State private var imageUrl: String = ""
    @State private var address: String = ""
    @StateObject private var userModeManager = UserModeManager.shared

    var body: some View {
        SBSettingBaseView(title: "Profile") {
            VStack(spacing: 24) {
                // Profile Image
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image("cat_access")
                        .resizable()
                        .scaledToFill()
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding(.top, 20)
                
                // Switch Mode or Upgrade Button
                if let user = UserRepository.shared.currentUser {
                    if user.isPremium {
                        Button(action: {
                            userModeManager.switchMode()
                        }) {
                            HStack {
                                Image(systemName: userModeManager.currentMode == .seller ? "arrow.left" : "arrow.right")
                                Text(userModeManager.currentMode == .buyer ? "Switch to Seller" : "Switch to Buyer")
                                    .font(R.font.outfitBold.font(size: 16))
                            }
                            .foregroundColor(.main)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.main, lineWidth: 2)
                            )
                        }
                    } else {
                        NavigationLink(destination: SBUpgradeAccountView()) {
                            Text("Upgrade To Seller")
                                .font(R.font.outfitRegular.font(size: 16))
                                .foregroundColor(.white)
                        }
                        .padding(13)
                        .background(Color.main)
                        .cornerRadius(30)
                    }
                }
                
                // Name Display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.main)
                        Text(name)
                            .font(R.font.outfitRegular.font(size: 16))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)

    }
    
   
}

#Preview {
    SBEditProfileView()
}

