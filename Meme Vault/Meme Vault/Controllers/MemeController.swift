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
    
    @Published var images: [Meme: MemeContainer] = [:]
    
    func fetchImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .current
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { imageData, _, _, _ in
            guard let imageData = imageData else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
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
        
        fetchImage(for: asset) { image in
            guard let image = image else { return completion(nil) }
            let container = MemeContainer(meme: meme, image: image)
            self.images[meme] = container
            completion(container)
        }
    }
    
    func fetchImage(for meme: Meme, completion: @escaping (UIImage?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        
        guard let id = meme.id,
              let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: fetchOptions).firstObject else {
            return completion(nil)
        }
        
        fetchImage(for: asset, completion: completion)
    }
    
    func fetchImage(for meme: Meme) {
        guard images[meme] == nil else { return }
        fetchImage(for: meme) { image in
            guard let image = image else { return }
            self.images[meme] = MemeContainer(meme: meme, image: image)
        }
    }
    
}
