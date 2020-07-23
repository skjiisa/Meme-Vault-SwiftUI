//
//  AlbumsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos

struct AlbumsView: View {
    @State private var albums: PHFetchResult<PHAssetCollection>
    
    init() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
        _albums = .init(initialValue: albums)
    }
    
    var body: some View {
        List {
            ForEach(0..<albums.count) { index in
                Text(albums.object(at: index).localizedTitle ?? "Unknown Album")
            }
        }
        .navigationBarTitle("Albums")
    }
}

struct AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumsView()
    }
}
