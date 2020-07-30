//
//  ContentView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos

struct ContentView: View {
    @State var showingAlbums = false
    
    let memeController = MemeController()
    
    var body: some View {
        TabView {
            NavigationView {
                if showingAlbums {
                    AlbumsView()
                } else {
                    Text("Please enable Photos access in the settings app")
                }
            }
            .tabItem {
                Image(systemName: "rectangle.stack.fill")
                    .imageScale(.large)
                Text("Albums")
            }
            
            NavigationView {
                MemesView()
            }
            .tabItem {
                Image(systemName: "photo.fill.on.rectangle.fill")
                    .imageScale(.large)
                Text("Memes")
            }
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gear")
                    .imageScale(.large)
                Text("Settings")
            }
        }
        .environmentObject(memeController)
        .onAppear {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    showingAlbums = true
                case .denied, .restricted:
                    print("Not allowed")
                    //TODO: Tell user how to enable access
                case .notDetermined:
                    print("Not determined yet")
                case .limited:
                    print("Limited access")
                    showingAlbums = true
                @unknown default:
                    break
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
