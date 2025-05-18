import SwiftUI

struct SBEditProfileView: View {
    @State private var username: String = "Magdalena Succrose"
    @State private var email: String = "magdalena83@mail.com"
    @State private var isSeller: Bool = false
    var body: some View {
        SBSettingBaseView(title: "Edit Profile") {
            VStack(spacing: 24) {
                Image("cat_access")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(.top, 20)
                HStack {
                    if isSeller {
                        Text("Go to Seller")
                            .font(R.font.outfitBold.font(size: 16))
                            .foregroundColor(.main)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.main, lineWidth: 2)
                            )
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.main)
                        TextField("Username", text: $username)
                            .font(R.font.outfitRegular.font(size: 16))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                // Email or Phone Number
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email or Phone Number")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.main)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .font(R.font.outfitRegular.font(size: 16))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                
                // Linked Account
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Liked With")
                        .font(R.font.outfitSemiBold.font(size: 16))
                    HStack {
                        Image("img_google_icon")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.trailing,10)
                        Text("Google")
                            .foregroundColor(.black)
                            .font(R.font.outfitRegular.font(size: 16))
                        Spacer()
                        Image(systemName: "link")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                }
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .font(R.font.outfitSemiBold.font(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.main)
                        .cornerRadius(30)
                }
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    SBEditProfileView()
}
