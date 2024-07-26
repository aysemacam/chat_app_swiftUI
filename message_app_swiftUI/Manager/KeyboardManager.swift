//
//  KeyboardManager.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI
import Combine

class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0.0
    @Published var isKeyboardVisible: Bool = false
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self.keyboardHeight = keyboardFrame.height
                }
            }
    }

    deinit {
        cancellable?.cancel()
    }
}
