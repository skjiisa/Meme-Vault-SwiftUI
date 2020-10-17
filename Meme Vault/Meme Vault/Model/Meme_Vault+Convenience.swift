//
//  Meme_Vault+Convenience.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/16/20.
//

import CoreData

extension Meme {
    convenience init(id: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = id
        self.modified = Date()
    }
}
