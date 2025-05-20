import SwiftUI

struct SellerProfileView: View {
    let shopName: String
    let followersCount: Int
    let logoImage: Image
    let description: String
    let facebookURL: URL?
    
    var body: some View {
        NavigationView{
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Text("Profile")
                        .font(R.font.outfitMedium.font(size: 20))
                        .foregroundColor(.white)
                        .padding(.leading,20)
                    Spacer()
                    NavigationLink(destination: SBSellerSettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(Color.white)
                    }
                }
                .padding()
                .background(Color.main)
                logoImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                
                Text(shopName)
                    .font(.custom("Outfit-Medium", size: 24))
                    .fontWeight(.bold)
                
                Text("Go to Buyer")
                    .font(R.font.outfitBold.font(size: 16))
                    .foregroundColor(.main)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.main, lineWidth: 2)
                    )
                
                Text("\(followersCount) follower\(followersCount > 1 ? "s" : "")")
                    .font(.custom("Outfit-Regular", size: 16))
                    .foregroundColor(.secondary)
                
                Text(description)
                    .font(.custom("Outfit-Regular", size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                
                if let fbURL = facebookURL {
                    Link(destination: fbURL) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(.blue)
                            Text("Facebook Page")
                                .font(.custom("Outfit-Regular", size: 16))
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                }
                Spacer()
                Button(role: .destructive) {
                    print("User logged out")
                } label: {
                    Text("Log Out")
                        .font(R.font.outfitBold.font(size: 16))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            
        }
        
    }
}

#Preview {
    SellerProfileView(
        shopName: "Minh's Fashion",
        followersCount: 1240,
        logoImage: Image(systemName: "bag.fill"),
        description: "Chuyên cung cấp các sản phẩm thời trang nam nữ chất lượng cao, phong cách trẻ trung năng động.",
        facebookURL: URL(string: "https://facebook.com/minhsfashion")
    )
}
