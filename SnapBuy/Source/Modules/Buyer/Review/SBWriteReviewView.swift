import SwiftUI
import PhotosUI

struct SBWriteReviewView: View {
    let purchased: Purchased
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showPhotoPicker = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Color.black)
                }
                Spacer()
                Text("Write a Review")
                    .font(R.font.outfitRegular.font(size: 16))
                    .padding(.trailing,15)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top,20)
            VStack (alignment: .leading) {
                VStack (alignment: .leading, spacing: 15) {
                    HStack(spacing: 16) {
                        Image(purchased.imageName)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(purchased.title)
                                .font(R.font.outfitSemiBold.font(size: 16))
                            
                            Text("Color: \(purchased.color)")
                                .font(R.font.outfitRegular.font(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Rating
                    VStack(alignment: .leading) {
                        Text("Rating")
                            .font(R.font.outfitMedium.font(size: 15))
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.main)
                                    .onTapGesture {
                                        rating = star
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // Review Text
                    VStack(alignment: .leading) {
                        Text("Write review at least 10 words")
                            .font(R.font.outfitMedium.font(size: 15))
                        
                        TextEditor(text: $reviewText)
                            .frame(height: 270)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2))
                            )
                            
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    // Image Picker
                    VStack(alignment: .leading) {
                        Text("Add image or video (optional)")
                            .font(R.font.outfitMedium.font(size: 15))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    showPhotoPicker = true
                                }) {
                                    VStack {
                                        Image(systemName: "plus")
                                            .font(.title2)
                                        Text("Add")
                                            .font(.caption)
                                    }
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.gray)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical,15)
                .background(Color.white)
                .cornerRadius(10)
                Spacer()
            }
            .padding(10)
            .background(Color.gray.opacity(0.2))
            
            // Submit Button
            Button(action: submitReview) {
                Text("Submit Review")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid() ? Color.main : Color.gray.opacity(0.4))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal)
            .disabled(!isValid())
        }
        
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: Binding(
                get: { nil },
                set: { item in
                    if let item = item {
                        Task {
                            if let data = try? await item.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                selectedImages.append(image)
                            }
                        }
                    }
                }
            ),
            matching: .images
        )
        .navigationBarBackButtonHidden(true)
    }
    
    
    // Kiểm tra dữ liệu
    func isValid() -> Bool {
        return rating > 0 && reviewText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }
    
    // Logic gửi review
    func submitReview() {
        print("📝 Review Submitted")
        print("⭐️ Rating: \(rating)")
        print("✍️ Text: \(reviewText)")
        print("🖼️ Images: \(selectedImages.count)")
        
        dismiss()
    }
}

#Preview {
    SBWriteReviewView(purchased: Purchased(title: "Bix Bag Limited Edition 229", imageName: "cat_access", color: "Berown", quantity: 1, price: 24.00, status: "Complete"))
}
