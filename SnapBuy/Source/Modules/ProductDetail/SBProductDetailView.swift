import SwiftUI

struct SBProductDetailView: View {
    let product: SBProduct
    @Environment(\.dismiss) var dismiss
    @State private var quantity: Int = 1
    @State private var selectedColor: Color = .brown
    @State private var showSheet = false
    @State private var currentIndex: Int = 0


    var productImages: [String] {
        SampleImages.verticalImages
    }

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color.black)
                    }
                    Spacer()
                    Text("Detail Product")
                        .font(R.font.outfitRegular.font(size:16))
                    Spacer()
                    Image(systemName: "bag")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                
                .padding()
                TabView(selection: $currentIndex) {
                    ForEach(productImages.indices, id: \.self) { index in
                        Image(productImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                Spacer()

                Button(action: {
                    showSheet = true
                }) {
                    HStack {
                        Image(systemName: "bag.fill")
                        Text("Add to Cart")
                            .font(R.font.outfitMedium.font(size: 16))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        .sheet(isPresented: $showSheet) {
            productDetailSheet
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(40)
        }
        .navigationBarBackButtonHidden(true)
    }

    var productDetailSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(product.name)
                    .font(R.font.outfitBold.font(size:25))
                Spacer()
                HStack(spacing: 8) {
                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                        Image(systemName: "minus")
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    Text("\(quantity)")
                        .font(.headline)
                    Button(action: { quantity += 1 }) {
                        Image(systemName: "plus")
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top,20)
            HStack {
                Text("4.8")
                    .fontWeight(.semibold)
                Text("(320 Review)")
                    .foregroundColor(.gray)
                    .font(.caption)
                Spacer()
                Text("Available in stock")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.top, -15)

            Text("Color")
                .font(R.font.outfitBold.font(size:14))
                .padding(.top,10)

            HStack(spacing: 16) {
                ForEach([Color.brown, .black, .cyan, .green], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: selectedColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            

            Text("Description")
                .font(R.font.outfitBold.font(size:14))
                .padding(.top,10)
            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry...")
                .font(R.font.outfitRegular.font(size:13))
                .foregroundColor(.gray)
                .lineLimit(3)
            Spacer()
            HStack {
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {}) {
                    HStack {
                        Image(systemName: "bag.fill")
                        Text("Add to Cart")
                            .font(R.font.outfitMedium.font(size: 16))
                    }
                    .padding()
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
            }
            .padding(.horizontal,20)
        }
        .padding()
    }
    
}
#Preview {
    SBProductDetailView(product: .sample)
}
