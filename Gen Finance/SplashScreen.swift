import SwiftUI

struct SplashScreen: View {
    
    @State private var size = 0.4
    @State private var opacity = 0.5
    @State private var rotation: Angle = .degrees(500)
    @State private var flyAway = false
    let duration: Double
    
    var body: some View {
        VStack {
            ZStack {
                // background
                mainView
            }
            .scaleEffect(size)
            .opacity(opacity)
            .rotationEffect(rotation)
            .onAppear {
                withAnimation(.spring(duration: duration * 0.6, bounce: 0.5)) {
                    self.size = 1.0
                    self.opacity = 1.0
                }
                withAnimation(.spring(duration: duration * 0.5, bounce: 0.3)) {
                    self.rotation = .zero
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.8) {
                    withAnimation(.easeIn(duration: duration * 0.2)) {
                        flyAway = true
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @Environment(\.colorScheme) var colorScheme
    
    private var background: some View {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.6),
                Color.white.opacity(0.2),
                Color.clear
            ]),
            center: .center,
            startRadius: 0,
            endRadius: 250
        )
        .blur(radius: 10)
        .frame(width: 500, height: 500)
        .clipShape(Circle())
    }
    
    private var mainView: some View {
        VStack {
            appIcon
            Spacer().frame(height: 10)
            title
        }
    }
    
    private var appIcon: some View {
        Image("AppIcon")
            .resizable()
            .scaledToFit()
            .frame(width: 150, height: 150)
            .if(colorScheme == .dark) { view in
                view.colorInvert()
            }
            .offset(y: flyAway ? -300 : 0)
            .opacity(flyAway ? 0 : 1)
    }
    
    private var title: some View {
        Text("Gen Finance")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(.indigo.gradient)
            .offset(y: flyAway ? 300 : 0)
            .opacity(flyAway ? 0 : 1)
    }
}

#Preview {
    SplashScreen(duration: 1.2)
}
