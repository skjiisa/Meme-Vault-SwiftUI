//
//  DestinationView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct DestinationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var destination: Destination
    
    var doneButton: some View {
        Button("Done") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $destination.wrappedName)
        }
        .navigationTitle("Edit Destination")
        .navigationBarItems(trailing: doneButton)
    }
}
