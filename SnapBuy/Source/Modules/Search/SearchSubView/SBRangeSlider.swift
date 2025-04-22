import SwiftUI

struct SBRangeSlider: View {
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    var minValue: Double
    var maxValue: Double

    private var trackWidth: CGFloat = 6

    // ✅ Khởi tạo để tránh lỗi 'private' init
    init(lowerValue: Binding<Double>, upperValue: Binding<Double>, minValue: Double, maxValue: Double) {
        self._lowerValue = lowerValue
        self._upperValue = upperValue
        self.minValue = minValue
        self.maxValue = maxValue
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let lowerThumbPosition = CGFloat((lowerValue - minValue) / (maxValue - minValue)) * width
            let upperThumbPosition = CGFloat((upperValue - minValue) / (maxValue - minValue)) * width

            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trackWidth/2)
                    
                // Selected range
                Capsule()
                    .fill(Color.main)
                    .frame(width: upperThumbPosition - lowerThumbPosition, height: trackWidth/2)
                    .offset(x: lowerThumbPosition)
                    

                // Lower thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.main, lineWidth: 5))
                    .offset(x: lowerThumbPosition - 14)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = Double(value.location.x / width) * (maxValue - minValue) + minValue
                                lowerValue = min(max(minValue, newValue), upperValue)
                            }
                    )

                // Upper thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.main, lineWidth: 5))
                    .offset(x: upperThumbPosition - 14)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = Double(value.location.x / width) * (maxValue - minValue) + minValue
                                upperValue = max(min(maxValue, newValue), lowerValue)
                            }
                    )
            }
        }
        .frame(height: 40)
    }
}
