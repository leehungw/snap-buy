import SwiftUI

struct SBOBView: View {
    var body: some View {
        VStack {
            Image("D6436144-D513-4D3A-9661-626AA7C84C8B")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 350)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer().frame(height: 20)

            Text("Various Collections Of The Latest Products")
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)

            Text("Urna amet, suspendisse ullamcorper ac elit diam facilisis cursus vestibulum.")
                .foregroundColor(.gray)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer().frame(height: 10)

            // Page Indicator
            HStack(spacing: 5) {
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.5)).frame(width: 8, height: 8)
                Circle().fill(Color.gray.opacity(0.5)).frame(width: 8, height: 8)
            }
            .padding(.vertical, 10)

            // Buttons
            SBButton(title: "Create Account", style: .filled) {
                // Handle create account action
            }
            .padding(.horizontal, 20)

            Button(action: {
                // Handle already have an account action
            }) {
                Text("Already Have an Account")
                    .foregroundColor(.blue)
                    .font(.subheadline)
                    .bold()
            }
            .padding(.top, 10)
        }
        .padding()
    }
}
