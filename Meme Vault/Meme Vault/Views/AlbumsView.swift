//
//  AlbumsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos
import CoreData

struct AlbumsView: View {
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var memeController: MemeController
    @EnvironmentObject var actionController: ActionController
    
    var exclude: Bool = false
    var onSelect: ((PHAssetCollection) -> Void)? = nil
    
    init() {}
    
    init(exclude: Bool) {
        self.exclude = exclude
    }
    
    init(onSelect: @escaping (PHAssetCollection) -> Void) {
        self.onSelect = onSelect
    }
    
    var refreshButton: some View {
        Button("Refresh") {
            actionController.refreshAlbums()
        }
        .font(.body)
    }
    
    var body: some View {
        List {
            ForEach(actionController.albums) { album in
                let title = album.localizedTitle ?? "Unknown Album"
                
                if exclude || onSelect != nil {
                    HStack {
                        Button(title) {
                            if exclude {
                                memeController.excludedAlbums.toggle(album)
                            } else if let select = onSelect {
                                select(album)
                            }
                        }
                        if exclude,
                           memeController.excludedAlbums.contains(album) {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                } else {
                    NavigationLink(title, destination: MemeView(), tag: album, selection: $actionController.currentAlbum)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Albums")
        .navigationBarItems(trailing: refreshButton)
        .onChange(of: actionController.currentAlbum) { album in
            if let album = album {
                memeController.fetchImages(for: album, context: moc)
                actionController.currentAlbum = album
            } else {
                memeController.assets = nil
            }
        }
        .onDisappear {
            if exclude {
                memeController.saveToPersistentStore()
            }
        }
    }
}

struct AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlbumsView()
                .environmentObject(MemeController())
        }
    }
}
