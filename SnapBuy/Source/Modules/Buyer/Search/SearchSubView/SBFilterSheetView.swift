import SwiftUI

struct SBFilterSheetView: View {
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 60
    @State private var selectedColor: SelectableColor = SelectableColor(color: .black, name: "Black")
    @State private var selectedLocation: String = "San Diego"

    let locations: [String] = ["San Diego", "New York", "Amsterdam"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text(R.string.localizable.filterBy())
                .font(R.font.outfitBold.font(size: 20))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 50)

            // PRICE
            VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text(R.string.localizable.price())
                        .font(R.font.outfitBold.font(size: 20))
                    Spacer()
                    Text("$\(Int(minPrice)) – $\(Int(maxPrice))")
                        .foregroundColor(.gray)
                        .font(R.font.outfitRegular.font(size: 14))
                }

                SBRangeSlider(
                    lowerValue: $minPrice,
                    upperValue: $maxPrice,
                    minValue: 0,
                    maxValue: 80
                )
                .padding(.horizontal, 20)
            }

            // COLOR
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(R.string.localizable.color())
                        .font(R.font.outfitBold.font(size: 16))
                    Spacer()
                    Text(selectedColor.name)
                        .foregroundColor(.gray)
                        .font(R.font.outfitRegular.font(size: 14))
                }
                .padding(.top, -20)

                HStack {
                    ForEach(sampleColors, id: \.self) { item in
                        ZStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 32, height: 32)
                                .opacity(selectedColor == item ? 1.0 : 0.5)

                            if selectedColor == item {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            }
                        }
                        .overlay(
                            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onTapGesture {
                            selectedColor = item
                        }
                        .padding(.trailing, 30)
                    }
                }
            }

            // LOCATION
            VStack(alignment: .leading, spacing: 20) {
                Text(R.string.localizable.location())
                    .font(R.font.outfitBold.font(size: 16))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(locations, id: \.self) { location in
                            Text(location)
                                .font(R.font.outfitMedium.font(size: 14))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(selectedLocation == location ? Color.main : Color.white)
                                .foregroundColor(selectedLocation == location ? .white : .main)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.main, lineWidth: 1)
                                )
                                .cornerRadius(20)
                                .onTapGesture {
                                    selectedLocation = location
                                }
                        }
                    }
                }
            }

            // BUTTON
            Button(action: {
                // Apply filter action
            }) {
                Text(R.string.localizable.applyFilter())
                    .font(R.font.outfitBold.font(size: 17))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }

            Spacer()
        }
        .font(R.font.outfitRegular.font(size: 16))
        .padding(.horizontal, 25)
        .padding(.bottom)
        .presentationDetents([.medium, .large])
    }
}
