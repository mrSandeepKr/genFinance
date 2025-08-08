//
//  FormSection.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 03/08/25.
//

import Foundation
import SwiftUI

struct FormSection<Content: View>: View {
    let heading: String
    let content: Content
    
    init(heading: String, @ViewBuilder content: () -> Content) {
        self.heading = heading
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(heading)
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.indigo.gradient.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
            content
            Spacer(minLength: 10)
        }
        .listRowInsets(.init())
    }
}

#Preview {
    NavigationStack {
        FireCalculatorView()
    }
}
