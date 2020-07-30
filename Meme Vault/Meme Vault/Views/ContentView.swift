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
                Text("Albums")
                    .imageScale(.large)
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
