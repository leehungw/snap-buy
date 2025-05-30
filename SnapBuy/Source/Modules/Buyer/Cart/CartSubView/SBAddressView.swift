import SwiftUI
import CoreLocation
import MapKit

struct SBAddressView: View {
    @Binding var selectedAddress: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D?
    @StateObject private var viewModel = SBAddressViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var customLocation: String = ""

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

            // Custom Location Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Enter address", text: $customLocation)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !customLocation.isEmpty {
                        Button(action: {
                            viewModel.geocodeAddress(customLocation)
                        }) {
                            Text("Find")
                                .font(R.font.outfitMedium.font(size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.main)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)

            // Location Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Location")
                    .font(R.font.outfitBold.font(size: 16))
                
                if viewModel.isLoadingLocation {
                    VStack {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    VStack(spacing: 12) {
                        if let coordinate = viewModel.coordinate {
                            Map(coordinateRegion: .constant(viewModel.region),
                                annotationItems: [coordinate]) { location in
                                MapMarker(coordinate: location)
                            }
                            .frame(height: 200)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 200)
                                .overlay(
                                    Text("No location selected")
                                        .foregroundColor(.gray)
                                )
                        }
                        
                        if let error = viewModel.locationError {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(R.font.outfitRegular.font(size: 14))
                                
                                Button(action: {
                                    viewModel.requestLocation()
                                }) {
                                    Text("Use Current Location Instead")
                                        .font(R.font.outfitMedium.font(size: 14))
                                        .foregroundColor(.main)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if !viewModel.currentAddress.isEmpty {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.currentAddress)
                                        .font(R.font.outfitRegular.font(size: 14))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    selectedAddress = viewModel.currentAddress
                                    selectedCoordinate = viewModel.coordinate
                                    dismiss()
                                }) {
                                    Text("Confirm")
                                        .font(R.font.outfitMedium.font(size: 14))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.main)
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.horizontal, 10)
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.currentAddress.isEmpty {
                viewModel.requestLocation()
            }
        }
    }
}

#Preview {
    SBAddressView(selectedAddress: .constant("San Diego, CA"), selectedCoordinate: .constant(nil))
}
