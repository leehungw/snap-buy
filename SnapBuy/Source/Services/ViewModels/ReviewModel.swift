import SwiftUI


struct Review: Identifiable {
    let id = UUID()
    let reviewer: String
    let rating: Int // from 0 to 5
    let comment: String
    let date: Date
}

let reviews: [Review] = [
    Review(reviewer: "Alice", rating: 5, comment: "Excellent product!", date: Date()),
    Review(reviewer: "Bob", rating: 4, comment: "Good value.", date: Date()),
    Review(reviewer: "Charlie", rating: 3, comment: "Average quality.", date: Date()),
    Review(reviewer: "David", rating: 5, comment: "Perfect!", date: Date())
]

let averageRating = calculateAverageRating(from: reviews)

func calculateAverageRating(from reviews: [Review]) -> Double {
    guard !reviews.isEmpty else { return 0.0 }
    let total = reviews.reduce(0) { $0 + $1.rating }
    let average = Double(total) / Double(reviews.count)
    return (average * 10).rounded() / 10  
}
