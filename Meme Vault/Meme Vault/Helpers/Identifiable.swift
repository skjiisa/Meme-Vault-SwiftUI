//
//  Identifiable.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/16/20.
//

import FilesProvider
import Photos

extension FileObject: Identifiable {}

extension PHAssetCollection: Identifiable {
    public var id: String {
        localIdentifier
    }
}
