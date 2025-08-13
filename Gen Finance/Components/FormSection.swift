//
//  FormSection.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 03/08/25.
//

import Foundation
import SwiftUI

struct FormSection<Content: View, Value: Equatable>: View {
    let heading: String
    let symbol: String?
    let content: Content
    let animationValue: Value?
    let isResetting: Bool
    let animationDelay: Double
    
    init(heading: String, 
         symbol: String? = nil, 
         animationValue: Value? = nil,
         isResetting: Bool = false,
         animationDelay: Double = 0.0,
         @ViewBuilder content: () -> Content) {
        self.heading = heading
        self.symbol = symbol
        self.content = content()
        self.animationValue = animationValue
        self.isResetting = isResetting
        self.animationDelay = animationDelay
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                if let symbol = symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.indigo.gradient.opacity(0.85))
                        .shadow(color: .indigo.opacity(0.08), radius: 2, x: 0, y: 1)
                }
                Text(heading)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.indigo.gradient.opacity(0.8))
            }
            .padding(.top, 16)
            content
            Spacer(minLength: 10)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(
            VisualEffectBlur(blurStyle: .systemMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.indigo.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeOut(duration: 0.5).delay(animationDelay), value: animationValue)
        .scaleEffect(isResetting ? 0.95 : 1.0)
        .opacity(isResetting ? 0.7 : 1.0)
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
