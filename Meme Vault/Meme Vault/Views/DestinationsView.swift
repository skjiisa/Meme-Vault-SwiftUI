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
    
    @State private var newDestination: Destination?
    
    let parent: Destination?
    
    init(parent: Destination? = nil) {
        let predicate: NSPredicate
        if let parent = parent {
            predicate = NSPredicate(format: "parent = %@", parent)
        } else {
            predicate = NSPredicate(format: "parent = nil")
        }
        
        destinationsFetchRequest = FetchRequest(entity: Destination.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: predicate)
        self.parent = parent
    }
    
    var addDestinationButton: some View {
        Button("Add") {
            let destination = Destination(context: moc)
            destination.path = "/"
            destination.parent = parent
            
            newDestination = destination
        }
    }
    
    var body: some View {
        List {
            ForEach(destinations, id: \.self) { destination in
                NavigationLink(destination: DestinationsView(parent: destination)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(destination.name ?? "")
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
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                let destination = destinations[index]
                moc.delete(destination)
            }
        }
        .navigationBarTitle(parent?.name ?? "Destinations")
        .navigationBarItems(trailing: addDestinationButton)
        .sheet(item: $newDestination) {
            try? moc.save()
        } content: { destination in
            NavigationView {
                DestinationView(destination: destination)
            }
        }

    }
}

struct DestinationsView_Previews: PreviewProvider {
    static var previews: some View {
        DestinationsView()
    }
}
