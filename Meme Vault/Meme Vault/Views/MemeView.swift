//
//  MemeView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos

struct MemeView: View {
    @FetchRequest(entity: Destination.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "parent = nil")) var destinations: FetchedResults<Destination>
    
    @ObservedObject var meme: Meme
//    @State var destination: Destination?
    let image: UIImage
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                let scaledHeight = image.size.height * proxy.size.width / image.size.width
                let staticHeight = scaledHeight > proxy.size.width ? proxy.size.width : scaledHeight
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width, height: staticHeight < (proxy.size.height - 52) ? staticHeight : (proxy.size.height - 52))
                    .border(Color(.cyan), width: 2)
                
                TextField("Name", text: $meme.wrappedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    .padding(.trailing)
                
                List {
                    ForEach(destinations, id: \.self) { destination in
                        DestinationDisclosure(chosenDestination: $meme.destination, destination: destination)
                    }
                }
            }
        }
        .border(Color(.green), width: 2)
        .navigationBarTitle("Meme")
        .navigationBarTitleDisplayMode(.inline)
    }
}
