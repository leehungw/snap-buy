import SwiftUI

struct UserView: View {
    
    var body: some View {
        SBBaseView() {
            ZStack {
                Color(red: 241/255, green: 242/255, blue: 245/255)
                    .ignoresSafeArea()
                
                Text("USER")
                    .font(.system(size: 26))
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                +
                Text(" Screen")
                    .font(.system(size: 17))
            }
        }
    }
}

#Preview {
    UserView()
}
