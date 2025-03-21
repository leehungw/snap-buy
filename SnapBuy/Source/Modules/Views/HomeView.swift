import SwiftUI

struct HomeView: View {
    @State private var showPopup = false
    @State private var isSheetPresented = false
    
    var body: some View {
        SBBaseView() {
            ZStack {
                VStack {
                    VStack {
                        Button("Open Popup") {
                            showPopup = true
                        }
                        .padding()
                    }
                    VStack {
                        Button("Open Sheet") {
                            isSheetPresented = true
                        }
                    }
                }
            }
        }
        .overlay(
            BasePopup(isPresented: $showPopup) {
                VStack {
                    Text("This is the content of popup")
                        .padding()
                }
            }
        )
        .sheet(isPresented: $isSheetPresented) {
            VStack {
                Text("Hello from Sheet!")
                    .font(.title)
                    .padding()
                
                Button("Close") {
                    isSheetPresented = false
                }
                .padding()
            }
            .frame(width: 300, height: 900)
            .presentationDetents([.fraction(0.7)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(50)
        }
    }
}

#Preview {
    HomeView()
}
