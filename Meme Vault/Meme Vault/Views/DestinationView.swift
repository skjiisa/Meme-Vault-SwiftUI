//
//  DestinationView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct DestinationView: View {
    @EnvironmentObject var providerController: ProviderController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var destination: Destination
    @State private var showingPaths = false
    
    var doneButton: some View {
        Button("Done") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Name", text: $destination.wrappedName)
            }
            
            Section(header: Text("Path")) {
                NavigationLink(destination: FileBrowserView(selectedPath: $destination.wrappedPath, showingPaths: $showingPaths, path: destination.path ?? "/").environmentObject(providerController), isActive: $showingPaths) {
                    Text(destination.wrappedPath)
                }
            }
        }
        .navigationTitle("Edit Destination")
        .navigationBarItems(trailing: doneButton)
        .onChange(of: destination.wrappedPath) { path in
            if destination.wrappedName.isEmpty {
                destination.name = (path as NSString).lastPathComponent
            }
        }
    }
}
