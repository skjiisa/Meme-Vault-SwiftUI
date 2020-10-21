//
//  ActionController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import Photos

class ActionController: ObservableObject {
    @Published var actionSets: [ActionSet] = [ActionSet(name: "Default actions", actions: [.share, .delete])]
    @Published var defaultActionSets: [PHAssetCollection: ActionSet] = [:]
    @Published var defaultActionSetIndex = 0
    
    var defaultActionSet: ActionSet? {
        guard defaultActionSetIndex < actionSets.count else { return nil }
        return actionSets[defaultActionSetIndex]
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
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "localIdentifier == %@", id)
        options.fetchLimit = 1
        let fetchResults = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
        return fetchResults.firstObject?.localizedTitle
    }
}
