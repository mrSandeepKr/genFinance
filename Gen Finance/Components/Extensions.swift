//
//  Extensions.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 15/08/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                              transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
