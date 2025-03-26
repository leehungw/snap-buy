import SwiftUI

enum SBButtonStyle {
    case filled, outlined
}

struct SBButton: View {
    var title: String
    var leadingIcon: Image? = nil
    var style: SBButtonStyle
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let leadingIcon {
                    leadingIcon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(style == .filled ? .black : .white)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(style == .filled ? .main : Color.clear)
            .foregroundColor(style == .filled ? .white : .black)
            .clipShape(Capsule())
        }
        .overlay(
            Capsule()
                .stroke(style == .outlined ? Color.gray.opacity(0.7) : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal, 20)
    }
}
