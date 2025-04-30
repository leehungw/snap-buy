import SwiftUI

struct SBMessageView : View {
    
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    
    var body: some View {
        SBBaseView {
            VStack (alignment: .leading, spacing: 30) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text(R.string.localizable.message)
                        .font(R.font.outfitRegular.font(size: 16))
                        .padding(.trailing,10)
                    Spacer()
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                    
                    TextField(R.string.localizable.searchSomething(), text: $searchText)
                        .foregroundColor(.black)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                .padding(.vertical, 15)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
                VStack(alignment: .leading) {
                    Text(R.string.localizable.activities)
                        .font(R.font.outfitBold.font(size: 20))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(sampleUsers) { user in
                                NavigationLink(destination: SBChatView(user: user)) {
                                    VStack(alignment: .center, spacing: 10) {
                                        Image(user.imageName)
                                            .resizable()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                            .background(Circle().stroke(Color.main, lineWidth:5))
                                            .padding(.top,5)
                                            .padding(.leading,5)
                                        Text(user.name)
                                            .font(R.font.outfitSemiBold.font(size: 16))
                                    }
                                }
                            }
                        }
                    }
                    
                }
                VStack(alignment: .leading) {
                    Text(R.string.localizable.messages)
                        .font(R.font.outfitBold.font(size: 20))
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(sampleMessages) { message in
                                NavigationLink(destination: SBChatView(user: message.sender)) {
                                    HStack(alignment: .top) {
                                        Image(message.sender.imageName)
                                            .resizable()
                                            .frame(width: 70, height: 70)
                                            .clipShape(Circle())
                                            .background(Circle().stroke(Color.main, lineWidth:5))
                                            .padding(.top,5)
                                            .padding(.leading,5)
                                            .padding(.trailing,10)
                                        VStack(alignment: .leading) {
                                            Text(message.sender.name)
                                                .font(R.font.outfitSemiBold.font(size: 16))
                                                .padding(.bottom,3)
                                            Text(message.content)
                                                .font(R.font.outfitRegular.font(size: 13))
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.leading)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text(message.timeAgo)
                                                .font(R.font.outfitSemiBold.font(size: 12))
                                            if message.unreadCount > 0 {
                                                Text("\(message.unreadCount)")
                                                    .font(.caption)
                                                    .padding(8)
                                                    .background(Circle().fill(Color.main))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal,30)
            .foregroundColor(.black)
        }
    }
}


 
#Preview {
    SBMessageView()
}
