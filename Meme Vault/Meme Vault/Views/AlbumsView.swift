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
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.fetchLimit = 1
//                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let assets = PHAsset.fetchAssets(in: albums.object(at: index), options: fetchOptions)
                    
                    let options = PHImageRequestOptions()
                    options.version = .current
                    
                    guard let asset = assets.firstObject else { return }
                    
                    let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id = %@", asset.localIdentifier)
                    let memes = try? moc.fetch(fetchRequest)
                    
                    if let meme = memes?.first {
                        self.selectedMeme = meme
                    } else {
                        let meme = Meme(context: moc)
                        meme.id = asset.localIdentifier
                        self.selectedMeme = meme
                        try? moc.save()
                    }
                    
                    PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [self] imageData, dataUTI, _, _ in
                        guard let imageData = imageData else { return }
                        selectedImage = UIImage(data: imageData)
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
