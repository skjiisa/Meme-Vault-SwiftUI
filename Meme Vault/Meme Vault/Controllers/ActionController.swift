//
//  ActionController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import SwiftUI
import Photos

class ActionController: ObservableObject {
    
    //MARK: Properties
    
    @Published var actionSets: [ActionSet] = []
    @Published var defaultActionSets: [PHAssetCollection: ActionSet] = [:]
    @Published var defaultActionSetIndex = 0
    
    @Published var albums: [PHAssetCollection] = []
    @Published var currentAlbum: PHAssetCollection?
    var albumsByID: [String: PHAssetCollection] = [:]
    
    @Published var newActionSet: ActionSet?
    
    init() {
        loadActionSets()
        if actionSets.count == 0 {
            actionSets.append(ActionSet(name: "Default actions", actions: [.share, .delete]))
            saveActionSets()
        }
        
        refreshAlbums()
    }
    
    var defaultActionSet: ActionSet? {
        guard defaultActionSetIndex < actionSets.count else { return nil }
        return actionSets[defaultActionSetIndex]
    }
    
    var defaultActions: [Action] {
        defaultActionSet?.actions ?? []
    }
    
    //MARK: Action Sets
    
    /// Creates a new, empty `ActionSet`,
    /// stores it in `newActionSet`,
    /// and appends it to `actionSets`.
    func createActionSet() {
        let actionSet = ActionSet(name: "")
        actionSets.append(actionSet)
        newActionSet = actionSet
    }
    
    /// The URL of the JSON file containing the list of `ActionSet`s.
    private var actionSetsFileURL: URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("actionSets.plist")
    }
    
    /// Saves the list of `ActionSet`s to the file at `actionSetsFileURL`.
    func saveActionSets() {
        guard let url = actionSetsFileURL else { return }
        
        do {
            let excludedAlbumsData = try JSONEncoder().encode(actionSets)
            try excludedAlbumsData.write(to: url)
        } catch {
            NSLog("Error writing Action Sets data: \(error)")
        }
    }
    
    /// Loads the list of `ActionSet`s from the plist file at `actionSetsFileURL`.
    func loadActionSets() {
        guard let url = actionSetsFileURL,
              FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let excludedAlbumsData = try Data(contentsOf: url)
            actionSets = try JSONDecoder().decode([ActionSet].self, from: excludedAlbumsData)
        } catch {
            NSLog("Error loading Action Sets data: \(error)")
        }
    }
    
    //MARK: Albums
    
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
    
    func albumName(id: String) -> String? {
        if let album = albumsByID[id] {
            return album.localizedTitle
        }
        
        refreshAlbums()
        return albumsByID[id]?.localizedTitle
    }
    
    //MARK: Actions
    
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
