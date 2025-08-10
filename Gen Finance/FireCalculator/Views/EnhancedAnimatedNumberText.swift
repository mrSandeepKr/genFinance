//
//  EnhancedAnimatedNumberText.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 10/08/25.
//

import Foundation
import SwiftUI

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
