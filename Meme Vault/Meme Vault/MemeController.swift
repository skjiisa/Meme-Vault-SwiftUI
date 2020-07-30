//
//  MemeController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import CoreData
import Photos
import SwiftUI

class MemeController {
    func fetchImage(for album: PHAssetCollection, context: NSManagedObjectContext, completion: @escaping (UIImage?) -> Void) -> Meme? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = PHAsset.fetchAssets(in: album, options: fetchOptions)
        
        let options = PHImageRequestOptions()
        options.version = .current
        
        guard let asset = assets.firstObject else {
            completion(nil)
            return nil
        }
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { imageData, _, _, _ in
            guard let imageData = imageData else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
        
        let fetchRequest: NSFetchRequest<Meme> = Meme.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", asset.localIdentifier)
        let memes = try? context.fetch(fetchRequest)
        
        if let meme = memes?.first {
            return meme
        } else {
            let meme = Meme(context: context)
            meme.id = asset.localIdentifier
            try? context.save()
            return meme
        }
    }
}
