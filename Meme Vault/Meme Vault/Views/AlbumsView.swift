//
//  AlbumsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos
import CoreData

extension UIImage: Identifiable {}

struct AlbumsView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var memeController: MemeController
    
    @State private var albums: PHFetchResult<PHAssetCollection>
    @State private var currentCollection: Int?
    
    var exclude: Bool
    
    init(exclude: Bool = false) {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
        _albums = .init(initialValue: albums)
        
        self.exclude = exclude
    }
    
    var body: some View {
        List {
            ForEach(0..<albums.count) { index in
                let title = albums.object(at: index).localizedTitle ?? "Unknown Album"
                
                if exclude {
                    HStack {
                        Button(title) {
                            memeController.toggle(albums.object(at: index))
                        }
                        if memeController.excludedAlbums.contains(albums.object(at: index)) {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                } else {
                    NavigationLink(title, destination: MemeView(), tag: index, selection: $currentCollection)
                }
            }
        }
        .navigationBarTitle("Albums")
        .onChange(of: currentCollection) { index in
            if let index = index {
                memeController.fetchImages(for: albums.object(at: index), context: moc)
                currentCollection = index
            } else {
                memeController.assets = nil
            }
        }
    }
}

struct AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumsView()
    }
}
