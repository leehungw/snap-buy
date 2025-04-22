import SwiftUI

struct SBAddressView: View {
    @Binding var selectedAddress: String
    @State private var searchText: String = "San Diego, CA"
    @Environment(\.dismiss) var dismiss
    @State private var selectedLocationID: UUID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // Navigation
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Text(R.string.localizable.address)
                    .font(R.font.outfitRegular.font(size: 16))
                    .padding(.trailing,10)
                Spacer()
            }
            .padding(.bottom, 10)
            .padding(.horizontal,20)

            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text(R.string.localizable.chooseYourLocation)
                    .font(R.font.outfitBold.font(size: 20))
                Text(R.string.localizable.letSFindYourUnforgettableEventChooseALocationBelowToGetStarted)
                    .font(R.font.outfitRegular.font(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Search Field
            HStack {
                Image(systemName: "location.circle")
                    .foregroundColor(.gray)
                TextField("Enter location", text: $searchText)
                Spacer()
                Image(systemName: "location.north.fill")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)

            // Select Location
            Text(R.string.localizable.chooseYourLocation)
                .font(R.font.outfitBold.font(size: 20))
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(locations.indices, id: \.self) { index in
                    let location = locations[index]
                    HStack {
                        VStack(alignment: .leading) {
                            Text(location.name)
                                .font(.headline)
                            Text(location.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(location.color.opacity(0.2))
                                .frame(width: 50, height: 50)
                            Circle()
                                .fill(location.color)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selectedLocationID == location.id ? Color.purple : Color.gray.opacity(0.2), lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedLocationID = location.id
                    }
                    .padding(.horizontal)
                }
            }

            Spacer()

            // Confirm Button
            Button(action: {
                if let selectedID = selectedLocationID,
                   let selected = locations.first(where: { $0.id == selectedID }) {
                    selectedAddress = searchText + "," + selected.name
                    dismiss()
                }
            }) {
                Text(R.string.localizable.confirm)
                    .font(R.font.outfitMedium.font(size: 20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.main)
                    .cornerRadius(25)
            }
            .padding()
        }
        .padding(.horizontal,10)
        .navigationBarHidden(true)
    }
}
#Preview {
    SBAddressView(selectedAddress: .constant("San Diego, CA"))
}
