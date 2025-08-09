//
//  HideNavBarWithSwipeToDismiss.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 10/08/25.
//

import SwiftUI

// MARK: - View Extension
extension View {
    func hideNavBarWithSiwpeToDismiss(threshold: CGFloat = 100) -> some View {
        modifier(SwipeToDismissModifier(threshold: threshold))
    }
}

fileprivate struct SwipeToDismissModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    let threshold: CGFloat
    
    init(threshold: CGFloat = 100) {
        self.threshold = threshold
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarHidden(true)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.location.x > threshold {
                            dismiss()
                        }
                    }
            )
    }
}
