//
//  View+Keyboard.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/17/20.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
