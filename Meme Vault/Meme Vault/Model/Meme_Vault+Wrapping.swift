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

extension Destination {
    var wrappedName: String {
        get { self.name ?? "" }
        set { self.name = newValue }
    }
    
    var wrappedPath: String {
        get { self.path ?? "" }
        set { self.path = newValue }
    }
}
