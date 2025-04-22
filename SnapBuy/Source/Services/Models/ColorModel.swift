import SwiftUI

struct SelectableColor: Hashable {
    let color: Color
    let name: String
}

let sampleColors: [SelectableColor] = [
    SelectableColor(color: .black, name: "Black"),
    SelectableColor(color: .purple, name: "Purple"),
    SelectableColor(color: .blue, name: "Blue"),
    SelectableColor(color: .yellow, name: "Yellow"),
    SelectableColor(color: .pink, name: "Pink")
]
