//
//  FileBrowserView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI
import FilesProvider

struct FileBrowserView: View {
    @EnvironmentObject var providerController: ProviderController
    
    @ObservedObject var files = FilesContainer()
    @State private var fetchStarted = false
    @Binding var selectedPath: String
    @Binding var showingPaths: Bool
    
    let path: String
    
    var chooseButton: some View {
        Button("Choose") {
            selectedPath = path
            showingPaths = false
        }
    }
    
    var body: some View {
        List {
            ForEach(files.files, id: \.self) { file in
                NavigationLink(file.name, destination:
                                FileBrowserView(selectedPath: $selectedPath, showingPaths: $showingPaths, path: providerController.appendDirectory(file.name, to: path))
                                .environmentObject(providerController)
                )
            }
        }
        .navigationTitle(path)
        .navigationBarItems(trailing: chooseButton)
        .onAppear {
            guard !fetchStarted else { return }
            fetchStarted = true
            providerController.webdavProvider?.contentsOfDirectory(path: path, completionHandler: { files, error in
                if let error = error {
                    NSLog("\(error)")
                }
                
                DispatchQueue.main.async {
                    self.files.addFolders(files)
                }
            })
        }
    }
}

struct FileBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        FileBrowserView(selectedPath: .constant("/"), showingPaths: .constant(true), path: "/")
    }
}
