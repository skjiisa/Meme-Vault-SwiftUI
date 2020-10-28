//
//  Meme_Vault+Convenience.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/16/20.
//

import CoreData
import FilesProvider

extension Meme {
    convenience init(id: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id
        self.modified = Date()
    }
}

extension Destination {
    @discardableResult
    convenience init(parent: Destination?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.path = parent?.path ?? "/"
        self.parent = parent
    }
    
    @discardableResult
    convenience init(directory: FileObject, parent: Destination? = nil, context: NSManagedObjectContext) {
        self.init(context: context)
        self.path = directory.path
        self.name = directory.name
        self.parent = parent
    }
}
