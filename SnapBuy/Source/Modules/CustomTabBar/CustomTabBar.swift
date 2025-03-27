

import SwiftUI

struct CustomTabBar: View {
    
    @Binding var tabSelection: Int
    var animation: Namespace.ID
    
    private var tabWidth: CGFloat {
        return screenWidth/5
    }
    
    @State private var midPoint: CGFloat = 0.0
    
    var body: some View {
        let midSize: CGFloat = screenWidth * (200/1000)
        
        ZStack() {
            BezierCurvePath(midPoint: midPoint)
                .foregroundStyle(.white)
                .shadow(radius: 5)
            
            HStack(spacing: 0.0) {
                ForEach(0..<TabModel.allCases.count, id: \.self) { index in
                    let tab = TabModel.allCases[index]
                    let isCurrentTab = tabSelection == index+1
                    
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                            tabSelection = index + 1
                            midPoint = tabWidth * (-CGFloat(tabSelection-3))
                        }
                        
                    } label: {
                        VStack(spacing: 2.0) {
                            Image(systemName: tab.systemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .aspectRatio(isCurrentTab ? 0.4 : 0.6, contentMode: .fit)
                                .frame(
                                    width: isCurrentTab ? midSize : 35.0,
                                    height: isCurrentTab ? midSize : 35.0)
                                .foregroundStyle(
                                    isCurrentTab ? .white : .gray
                                )
                                .background {
                                    if isCurrentTab {
                                        Circle()
                                            .fill(.main.gradient)
                                            .matchedGeometryEffect(id: "CurveAnimation", in: animation)
                                    }
                                }
                                .offset(y: isCurrentTab ? -(midSize/2) : 0.0)
                            
                            if !isCurrentTab {
                                Text(tab.rawValue)
                                    .font(.caption)
                                    .fontDesign(.rounded)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(isCurrentTab ? .white : .gray)
                        .offset(y: !isCurrentTab ? -8.0 : 0.0)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: midSize)
        .onAppear {
            midPoint = tabWidth * (-CGFloat(1-3))
        }
    }
}

#Preview {
    RootView()
}
