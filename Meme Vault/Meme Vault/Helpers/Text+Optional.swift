//
//  Text+Optional.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 8/4/20.
//

import SwiftUI

extension Text {
    init?(optionalString: String?) {
        guard let string = optionalString else { return nil }
        self.init(string)
    }
}
