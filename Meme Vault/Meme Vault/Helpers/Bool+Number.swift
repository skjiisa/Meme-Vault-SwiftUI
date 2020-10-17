//
//  Bool+Number.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/17/20.
//

import Foundation

extension Bool {
    var int: Int { self ? 1 : 0 }
    var float: Float { self ? 1.0 : 0.0 }
}
