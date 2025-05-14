import SwiftUI

struct SBEmailVerificationTextView: View {
    @Binding var text: String
    var onCommit: (() -> Void)? = nil
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("", text: $text)
            .onChange(of: text) { newValue in
                if newValue.count > 1 {
                    text = String(newValue.prefix(1))
                }
                if newValue.count == 1 {
                    isFocused = false
                    onCommit?()
                }
            }
            .padding()
            .focused($isFocused)
            .frame(width: 50, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(text.isEmpty && !isFocused ? Color.gray.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.main : (text.isEmpty ? Color.clear : Color.black), lineWidth: 2)
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)

    }
}

#Preview {
    SBVerificationView()
}
