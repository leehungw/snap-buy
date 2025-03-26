import SwiftUI

struct SBTextField: View {
    let image: Image
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(.leading, 10)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .focused($isFocused)
            }
        }
        .frame(height: 50)
        .background(text.isEmpty && !isFocused ? Color.gray.opacity(0.1) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isFocused ? Color.main : (text.isEmpty ? Color.clear : Color.black), lineWidth: 2)
        )
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}
