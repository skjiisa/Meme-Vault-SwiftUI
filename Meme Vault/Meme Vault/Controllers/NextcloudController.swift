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
    
    //MARK: URLs
    
    /// Appends a file or directory name to a path.
    ///
    /// Appropriately handles the `/` between the path and new file name,
    /// so it doesn't matter whether or not the path ends with a `/`
    /// or whether or not the file name starts with a `/`.
    /// - Parameters:
    ///   - fileName: The file name to append.
    ///   - path: The path to append to.
    /// - Returns: the path with the file name appended.
    func append(fileNamed fileName: String, to path: String) -> String {
        var fileName = fileName
        if fileName.first == "/" {
            fileName.removeFirst()
        }
        
        if path.last == "/" {
            return path + fileName
        }
        
        return path + "/" + fileName
    }
    
    /// Sets a URL's protocol to HTTPS.
    ///
    /// If the URL is already using HTTPS, it returns the same URL.
    /// If the URL is using HTTP, it converts it to HTTPS.
    /// If the URL is using neither, it prefixes it with `https://`.
    /// - Parameter url: A String of the URL to set the protocol of.
    /// - Returns: the URL with an `https://` prefix.
    func https(_ url: String) -> String {
        if url.hasPrefix("https://") {
            return url
        }
        
        if url.hasPrefix("http://") {
            var newURL = url
            if let index = newURL.firstIndex(of: ":") {
                newURL.insert("s", at: index)
                return newURL
            }
        }
        
        return "https://" + url
    }
    
    /// Creates a Nextcloud URL given a base URL and a username.
    /// - Parameters:
    ///   - baseURL: The base URL of the Nextcloud server.
    ///   - username: The username of the Nextcloud account.
    /// - Returns: a URL of the format `[baseURL]/remote.php/dav/files/[username]/`.
    func nextcloudURL(baseURL: String, username: String) -> String {
        var url = baseURL
        url = append(fileNamed: "remote.php/dav/files/\(username)/", to: url)
        url = https(url)
        return url
    }
    
    //MARK: Nextcloud Content
    
    func testLogin(account: Account, password: String, completion: @escaping (_ success: Bool, _ errorDescription: String) -> Void) {
        guard let username = account.username,
              let baseURL = account.baseURL,
              !username.isEmpty,
              !baseURL.isEmpty else { return completion(false, "URL or username empty") }
        
        let nextcloudURL = self.nextcloudURL(baseURL: baseURL, username: username)
        
        NCCommunicationCommon.shared.remove(account: username)
        NCCommunicationCommon.shared.setup(account: username, user: username, userId: username, password: password, urlBase: nextcloudURL)
        NCCommunication.shared.readFileOrFolder(serverUrlFileName: nextcloudURL, depth: "", showHiddenFiles: false) { account, files, responseData, errorCode, errorDescription in
            print(account, nextcloudURL, username)
            print(errorCode, errorDescription)
            print(files.map { $0.fileName })
            
            completion(errorCode == 0, errorDescription)
            // If succeeded, save save password to Keychain
        }
    }
    
}
