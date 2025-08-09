import SwiftUI

struct FireResultView: View {
    let requiredCorpus: Double
    let projectedCorpus: Double
    @Environment(\.dismiss) var dismiss
    @State private var animatedRequired: Double = 0
    @State private var animatedProjected: Double = 0
    @State private var showCards: Bool = false
    @State private var showIcon: Bool = false
    @State private var iconScale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            contentBackground()
            VStack(spacing: 32) {
                Spacer(minLength: 20)
                Image(systemName: "flame.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.indigo, .orange)
                    .shadow(color: .indigo.opacity(0.15), radius: 12, x: 0, y: 6)
                    .scaleEffect(iconScale)
                    .opacity(showIcon ? 1 : 0)
                    .padding(.bottom, 12)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.6)) {
                            showIcon = true
                        }
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0).delay(0.1)) {
                            iconScale = 1.2
                        }
                    }
                VStack(spacing: 24) {
                    corpusCard(
                        title: "Required FIRE Corpus",
                        value: animatedRequired,
                        color: .indigo,
                        delay: 0.3
                    )
                    corpusCard(
                        title: "Projected Corpus at Retirement",
                        value: animatedProjected,
                        color: .green,
                        delay: 0.5
                    )
                }
                .padding(.horizontal, 6)
                summaryTipSection
                Spacer()
                backButton()
            }
            .padding()
            .navigationTitle("FIRE Results")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0)) {
                    animatedRequired = requiredCorpus
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 1.5, dampingFraction: 0.8, blendDuration: 0)) {
                    animatedProjected = projectedCorpus
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showCards = true
            }
        }
        .hideNavBarWithSiwpeToDismiss()
    }
    
    @ViewBuilder
    private func contentBackground() -> some View {
        // Enhanced glassmorphism background
        VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
            .ignoresSafeArea()
        
        // Multiple decorative blurred shapes for depth
        Circle()
            .fill(Color.indigo.opacity(0.18))
            .blur(radius: 60)
            .frame(width: 320, height: 320)
            .offset(x: 120, y: -180)
            .allowsHitTesting(false)
        
        Circle()
            .fill(Color.green.opacity(0.12))
            .blur(radius: 80)
            .frame(width: 250, height: 250)
            .offset(x: -100, y: 200)
            .allowsHitTesting(false)
    }
    
    @ViewBuilder
    private func corpusCard(title: String, value: Double, color: Color, delay: Double) -> some View {
        VStack(spacing: 14) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            EnhancedAnimatedNumberText(value: value, color: color, delay: delay)
        }
        .padding(.all, 24)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                VisualEffectBlur(blurStyle: .systemMaterial)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: color.opacity(0.1), radius: 15, x: 0, y: 8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.2),
                            color.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .opacity(showCards ? 1 : 0)
        .offset(y: showCards ? 0 : 40)
        .scaleEffect(showCards ? 1 : 0.95)
        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.3), value: showCards)
    }
    
    // Enhanced summary/tip section
    private var summaryTipSection: some View {
        let gap = projectedCorpus - requiredCorpus
        let (icon, message, color): (String, String, Color) = {
            if requiredCorpus == 0 || projectedCorpus == 0 {
                return ("info.circle.fill", "Enter your details to see your FIRE status.", .gray)
            } else if gap >= 0 {
                return ("checkmark.seal.fill", "You are on track for FIRE!", .green)
            } else {
                return ("exclamationmark.triangle.fill", "Consider increasing your SIP or retirement age to close the gap.", .orange)
            }
        }()
        
        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                VisualEffectBlur(blurStyle: .systemThinMaterial)
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        color.opacity(0.03),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
        .opacity(showCards ? 1 : 0)
        .offset(y: showCards ? 0 : 20)
        .animation(.easeOut(duration: 0.8).delay(0.7), value: showCards)
    }
    
    @ViewBuilder
    private func backButton() -> some View {
        // Enhanced back button
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                dismiss()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.indigo,
                                Color.indigo.opacity(0.8),
                                Color.indigo.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.indigo.opacity(0.25), radius: 12, x: 0, y: 6)
                
                Text("Okay")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
            }
        }
        .scaleEffect(showCards ? 1 : 0.9)
        .opacity(showCards ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showCards)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }
}

// Enhanced animated number text with sophisticated counter animation
struct EnhancedAnimatedNumberText: View, Animatable {
    var value: Double
    var color: Color
    var delay: Double
    @State private var displayedValue: Double = 0
    @State private var isAnimating: Bool = false
    
    var animatableData: Double {
        get { displayedValue }
        set { displayedValue = newValue }
    }
    
    var body: some View {
        Text(displayedValue, format: .currency(code: "INR").precision(.fractionLength(0)))
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .shadow(color: color.opacity(0.15), radius: 4, x: 0, y: 2)
            .monospacedDigit()
            .scaleEffect(isAnimating ? 1.02 : 1.0)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 0.3).delay(delay + 0.5)) {
                        isAnimating = true
                    }
                }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.spring(response: 1.2, dampingFraction: 0.8, blendDuration: 0)) {
                    displayedValue = newValue
                }
            }
    }
}

#Preview {
    NavigationStack {
        FireResultView(requiredCorpus: 10000000, projectedCorpus: 8500000)
    }
}
