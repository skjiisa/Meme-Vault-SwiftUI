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
    
    @Published var images: [Meme: MemeContainer] = [:]
    @Published var memes: [Meme] = []
    
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
    
    //MARK: Getting Meme Containers
    
    func load(_ fetchedMemes: FetchedResults<Meme>) {
        memes = Array(fetchedMemes)
        assets = nil
    }
    
    func container(for meme: Meme) -> MemeContainer? {
        let image = images[meme]
        fetchImage(for: meme)
        return image
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
            let meme = Meme(context: context)
            meme.id = asset.localIdentifier
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
    
    func fetchAsset(for meme: Meme) -> PHAsset? {
        guard let id = meme.id else { return nil }
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        
        return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions).firstObject
    }
    
    func fetchImage(for album: PHAssetCollection, context: NSManagedObjectContext, completion: @escaping (MemeContainer?) -> Void) {
        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        nextAssetToFetch = 0
        
        guard let asset = assets?.firstObject,
              let meme = getNextAssetMeme(context: context) else { return completion(nil) }
        
        getNextAssetMeme(context: context)
        
        fetchImage(for: asset) { image in
            guard let image = image else { return completion(nil) }
            let container = MemeContainer(meme: meme, image: image)
            self.images[meme] = container
            completion(container)
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
            self.images[meme] = MemeContainer(meme: meme, image: image)
        }
    }
    
    func fetchImageData(for meme: Meme, completion: @escaping (Data?, String?) -> Void) {
        guard let asset = fetchAsset(for: meme) else { return completion(nil,nil) }
        fetchImageData(for: asset, completion: completion)
    }
    
}
