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
            NavigationLink("WebDAV Account", destination: LoginView())
            NavigationLink("Destinations", destination: DestinationsView())
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Settings")
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}