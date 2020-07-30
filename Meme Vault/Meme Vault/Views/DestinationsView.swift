//
//  DestinationsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct DestinationsView: View {
    @Environment(\.managedObjectContext) var moc
    var destinationsFetchRequest: FetchRequest<Destination>
    var destinations: FetchedResults<Destination> {
        destinationsFetchRequest.wrappedValue
    }
    
    let parent: Destination?
    
    init(parent: Destination? = nil) {
        let predicate: NSPredicate
        if let parent = parent {
            predicate = NSPredicate(format: "parent = %@", parent)
        } else {
            predicate = NSPredicate(format: "parent = nil")
        }
        
        destinationsFetchRequest = FetchRequest(entity: Destination.entity(), sortDescriptors: [], predicate: predicate)
        self.parent = parent
    }
    
    var addDestinationButton: some View {
        Button("Add") {
            let newDestination = Destination(context: moc)
            newDestination.name = "New Destination"
            newDestination.path = "/asdf"
            newDestination.parent = parent
        }
    }
    
    var body: some View {
        List {
            ForEach(destinations, id: \.self) { destination in
                NavigationLink(destination: DestinationsView(parent: destination)) {
                    if let name = destination.name {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(name)
                                    .font(.body)
                                if let path = destination.path {
                                    Text(path)
                                        .font(.caption)
                                }
                            }
                            if let childrenCount = destination.children?.count, childrenCount > 0 {
                                Spacer()
                                Text("\(childrenCount) child\(childrenCount > 1 ? "ren" : "")")
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(parent?.name ?? "Destinations")
        .navigationBarItems(trailing: addDestinationButton)
    }
}

struct DestinationsView_Previews: PreviewProvider {
    static var previews: some View {
        DestinationsView()
    }
}
