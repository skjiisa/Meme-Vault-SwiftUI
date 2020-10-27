//
//  DestinationDisclosure.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct DestinationDisclosure: View {
    var fetchRequest: FetchRequest<Destination>
    var children: FetchedResults<Destination> {
        fetchRequest.wrappedValue
    }
    
    @Binding var chosenDestination: Destination?
    
    let destination: Destination
    var meme: Meme?
    
    init(chosenDestination: Binding<Destination?>, destination: Destination, meme: Meme? = nil) {
        _chosenDestination = chosenDestination
        self.destination = destination
        
        self.fetchRequest = FetchRequest(entity: Destination.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "parent = %@", destination))
    }
    
    var chooseButton: some View {
        Button(destination.name ?? "Destination") {
            chosenDestination = destination
            meme?.modified = Date()
        }
        .foregroundColor(.accentColor)
        .disabled(chosenDestination == destination)
    }
    
    var body: some View {
        if children.count > 0 {
            DisclosureGroup {
                ForEach(children) { child in
                    DestinationDisclosure(chosenDestination: $chosenDestination, destination: child)
                }
            } label: {
                chooseButton
            }
        } else {
            chooseButton
        }
    }
}
