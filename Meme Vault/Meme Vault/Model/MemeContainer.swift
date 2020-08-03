//
//  MemeContainer.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/31/20.
//

import SwiftUI

class MemeContainer: ObservableObject {
    @Published var meme: Meme
    @Published var image: UIImage
    
    init(meme: Meme, image: UIImage) {
        self.meme = meme
        self.image = image
    }
    
    var thumbnailHeight: CGFloat {
        image.size.height < image.size.width ? 64 * image.size.height / image.size.width : 64
    }
}
