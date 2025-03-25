import SwiftUI

struct SBBasePopup<Content: View>: View {
    @Binding var isPresented: Bool
    let content: () -> Content
    
    var body: some View {
        ZStack {
            if isPresented {
                
                VStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing,30)
                    .padding(.top, 30)
                    
                    content()
                        .padding(.top,15)
                        .padding(.horizontal, 10)
                        .multilineTextAlignment(.center)
                        .font(.custom("Outfit-Regular", size: 20))
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(.main)
                            .cornerRadius(100)
                            .padding(.bottom,20)
                            .font(.custom("Outfit-Regular", size: 16))
                    }
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .padding(.bottom, 30)
                            .font(.custom("Outfit-Regular", size: 16))
                    }
                }
                .frame(width: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale)
                .animation(.spring(), value: isPresented)
                .onTapGesture {
                    isPresented = false
                }
            }
        }
    }
}
