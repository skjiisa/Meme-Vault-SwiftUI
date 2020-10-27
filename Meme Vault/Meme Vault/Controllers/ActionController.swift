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
    @Published var tempActionSetIndex: Int? = 0
    
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
    
    /// The temp Action Set to show expanded.
    ///
    /// Returns the Action Set in `actionSets` at the index of `tempActionSetIndex` if there is one.
    /// If not, returns `defaultActionSet`.
    var tempActionSet: ActionSet? {
        get {
            guard let tempActionSetIndex = tempActionSetIndex,
                  tempActionSetIndex < actionSets.count else { return defaultActionSet }
            return actionSets[tempActionSetIndex]
        }
        set {
            if let newValue = newValue,
               let index = actionSets.firstIndex(of: newValue) {
                tempActionSetIndex = index
            } else {
                tempActionSetIndex = nil
            }
        }
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
    
    func setDefault(_ actionSet: ActionSet) {
        guard let index = actionSets.firstIndex(of: actionSet) else { return }
        defaultActionSetIndex = index
        saveDefaultActionSetIndex()
    }
    
    /// The URL of the JSON file containing the list of `ActionSet`s.
    private var actionSetsFileURL: URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("actionSets.plist")
    }
    
    private var defaultActionSetIndexKey = "defaultActionSetIndex"
    
    /// Saves the index of the default Action Set to User Defaults
    func saveDefaultActionSetIndex() {
        UserDefaults.standard.setValue(defaultActionSetIndex, forKey: defaultActionSetIndexKey)
    }
    
    /// Saves the list of Action Sets to the file at `actionSetsFileURL`.
    /// Saves the default Action Set by calling `saveDefaultActionSetIndex`.
    func saveActionSets() {
        guard let url = actionSetsFileURL else { return }
        
        do {
            let excludedAlbumsData = try JSONEncoder().encode(actionSets)
            try excludedAlbumsData.write(to: url)
            
            saveDefaultActionSetIndex()
        } catch {
            NSLog("Error writing Action Sets data: \(error)")
        }
    }
    
    /// Loads the list of Action Sets from the plist file at `actionSetsFileURL`.
    /// Loads the default Action Set from User Defaults.
    func loadActionSets() {
        guard let url = actionSetsFileURL,
              FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let excludedAlbumsData = try Data(contentsOf: url)
            actionSets = try JSONDecoder().decode([ActionSet].self, from: excludedAlbumsData)
            
            defaultActionSetIndex = UserDefaults.standard.integer(forKey: defaultActionSetIndexKey)
        } catch {
            NSLog("Error loading Action Sets data: \(error)")
        }
    }
    
    private func findDefaultActionSet(_ actionSet: ActionSet?) {
        if let actionSet = actionSet,
           let defaultActionSetIndex = actionSets.firstIndex(of: actionSet) {
            self.defaultActionSetIndex = defaultActionSetIndex
        } else {
            self.defaultActionSetIndex = 0
        }
    }
    
    func removeActionSets(atOffsets offsets: IndexSet) {
        let defaultActionSet = self.defaultActionSet
        actionSets.remove(atOffsets: offsets)
        findDefaultActionSet(defaultActionSet)
        
        saveActionSets()
    }
    
    func moveActionSets(fromOffsets source: IndexSet, toOffset destination: Int) {
        let defaultActionSet = self.defaultActionSet
        actionSets.move(fromOffsets: source, toOffset: destination)
        findDefaultActionSet(defaultActionSet)
        
        saveActionSets()
    }
    
    /// Checks if the given Action Set is the default for the current album.
    /// - Parameter actionSet: The `ActionSet` to check
    /// - Returns: `true` if the `ActionSet` in `defaultActionSets` for `currentAlbum` is the given Action Set.
    /// `true` if there is no default Action Set for the current album but the given Action Set is the global default.
    /// `true` if there is no current album but the Action Set is the temp Action Set.
    func isAlbumActionSet(_ actionSet: ActionSet) -> Bool {
        if let currentAlbum = currentAlbum {
            if let albumDefault = defaultActionSets[currentAlbum] {
                return albumDefault == actionSet
            } else {
                return defaultActionSet == actionSet
            }
        } else {
            return tempActionSet == actionSet
        }
    }
    
    /// If there is a current album, set or unset the default Action Set for it. If not, set or unset the temp Action Set.
    /// - Parameters:
    ///   - actionSet: The `ActionSet` to set or unset
    ///   - isDefault: Whether the Action Set should be set or unset
    func setAlbumActionSet(_ actionSet: ActionSet, isDefault: Bool) {
        if let currentAlbum = currentAlbum {
            if isDefault {
                defaultActionSets[currentAlbum] = actionSet
            } else if defaultActionSets[currentAlbum] == actionSet {
                defaultActionSets.removeValue(forKey: currentAlbum)
            }
        } else {
            tempActionSet = actionSet
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
        case .favorite:
            return "Add to favorites"
        case .unfavorite:
            return "Remove from favorites"
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
            case .favorite:
                PHAssetChangeRequest(for: asset).isFavorite = true
            case .unfavorite:
                PHAssetChangeRequest(for: asset).isFavorite = false
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
