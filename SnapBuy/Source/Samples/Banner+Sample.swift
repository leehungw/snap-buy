import Foundation

extension Banner {
    static let sample1 = Banner(
        title: "24% off shipping today",
        subtitle: "on bag purchases",
        storeName: "Kutuku Store",
        imageName: "imgb_1"
    )

    static let sample2 = Banner(
        title: "Summer Sale",
        subtitle: "up to 50% off",
        storeName: "Vinta Bags",
        imageName: "imgb_2"
    )

    static let sample3 = Banner(
        title: "New Arrivals",
        subtitle: "Fresh styles in stock",
        storeName: "Luxury Brand",
        imageName: "imgb_3"
    )

    static let samples: [Banner] = [sample1, sample2, sample3]
}
