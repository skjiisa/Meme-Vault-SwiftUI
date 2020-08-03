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
    
    var memes: [Meme] = []
    @Published var currentMemeIndex: Int = 0
    private var fetchQueue = Set<Meme>()
    
    //MARK: Getting Meme Containers
    
    func load(_ fetchedMemes: FetchedResults<Meme>) {
        memes = Array(fetchedMemes)
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
    
    func fetchAsset(for meme: Meme) -> PHAsset? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        
        guard let id = meme.id else { return nil }
        return PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions).firstObject
    }
    
    func fetchImage(for album: PHAssetCollection, context: NSManagedObjectContext, completion: @escaping (MemeContainer?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        
        guard let asset = assets.firstObject else { return completion(nil) }
        
        let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", asset.localIdentifier)
        let memes = try? context.fetch(fetchRequest)
        
        let meme: Meme
        if let firstMeme = memes?.first {
            meme = firstMeme
            if let container = images[meme] {
                return completion(container)
            }
        } else {
            meme = Meme(context: context)
            meme.id = asset.localIdentifier
            try? context.save()
        }
        
        self.memes = [meme]
        
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
