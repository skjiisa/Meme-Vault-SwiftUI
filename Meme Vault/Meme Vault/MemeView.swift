//
//  MemeView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos

struct MemeView: View {
    @Binding var image: UIImage?
    @State var name: String = ""
    
    var body: some View {
        VStack {
            Image(uiImage: image ?? UIImage(systemName: "slash.circle")!)
        }
    }
}
