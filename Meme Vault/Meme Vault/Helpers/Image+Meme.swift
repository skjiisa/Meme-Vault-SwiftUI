//
//  Image+Meme.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 8/2/20.
//

import SwiftUI

extension Image {
    init(uiImage: UIImage?, orSystemName systemName: String, meme: Meme) {
        if let uiImage = uiImage {
            self.init(uiImage: uiImage)
        } else {
            self.init(systemName: systemName)
        }
        let _ = self.tag(meme)
    }
}
