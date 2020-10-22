//
//  MemeController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import CoreData
import Photos
import SwiftUI

class MemeController: ObservableObject {
    
    //MARK: Properties
    
    @Published var images: [Meme: UIImage] = [:]
    @Published var memes: [Meme] = []
    @Published var currentMeme: Meme?
    @Published var excludedAlbums: Set<PHAssetCollection> = []
    
    var assets: PHFetchResult<PHAsset>?
    var nextAssetToFetch: Int = 0
    
    private var fetchQueue = Set<Meme>()
    
    init() {
        loadFromPersistentStore()
    }
    
    //MARK: Meme CRUD
    
    func delete(meme: Meme, context: NSManagedObjectContext) {
        context.delete(meme)
        do {
            try context.save()
        } catch {
            NSLog("\(error)")
        }
    }
    
    //MARK: Navigation
    
    func load(_ fetchedMemes: FetchedResults<Meme>) {
        memes = Array(fetchedMemes)
        assets = nil
    }
    
    func nextMeme() {
        guard let currentMeme = currentMeme,
              let index = memes.firstIndex(of: currentMeme),
              index < memes.endIndex - 1 else { return }
        self.currentMeme = memes[index + 1]
    }
    
    //MARK: Fetching Images
    
    func fetchImageData(for asset: PHAsset, completion: @escaping (Data?, String?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .current
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { imageData, dataUTI, _, _ in
            completion(imageData, dataUTI)
        }
    }
    
    func fetchImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        fetchImageData(for: asset) { imageData, _ in
            guard let imageData = imageData else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }
    
    func getMeme(for asset: PHAsset, context: NSManagedObjectContext) -> Meme {
        let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", asset.localIdentifier)
        fetchRequest.fetchLimit = 1
        let memes = try? context.fetch(fetchRequest)
        
        if let firstMeme = memes?.first {
            return firstMeme
        } else {
            let meme = Meme(id: asset.localIdentifier, context: context)
            try? context.save()
            return meme
        }
    }
    
    func nextValidAsset() -> PHAsset? {
        guard let assets = assets else { return nil }
        
        while nextAssetToFetch < assets.count {
            let asset = assets.object(at: nextAssetToFetch)
            nextAssetToFetch += 1
            
            if !excluded(asset) {
                return asset
            }
        }
        
        return nil
    }
    
    @discardableResult
    func getNextAssetMeme(context: NSManagedObjectContext) -> Meme? {
        guard let asset = nextValidAsset() else { return nil }
        let meme = getMeme(for: asset, context: context)
        memes.append(meme)
        return meme
    }
    
    func getNextAssetMemes(count: Int, context: NSManagedObjectContext) {
        // Fetch all existing Memes.
        let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
        let existingMemes = try? context.fetch(fetchRequest)
        
        // Make a hash table for easy Meme lookup.
        var memesByID: [String: Meme] = [:]
        for meme in existingMemes ?? [] {
            guard let id = meme.id else { continue }
            memesByID[id] = meme
        }
        
        // Create if necessary and add each asset's Meme to the list
        // if it hasn't already been uploaded or marked for delete.
        while let asset = nextValidAsset(),
              memes.count < count {
            if let meme = memesByID[asset.localIdentifier] {
                guard !meme.uploaded,
                      !meme.delete else { continue }
                memes.append(meme)
            } else {
                let meme = Meme(id: asset.localIdentifier, context: context)
                memes.append(meme)
            }
        }
        
        try? context.save()
    }
    
    func fetchAsset(for meme: Meme) -> PHAsset? {
        guard let id = meme.id else { return nil }
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        
        return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions).firstObject
    }
    
    func fetchImages(for album: PHAssetCollection, context: NSManagedObjectContext) {
        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        nextAssetToFetch = 0
        memes.removeAll()
        
        // Since SwiftUI is had a bug and won't new Memes into the TabView,
        // load up 20 at the start.
        getNextAssetMemes(count: 20, context: context)
    }
    
    func fetchImage(for meme: Meme, completion: @escaping (UIImage?) -> Void) {
        guard let asset = fetchAsset(for: meme) else { return completion(nil) }
        fetchImage(for: asset, completion: completion)
    }
    
    func fetchImage(for meme: Meme) {
        guard images[meme] == nil,
              !fetchQueue.contains(meme) else { return }
        fetchQueue.insert(meme)
        fetchImage(for: meme) { image in
            self.fetchQueue.remove(meme)
            guard let image = image else { return }
            self.images[meme] = image
        }
    }
    
    func fetchImageData(for meme: Meme, completion: @escaping (Data?, String?) -> Void) {
        guard let asset = fetchAsset(for: meme) else { return completion(nil,nil) }
        fetchImageData(for: asset, completion: completion)
    }
    
    //MARK: Actions
    
    func share(meme: Meme, shareSheet: @escaping (ShareSheet?) -> Void) {
        guard let asset = fetchAsset(for: meme) else { return shareSheet(nil) }
        
        fetchImageData(for: asset) { imageData, dataUTI in
            guard let imageData = imageData,
                  let dataUTI = dataUTI,
                  let fileExtension = URL(string: dataUTI)?.pathExtension else { return shareSheet(nil) }
            let name = meme.wrappedName.isEmpty ? dataUTI : meme.wrappedName
            let filename = "\(name).\(fileExtension)"
            
            do {
                let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                try imageData.write(to: filePath)
                shareSheet (
                    ShareSheet(activityItems: [filePath]) { _, _, _, _ in
                        do {
                            try FileManager.default.removeItem(at: filePath)
                        } catch {
                            NSLog("Error deleting local copy of image: \(error)")
                        }
                    })
            } catch {
                NSLog("Error creating local copy of image: \(error)")
                shareSheet(nil)
            }
        }
    }
    
    func markForDelete(meme: Meme, context: NSManagedObjectContext) {
        meme.delete.toggle()
        try? context.save()
    }
    
    //MARK: Albums
    
    /// Checks if an assets is in any of the excluded albums.
    /// - Parameter asset: The assets to check.
    /// - Returns: `True` if the assets is contained in any of the collections in `excludedAlbums`. Otherwise `False`.
    func excluded(_ asset: PHAsset) -> Bool {
        let collections = PHAssetCollection.fetchAssetCollectionsContaining(asset, with: .album, options: nil)
        for i in 0..<collections.count {
            if excludedAlbums.contains(collections.object(at: i)) {
                return true
            }
        }
        
        return false
    }
    
    /// The URL of the plist file containing the list of excluded albums.
    private var persistentFileURL: URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("excludedAlbums.plist")
    }
    
    /// Saves the list of excluded albums to the plist file at `persistentFileURL`.
    func saveToPersistentStore() {
        guard let url = persistentFileURL else { return }
        let albumIDs = excludedAlbums.map { $0.localIdentifier }
        
        do {
            let excludedAlbumsData = try PropertyListEncoder().encode(albumIDs)
            try excludedAlbumsData.write(to: url)
        } catch {
            NSLog("Error writing excluded albums data: \(error)")
        }
    }
    
    /// Loads the list of excluded albums from the plist file at `persistentFileURL`.
    func loadFromPersistentStore() {
        guard let url = persistentFileURL,
              FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let excludedAlbumsData = try Data(contentsOf: url)
            let albumIDsArray = try PropertyListDecoder().decode([String].self, from: excludedAlbumsData)
            let albumIDs = Set(albumIDsArray)
            
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            
            for i in 0..<albums.count {
                let album = albums.object(at: i)
                if albumIDs.contains(album.localIdentifier) {
                    excludedAlbums.insert(album)
                }
            }
        } catch {
            NSLog("Error loading excluded albums data: \(error)")
        }
    }
    
}
