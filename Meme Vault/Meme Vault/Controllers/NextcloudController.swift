//
//  NextcloudController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/28/20.
//

import CoreData
import NCCommunication
import KeychainSwift

class NextcloudController: ObservableObject {
    
    //MARK: Account CRUD
    
    func createAccount(context: NSManagedObjectContext) -> Account {
        let newAccount = Account(context: context)
        try? context.save()
        return newAccount
    }
    
    func delete(account: Account, context: NSManagedObjectContext) {
        context.delete(account)
        try? context.save()
    }
    
    func delete(accounts: [Account], context: NSManagedObjectContext) {
        accounts.forEach { context.delete($0) }
        try? context.save()
    }
    
}
