import SwiftUI
import Kingfisher

struct SBProductDetailView: View {
    let product: SBProduct
    @Environment(\.dismiss) var dismiss
    @State private var quantity: Int = 1
    @State private var selectedColor: Color = .brown
    @State private var currentIndex: Int = 0
    
    
    var productImages: [String] {
        product.productImages.map { $0.url }
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
            ScrollView(showsIndicators: true) {
                TabView(selection: $currentIndex) {
                    ForEach(productImages.indices, id: \.self) { index in
                        KFImage(URL(string: productImages[index]))
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                
                
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
                    Text(product.description)
                        .font(R.font.outfitRegular.font(size:13))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Product Variants
                    Text("Variants")
                        .font(R.font.outfitBold.font(size:14))
                        .padding(.top, 10)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(product.productVariants, id: \.id) { variant in
                                VStack {
                                    Text("\(variant.size)")
                                        .font(.caption)
                                    Circle()
                                        .fill(Color(variant.color))
                                        .frame(width: 24, height: 24)
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Tags
                    Text("Tags")
                        .font(R.font.outfitBold.font(size:14))
                        .padding(.top, 10)
                    WrapHStack(items: product.listTag) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                    }
                    HStack {
                        Text("$\(String(format: "%.2f", product.basePrice))")
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
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 60)
        }
        .navigationBarBackButtonHidden(true)
    }
    
}

struct WrapHStack<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    @State private var totalHeight: CGFloat = .zero
    
    init(items: Data,
         spacing: CGFloat = 8,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.items = items
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .padding(.all, 4)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height + spacing
                        }
                        let result = width
                        if item == items.first {
                            width = 0 // First item
                        } else {
                            width -= dimension.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.first {
                            height = 0 // First item
                        }
                        return result
                    }
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: geometry.size.height)
        }
        .onPreferenceChange(SizePreferenceKey.self) { binding.wrappedValue = $0 }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
