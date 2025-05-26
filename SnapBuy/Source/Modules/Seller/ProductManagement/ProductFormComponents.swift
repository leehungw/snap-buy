import SwiftUI
//
//struct ProductTextField: View {
//    let title: String
//    let placeholder: String
//    @Binding var text: String
//    var keyboardType: UIKeyboardType = .default
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(title)
//                .font(R.font.outfitMedium.font(size: 14))
//            TextField(placeholder, text: $text)
//                .keyboardType(keyboardType)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .font(R.font.outfitRegular.font(size: 14))
//        }
//    }
//}
//
//struct ProductMultilineField: View {
//    let title: String
//    @Binding var text: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(title)
//                .font(R.font.outfitMedium.font(size: 14))
//            TextField("Enter \(title.lowercased())", text: $text, axis: .vertical)
//                .lineLimit(4...8)
//                .padding(8)
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(10)
//                .font(R.font.outfitRegular.font(size: 14))
//        }
//    }
//}

struct ProductPicker<T: Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: [(T, String)]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(R.font.outfitMedium.font(size: 14))
                Picker("Select \(title)", selection: $selection) {
                    ForEach(options, id: \.0) { option in
                        Text(option.1).tag(option.0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .font(R.font.outfitRegular.font(size: 14))
            }
            Spacer()
        }
    }
}

struct TagInputField: View {
    let title: String
    @Binding var input: String
    @Binding var tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(R.font.outfitMedium.font(size: 14))
            
            HStack {
                TextField("Enter a \(title.lowercased())", text: $input)
                    .font(R.font.outfitRegular.font(size: 14))
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button {
                    if !input.trimmingCharacters(in: .whitespaces).isEmpty {
                        tags.append(input)
                        input = ""
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                Image(systemName: "xmark.circle.fill")
                                    .onTapGesture {
                                        tags.removeAll { $0 == tag }
                                    }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }
}
//
//struct ImagePickerView: View {
//    @Binding var selectedImages: [UIImage]
//    @Binding var showPicker: Bool
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Product Images")
//                .font(R.font.outfitMedium.font(size: 15))
//            
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 12) {
//                    ForEach(selectedImages, id: \.self) { image in
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 80, height: 80)
//                            .clipped()
//                            .cornerRadius(8)
//                    }
//                    
//                    Button {
//                        showPicker = true
//                    } label: {
//                        VStack {
//                            Image(systemName: "plus")
//                                .font(.title2)
//                            Text("Add")
//                                .font(R.font.outfitRegular.font(size: 12))
//                        }
//                        .frame(width: 80, height: 80)
//                        .foregroundColor(.gray)
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                    }
//                }
//            }
//        }
//    }
//} 
