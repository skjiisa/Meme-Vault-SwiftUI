//
//  Set+Toggle.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import Foundation

extension Set {
    /// Inserts the given element in the set if it is not already present,
    /// otherwise removes the specified element from the set.
    /// - Parameter member: The element to add to or remove from the set.
    mutating func toggle(_ member: Element) {
        if contains(member) {
            remove(member)
        } else {
            insert(member)
        }
    }
}
