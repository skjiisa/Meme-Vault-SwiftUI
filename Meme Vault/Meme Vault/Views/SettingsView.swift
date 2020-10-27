//
//  SettingsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/25/20.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink("WebDAV account", destination: LoginView())
            NavigationLink("Destinations", destination: DestinationsView())
            
            Section {
                NavigationLink("Actions", destination: ActionSetsView())
            }
            
            Section {
                NavigationLink("Excluded albums", destination: AlbumsView(exclude: true))
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Settings")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
