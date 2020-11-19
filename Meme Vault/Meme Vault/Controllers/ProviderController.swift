//
//  ProviderController.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI
import Photos
import CoreData
import FilesProvider

class ProviderController: ObservableObject {
    
    //MARK: Properties
    
    private(set) var webdavProvider: WebDAVFileProvider?
    
    private(set) var host: URL?
    private(set) var credential: URLCredential?
    
    private var uploadQueue: [String: Meme] = [:]
    private var contentRequestIDs: [PHAsset: PHContentEditingInputRequestID] = [:]
    
    private var memes: [String: Meme] = [:]
    @Published var uploadProgress: [Meme: Float] = [:]
    
    @Published var directories: [String: [FileObject]] = [:]
    
    init() {
        host = UserDefaults.standard.url(forKey: "host")
        loadCredentials()
        login()
    }
    
    //MARK: Credentials
    
    func login(host: String, username: String, password: String) {
        guard !host.isEmpty,
              let hostURL = URL(string: host),
              !username.isEmpty,
              !password.isEmpty else { return }
        login(host: hostURL, username: username, password: password)
    }
    
    func login(host: URL, username: String, password: String) {
        self.host = host
        UserDefaults.standard.set(host, forKey: "host")
        
        setCredentials(username: username, password: password)
        login()
    }
    
    private func loadCredentials() {
        guard let host = host?.absoluteString else { return }
        
        let space = URLProtectionSpace(host: host, port: 443, protocol: nil, realm: nil, authenticationMethod: nil)
        if let spaceCred = URLCredentialStorage.shared.defaultCredential(for: space) {
            credential = spaceCred
        }
    }
    
    private func setCredentials(username: String, password: String) {
        guard let host = host?.absoluteString else { return }
        
        let space = URLProtectionSpace(host: host, port: 443, protocol: nil, realm: nil, authenticationMethod: nil)

        let credential = URLCredential(user: username, password: password, persistence: .permanent)
        URLCredentialStorage.shared.set(credential, for: space)
        
        self.credential = credential
    }
    
    private func login() {
        guard let host = host,
            let credential = credential else { return }
        
        webdavProvider = WebDAVFileProvider(baseURL: host, credential: credential)
        webdavProvider?.delegate = self
    }
    
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
    
    //MARK: Pathing
    
    func append(fileNamed directory: String, to path: String) -> String {
        if path.last == "/" {
            return path + directory
        }
        
        return path + "/" + directory
    }
    
    func ssl(_ url: String) -> String {
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
    
    //MARK: Networking
    
    func upload(_ meme: Meme, memeController: MemeController, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void = {_ in}) {
        guard let destinationPath = meme.destination?.path else { return completion(false) }
        memeController.fetchImageData(for: meme) { imageData, dataUTI in
            guard let imageData = imageData,
                  let dataUTI = dataUTI,
                  let typeURL = URL(string: dataUTI) else { return completion(false) }
            
            let filename: String
            if let name = meme.name,
               !name.isEmpty {
                filename = "\(name).\(typeURL.pathExtension)"
            } else {
                // Temp default file name
                filename = typeURL.lastPathComponent
            }
            
            let path = self.append(fileNamed: filename, to: destinationPath)
            
            do {
                let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
                try imageData.write(to: tempFile)
                
                self.memes[tempFile.path] = meme
                
                self.webdavProvider?.copyItem(localFile: tempFile, to: path, overwrite: true, completionHandler: { error in
                    DispatchQueue.main.async {
                        try? FileManager.default.removeItem(at: tempFile)
                        self.memes.removeValue(forKey: tempFile.path)
                        self.uploadProgress.removeValue(forKey: meme)
                    }
                    
                    if let error = error {
                        NSLog("\(error)")
                        return completion(false)
                    }
                    
                    DispatchQueue.main.async {
                        meme.uploaded = true
                        meme.modified = Date()
                        try? context.save()
                        completion(true)
                    }
                })
            } catch {
                NSLog("\(error)")
                completion(false)
            }
        }
    }
    
    func fetchContents(ofDirectoryAtPath path: String) {
        webdavProvider?.contentsOfDirectory(path: path, completionHandler: { files, error in
            if let error = error {
                NSLog("\(error)")
            }

            DispatchQueue.main.async {
                withAnimation {
                    self.directories[path] = files.filter { $0.isDirectory }
                }
            }
        })
    }
    
}

//MARK: File provider delegate

extension ProviderController: FileProviderDelegate {
    func fileproviderSucceed(_ fileProvider: FileProviderOperations, operation: FileOperationType) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("\(source) copied to \(dest).")
        case .remove(path: let path):
            print("\(path) has been deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) succeed.")
            } else {
                print("\(operation.actionDescription) on \(operation.source) succeed.")
            }
        }
    }
    
    func fileproviderFailed(_ fileProvider: FileProviderOperations, operation: FileOperationType, error: Error) {
        switch operation {
        case .copy(source: let source, destination: let dest):
            print("copying \(source) to \(dest) has been failed.")
        case .remove:
            print("file can't be deleted.")
        default:
            if let destination = operation.destination {
                print("\(operation.actionDescription) from \(operation.source) to \(destination) failed.")
            } else {
                print("\(operation.actionDescription) on \(operation.source) failed.")
            }
        }
    }
    
    func fileproviderProgress(_ fileProvider: FileProviderOperations, operation: FileOperationType, progress: Float) {
        switch operation {
        case .copy(source: let source, destination: let dest) where dest.hasPrefix("file://"):
            print("Downloading \(source) to \((dest as NSString).lastPathComponent): \(progress * 100) completed.")
        case .copy(source: let source, destination: let dest) where source.hasPrefix("file://"):
            print("Uploading \((source as NSString).lastPathComponent) to \(dest): \(progress * 100) completed.")
            
            // Log the progress
            let tempFile = String(source.dropFirst(7))
            if let meme = memes[tempFile] {
                withAnimation {
                    uploadProgress[meme] = progress
                }
            }
        case .copy(source: let source, destination: let dest):
            print("Copy \(source) to \(dest): \(progress * 100) completed.")
        default:
            break
        }
    }
}
