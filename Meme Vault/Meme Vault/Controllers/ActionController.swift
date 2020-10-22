//
//  ActionController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import SwiftUI
import Photos

class ActionController: ObservableObject {
    @Published var actionSets: [ActionSet] = [ActionSet(name: "Default actions", actions: [.share, .delete])]
    @Published var defaultActionSets: [PHAssetCollection: ActionSet] = [:]
    @Published var defaultActionSetIndex = 0
    
    @Published var albums: [PHAssetCollection] = []
    @Published var currentAlbum: PHAssetCollection?
    var albumsByID: [String: PHAssetCollection] = [:]
    
    init() {
        refreshAlbums()
    }
    
    var defaultActionSet: ActionSet? {
        guard defaultActionSetIndex < actionSets.count else { return nil }
        return actionSets[defaultActionSetIndex]
    }
    
    var defaultActions: [Action] {
        defaultActionSet?.actions ?? []
    }
    
    func refreshAlbums() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
        
        withAnimation {
            self.albums = albums.objects(at: IndexSet(0..<albums.count))
        }
        
        albumsByID.removeAll()
        self.albums.forEach { albumsByID[$0.id] = $0 }
    }
    
    func title(for action: Action) -> String {
        switch action {
        case .share:
            return "Share"
        case .delete:
            return "Delete"
        case .addToAlbum(id: let id):
            if let name = albumName(id: id) {
                return "Add to " + name
            }
            return ""
        case .removeFromAlbum(id: .some(let id)):
            if let name = albumName(id: id) {
                return "Remove from " + name
            }
            fallthrough
        case .removeFromAlbum:
            return "Remove from current album"
        }
    }
    
    func albumName(id: String) -> String? {
        if let album = albumsByID[id] {
            return album.localizedTitle
        }
        
        refreshAlbums()
        return albumsByID[id]?.localizedTitle
    }
    
    func perform(action: Action, on asset: PHAsset) {
        let assets = [asset] as NSFastEnumeration
        
        PHPhotoLibrary.shared().performChanges { [self] in
            switch action {
            case .addToAlbum(id: let id):
                guard let album = albumsByID[id] else { break }
                PHAssetCollectionChangeRequest(for: album)?.addAssets(assets)
            case .removeFromAlbum(id: .some(let id)):
                guard let album = albumsByID[id] else { break }
                PHAssetCollectionChangeRequest(for: album)?.removeAssets(assets)
            case .removeFromAlbum(id: nil):
                guard let album = currentAlbum else { break }
                PHAssetCollectionChangeRequest(for: album)?.removeAssets(assets)
            default: break
            }
        }
    }
    
}
