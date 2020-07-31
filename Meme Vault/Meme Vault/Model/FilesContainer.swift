//
//  FilesContainer.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import Foundation
import FilesProvider

class FilesContainer: ObservableObject {
    @Published var files: [FileObject] = []
    
    func addFolders(_ files: [FileObject]) {
        self.files = files.filter { $0.isDirectory }
    }
}
