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
    
    @State private var fetchStarted = false
    @Binding var selectedPath: String
    @Binding var showingPaths: Bool
    
    let path: String
    let addAll: (String) -> Void
    
    var chooseButton: some View {
        Button("Choose") {
            selectedPath = path
            showingPaths = false
        }
    }
    
    var body: some View {
        Form {
            ForEach(providerController.directories[path] ?? []) { file in
                NavigationLink(file.name, destination:
                                FileBrowserView(selectedPath: $selectedPath, showingPaths: $showingPaths, path: providerController.append(fileNamed: file.name, to: path), addAll: addAll)
                                .environmentObject(providerController)
                )
            }
            
            Section {
                Button() {
                    addAll(path)
                } label: {
                    HStack {
                        Spacer()
                        Text("Add All")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(path)
        .navigationBarItems(trailing: chooseButton)
        .onAppear {
            guard !fetchStarted else { return }
            fetchStarted = true
            providerController.fetchContents(ofDirectoryAtPath: path)
        }
    }
}

struct FileBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        FileBrowserView(selectedPath: .constant("/"), showingPaths: .constant(true), path: "/", addAll: {_ in})
    }
}
