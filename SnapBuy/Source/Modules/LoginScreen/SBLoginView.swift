import SwiftUI

struct SBLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isForgotPasswordPresented: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                        Text(RLocalizable.loginAccount())
                            .font(.title)
                            .bold()
                            .padding(.top, 40)
                            .padding(.bottom, 10)
                        
                        Text(RLocalizable.pleaseLoginWithRegisteredAccount())
                            .foregroundColor(.gray)
                            .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing:  5) {
                    HStack {
                        Text(RLocalizable.email())
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 20)
                    }
                    SBTextField(image: RImage.img_email.image, placeholder: RLocalizable.enterYourEmail(), text: $email)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(RLocalizable.password())
                            .font(.title3)
                            .bold()
                            .padding(.horizontal, 20)
                    }
                    SBTextField(image: RImage.img_password.image, placeholder: RLocalizable.createYourPassword(), text: $password, isSecure: true)
                }
                
                HStack {
                    Spacer()
                    Text(RLocalizable.forgotPassword())
                        .foregroundColor(.main)
                        .font(.footnote).bold()
                        .padding(.trailing, 20)
                        .padding(.bottom, 40)
                        .onTapGesture {
                            forgotPassword()
                        }
                }
                
                
                SBButton(title: RLocalizable.signIn(), style: .filled) {
//                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                       let keyWindow = windowScene.windows.first {
//                        keyWindow.rootViewController = UIHostingController(rootView: SBHomeTabbarView())
//                        keyWindow.makeKeyAndVisible()
//                    }
                    // Define the login payload as a dictionary
                    let loginPayload: [String: Any] = [
                        "email": "ndam8175@gmail.com",
                        "password": "123123"
                    ]

                    // Convert the payload to JSON data
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: loginPayload, options: []) else {
                        print("Error: Unable to serialize login payload.")
                        return
                    }

                    // Use the original service to perform the request, decoding the response to RawResponse
                    SBAPIService.shared.performRequest(endpoint: "api/users/login",
                                                       method: "POST",
                                                       body: jsonData,
                                                       headers: nil) { (result: Result<RawResponse, Error>) in
                        switch result {
                        case .success(let response):
                            print("Raw JSON:\n\(response.raw)")
                        case .failure(let error):
                            print("Request failed with error: \(error.localizedDescription)")
                        }
                    }
                }
                
                Text(RLocalizable.orUsingOtherMethod())
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .padding(.top, 10)
                
                VStack(spacing: 10) {
                    SBButton(title: RLocalizable.signInWithGoogle(), leadingIcon: RImage.img_google_icon.image, style: .outlined) {
                        // Google Sign In Action
                    }
                    SBButton(title: RLocalizable.signInWithFacebook(), leadingIcon: RImage.img_facebook_icon.image, style: .outlined) {
                        // Facebook Sign In Action
                    }
                }
            }
        }
        .navigationTitle("")
        .toolbar(.hidden)
        .sheet(isPresented: $isForgotPasswordPresented) {
            SBForgotPasswordSheetView()
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(50)
        }
    }
    
    private func forgotPassword() {
        isForgotPasswordPresented = true
    }
}

#Preview {
    SBLoginView()
}

/// A type that can decode any JSON value.
struct AnyDecodable: Decodable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else if let array = try? container.decode([AnyDecodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyDecodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to decode JSON value"
            )
        }
    }
}

/// A wrapper type that decodes the entire JSON response and converts it to a raw JSON string.
struct RawResponse: Decodable {
    let raw: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Decode the JSON as a dictionary of [String: AnyDecodable]
        let decodedDict = try container.decode([String: AnyDecodable].self)
        // Map it to a [String: Any] object
        let jsonObject = decodedDict.mapValues { $0.value }
        // Serialize the object back to JSON data
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        // Convert the data to a String
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unable to convert data to string"
            )
        }
        raw = jsonString
    }
}
