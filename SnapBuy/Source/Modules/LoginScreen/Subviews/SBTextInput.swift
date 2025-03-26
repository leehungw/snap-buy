import SwiftUI

struct SBTextField: View {
    let image: Image
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            image
                .foregroundColor(.gray)
                .padding(.leading, 10)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
            } else {
                TextField(placeholder, text: $text)
                    .padding()
            }
        }
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}
