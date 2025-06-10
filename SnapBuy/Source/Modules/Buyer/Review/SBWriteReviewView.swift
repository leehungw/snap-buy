import SwiftUI
import PhotosUI

struct SBWriteReviewView: View {
    let order: SBOrderItemModel
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showPhotoPicker = false
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Text("Write a Review")
                        .font(R.font.outfitSemiBold.font(size: 18))
                    Spacer()
                    Color.clear
                        .frame(width: 24, height: 24) // Balance the back button
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Product Card
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: order.productImageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 70, height: 70)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(order.productName)
                                    .font(R.font.outfitSemiBold.font(size: 16))
                                    .lineLimit(2)
                                
                                if !order.productNote.isEmpty {
                                    Text(order.productNote)
                                        .font(R.font.outfitRegular.font(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Quantity: \(order.quantity)")
                                    .font(R.font.outfitRegular.font(size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 2)
                        
                        // Rating Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rating")
                                .font(R.font.outfitSemiBold.font(size: 16))
                            
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.system(size: 28))
                                        .foregroundColor(star <= rating ? .yellow : .gray.opacity(0.3))
                                        .onTapGesture {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                rating = star
                                            }
                                        }
                                }
                            }
                            .padding(.bottom, 4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 2)
                        
                        // Review Text Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Review")
                                .font(R.font.outfitSemiBold.font(size: 16))
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $reviewText)
                                    .frame(minHeight: 120, maxHeight: 200)
                                    .font(R.font.outfitRegular.font(size: 15))
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                
                                if reviewText.isEmpty {
                                    Text("Share your experience about this product...")
                                        .font(R.font.outfitRegular.font(size: 15))
                                        .foregroundColor(.gray.opacity(0.8))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 16)
                                }
                            }
                            
                            Text("\(reviewText.count) characters (minimum 10)")
                                .font(R.font.outfitRegular.font(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 2)
                        
                        // Image Upload Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Photos")
                                .font(R.font.outfitSemiBold.font(size: 16))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    Button(action: { showPhotoPicker = true }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 24))
                                            Text("Add")
                                                .font(R.font.outfitRegular.font(size: 12))
                                        }
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.main)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                    
                                    ForEach(selectedImages, id: \.self) { image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 2)
                    }
                    .padding(16)
                }
                
                // Submit Button
                VStack {
                    Button(action: submitReview) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit Review")
                                    .font(R.font.outfitSemiBold.font(size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(isValid() ? Color.main : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(27)
                        .shadow(color: isValid() ? Color.main.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                    }
                    .disabled(!isValid() || isSubmitting)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if alertTitle == "Success" {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
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
        isSubmitting = true
        
        // Upload images first if there are any
        if !selectedImages.isEmpty {
            ImgurService.shared.uploadImages(selectedImages) { result in
                switch result {
                case .success(let imageUrls):
                    // Submit review with uploaded image URLs
                    ReviewRepository.shared.submitReview(
                        orderId: order.orderId,
                        productId: order.productId,
                        rating: rating,
                        content: reviewText,
                        images: imageUrls,
                        productNote: order.productNote
                    ) { result in
                        switch result {
                        case .success(let reviewData):
                            // Update order item review status
                            OrderRepository.shared.updateOrderItemReviewStatus(orderItemId: order.id) { updateResult in
                                isSubmitting = false
                                switch updateResult {
                                case .success:
                                    alertTitle = "Success"
                                    alertMessage = "Review submitted successfully"
                                    showAlert = true
                                case .failure(let error):
                                    alertTitle = "Warning"
                                    alertMessage = "Review submitted but failed to update status: \(error.localizedDescription)"
                                    showAlert = true
                                }
                            }
                        case .failure(let error):
                            isSubmitting = false
                            alertTitle = "Error"
                            alertMessage = error.localizedDescription
                            showAlert = true
                        }
                    }
                    
                case .failure(let error):
                    isSubmitting = false
                    alertTitle = "Error"
                    alertMessage = "Failed to upload images: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        } else {
            // Submit review without images
            ReviewRepository.shared.submitReview(
                orderId: order.orderId,
                productId: order.productId,
                rating: rating,
                content: reviewText,
                images: [],
                productNote: order.productNote
            ) { result in
                switch result {
                case .success(let reviewData):
                    // Update order item review status
                    OrderRepository.shared.updateOrderItemReviewStatus(orderItemId: order.id) { updateResult in
                        isSubmitting = false
                        switch updateResult {
                        case .success:
                            alertTitle = "Success"
                            alertMessage = "Review submitted successfully"
                            showAlert = true
                        case .failure(let error):
                            alertTitle = "Warning"
                            alertMessage = "Review submitted but failed to update status: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                case .failure(let error):
                    isSubmitting = false
                    alertTitle = "Error"
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }
        }
    }
}
