//
//  Meme_Vault+Wrapping.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/25/20.
//

import Foundation

extension Meme {
    var wrappedName: String {
        get { self.name ?? "" }
        set { self.name = newValue }
    }
}
