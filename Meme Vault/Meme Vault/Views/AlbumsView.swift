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
    
    @State private var albums: PHFetchResult<PHAssetCollection>
    @State private var selectedMeme: Meme?
    @State private var selectedImage: UIImage?
    @State private var showingImage: Bool = false
    
    let memeController = MemeController()
    
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
                    selectedMeme = memeController.fetchImage(for: albums.object(at: index), context: moc) { image in
                        guard let image = image else { return }
                        selectedImage = image
                        showingImage = true
                    }
                } label: {
                    HStack {
                        Text(albums.object(at: index).localizedTitle ?? "Unknown Album")
                        if let selectedMeme = selectedMeme, let selectedImage = selectedImage {
                            NavigationLink(destination: MemeView(meme: selectedMeme, image: selectedImage), isActive: $showingImage) { EmptyView() }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
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
