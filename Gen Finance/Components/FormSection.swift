//
//  FormSection.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 03/08/25.
//

import Foundation
import SwiftUI

struct FormSection<Content: View, Value: Equatable>: View {
    
    // MARK: - View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                if let symbol = symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.indigo.gradient.opacity(0.85))
                        .shadow(color: theme.primary080, radius: 2, x: 0, y: 1)
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
        .shadow(color: theme.primary080, radius: 8, x: 0, y: 4)
        .padding(.vertical, 4)
        .padding(.horizontal, 2)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeOut(duration: 0.5).delay(animationDelay), value: animationValue)
        .scaleEffect(isResetting ? 0.95 : 1.0)
        .opacity(isResetting ? 0.7 : 1.0)
    }
    
    // MARK: - Init

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
    
    // MARK: - Private
    
    @Environment(\.appTheme) private var theme
    
    private let heading: String
    private let symbol: String?
    private let content: Content
    private let animationValue: Value?
    private let isResetting: Bool
    private let animationDelay: Double
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
