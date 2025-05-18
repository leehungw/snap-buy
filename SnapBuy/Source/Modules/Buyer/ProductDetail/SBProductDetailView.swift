import SwiftUI

struct SBProductDetailView: View {
    let product: Product
    @Environment(\.dismiss) var dismiss
    @State private var quantity: Int = 1
    @State private var selectedColor: Color = .brown
    @State private var showSheet = true
    @State private var currentIndex: Int = 0
    @State private var selectedDetent: PresentationDetent = .fraction(0.5)
    @State private var isExpanded: Bool = false
    @State private var showAllReviews = false


    var productImages: [String] {
        SampleImages.verticalImages
    }

    var body: some View {
        SBBaseView {
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
                    NavigationLink(destination: SBCartView()) {
                        Image(systemName: "bag")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
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
                    .presentationDetents([.fraction(0.5), .large], selection: $selectedDetent)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(40)
            }
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }

    var productDetailSheet: some View {
        let average = calculateAverageRating(from: reviews)
        return VStack(alignment: .leading, spacing: 16) {
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
                Text(String(format: "%.1f", average))
                    .fontWeight(.semibold)
                Text("(\(reviews.count) review\(reviews.count == 1 ? "" : "s"))")
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
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(R.font.outfitBold.font(size:14))
                        .padding(.top,10)
                    Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry...Lorem Ipsum is simply dummy text of the printing and typesetting industry...Lorem Ipsum is simply dummy text of the printing and typesetting industry...Lorem Ipsum is simply dummy text of the printing and typesetting industry...")
                        .font(R.font.outfitRegular.font(size:13))
                        .foregroundColor(.gray)
                        .lineLimit(isExpanded ? nil : 3)
                    Button(action: {
                        isExpanded.toggle()
                    }) {
                        Text(isExpanded ? "Read less" : "Read more")
                            .font(R.font.outfitMedium.font(size:13))
                            .foregroundColor(.main)
                    }
                    .padding(.bottom,10)
                    if selectedDetent == .large {
                        NavigationLink(destination: SBStoreView()) {
                            HStack {
                                Image(systemName: "cube.box")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(24)
                                    .padding(.trailing, 10)
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(R.string.localizable.upboxBag())
                                            .font(R.font.outfitBold.font(size: 16))
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(Color.main)
                                            .font(.caption)
                                    }
                                    
                                    Text(R.string.localizable.storeStatsFormat("104", "1.3k"))
                                        .font(R.font.outfitRegular.font(size: 12))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                
                                Button(action: {}) {
                                    Text(R.string.localizable.follow())
                                        .font(R.font.outfitSemiBold.font(size: 14))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.main)
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                            Text(R.string.localizable.rating)
                                .font(R.font.outfitBold.font(size:14))
                                .padding(.top,10)
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(showAllReviews ? reviews : Array(reviews.prefix(3)), id: \.id) { review in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(review.reviewer)
                                            .font(R.font.outfitBold.font(size:13))
                                        Spacer()
                                        Text(review.date, style: .date)
                                            .font(R.font.outfitRegular.font(size:12))
                                            .foregroundColor(.gray)
                                    }
                                    HStack(spacing: 2) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Image(systemName: index < review.rating ? "star.fill" : "star")
                                                .foregroundColor(.yellow)
                                                .font(.caption)
                                        }
                                    }
                                    Text(review.comment)
                                        .font(R.font.outfitRegular.font(size:13))
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 5)
                            }
                            
                            if reviews.count > 3 {
                                Button(action: {
                                    showAllReviews.toggle()
                                }) {
                                    Text(showAllReviews ? "Show Less" : "See All Reviews")
                                        .font(R.font.outfitMedium.font(size: 14))
                                        .foregroundColor(.main)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            
            
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
    SBProductDetailView(product: Product.sampleList[0])
}
