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
    @State private var selectedMeme: MemeContainer?
    @State private var currentImage: Int?
    
    init() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
        _albums = .init(initialValue: albums)
    }
    
    var body: some View {
        List {
            ForEach(0..<albums.count) { index in
                Button {
                    memeController.fetchImage(for: albums.object(at: index), context: moc) { memeContainer in
                        selectedMeme = memeContainer
                        currentImage = selectedMeme == nil ? nil : index
                    }
                } label: {
                    NavigationLink(destination: MemeView(startingMeme: selectedMeme?.meme), tag: index, selection: $currentImage) {
                        HStack {
                            Text(albums.object(at: index).localizedTitle ?? "Unknown Album")
                        }
                    }
                }
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
