//
//  KeyboardResponder.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 08/08/25.
//

import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    @Published private(set) var isKeyboardVisible: Bool = false
    
    private var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = keyboardPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isKeyboardVisible, on: self)
    }
}
