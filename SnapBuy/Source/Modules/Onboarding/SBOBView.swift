import SwiftUI

struct SBOBView: View {
    @State private var currentPage = 0
    private let pages = [
        SBOBPageView.Page(image: RImage.img_ob1.image, title: "Welcome to Our App", subtitle: "Discover new features and functionalities."),
        SBOBPageView.Page(image: RImage.img_ob2.image, title: "Stay Organized", subtitle: "Keep track of your tasks and projects efficiently."),
        SBOBPageView.Page(image: RImage.img_ob3.image, title: "Achieve Your Goals", subtitle: "Set targets and accomplish them with ease.")
    ]
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.blue
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
    }
    
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        SBOBPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .onReceive(Timer.publish(every: 2, on: .main, in: .common).autoconnect()) { _ in
                    withAnimation {
                        currentPage = (currentPage + 1) % pages.count
                    }
                }
                
                Spacer().frame(height: 100)
                
                SBButton(title: RLocalizable.createAccount(), style: .filled) {
                    SBUserDefaultService.instance.didShowOnboarding = true
                    path.append(1)
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    SBUserDefaultService.instance.didShowOnboarding = true
                }) {
                    Text(RLocalizable.alreadyHaveAnAccount())
                        .foregroundColor(.main)
                        .font(.subheadline)
                        .bold()
                }
                .padding(.top, 10)
                .navigationDestination(for: Int.self) { _ in
                    SBLoginView()
                }
            }
            .padding()
        }
    }
}

