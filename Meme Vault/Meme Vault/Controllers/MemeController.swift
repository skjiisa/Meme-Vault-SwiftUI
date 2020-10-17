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
    
    var assets: PHFetchResult<PHAsset>?
    var nextAssetToFetch: Int = 0
    
    private var fetchQueue = Set<Meme>()
    
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
    
    @discardableResult
    func getNextAssetMeme(context: NSManagedObjectContext) -> Meme? {
        guard nextAssetToFetch < assets?.count ?? 0,
              let asset = assets?.object(at: nextAssetToFetch) else { return nil }
        
        let meme = getMeme(for: asset, context: context)
        
        if nextAssetToFetch == 0 {
            memes = [meme]
        } else {
            memes.append(meme)
        }
        nextAssetToFetch += 1
        return meme
    }
    
    func getNextAssetMemes(count: Int, context: NSManagedObjectContext) {
        let indexSet = IndexSet(nextAssetToFetch ..< min(nextAssetToFetch + count, assets?.count ?? nextAssetToFetch))
        guard nextAssetToFetch < assets?.count ?? 0,
              let assets = self.assets?.objects(at: indexSet) else { return }
        
        let assetIDs = assets.map { $0.localIdentifier }
        
        let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", assetIDs)
        let existingMemes = try? context.fetch(fetchRequest)
        
        var memesByID: [String: Meme] = [:]
        for meme in existingMemes ?? [] {
            guard let id = meme.id else { continue }
            memesByID[id] = meme
        }
        
        for asset in assets {
            if let meme = memesByID[asset.localIdentifier] {
                memes.append(meme)
            } else {
                let meme = Meme(id: asset.localIdentifier, context: context)
                memes.append(meme)
            }
            nextAssetToFetch += 1
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
        
        guard let asset = assets?.firstObject,
              let meme = getNextAssetMeme(context: context) else { return }
        
        // Since SwiftUI is had a bug and won't new Memes into the TabView,
        // load up 20 at the start.
        getNextAssetMemes(count: 20, context: context)
        
        // Fetch the first image
        fetchImage(for: asset) { image in
            guard let image = image else { return }
            self.images[meme] = image
        }
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
    
}
