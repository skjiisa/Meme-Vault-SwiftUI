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
            Text("Destinations")
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
