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
        Section(
            header: Text(heading)
                .font(.headline)
                .foregroundStyle(.indigo.gradient.opacity(0.8))
        ) {
            content
        }
        .listRowInsets(.init())
    }
}
