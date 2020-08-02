//
//  MemeView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos

struct MemeView: View {
    @EnvironmentObject var memeController: MemeController
    @EnvironmentObject var providerController: ProviderController
    @FetchRequest(entity: Destination.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "parent = nil")) var destinations: FetchedResults<Destination>
    
    @ObservedObject var memeContainer: MemeContainer
    
    init?(memeContainer: MemeContainer?) {
        guard let memeContainer = memeContainer else { return nil }
        self.memeContainer = memeContainer
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                Image(uiImage: memeContainer.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: proxy.size.width,
                           height: memeContainer.scaledHeight(frameSize: proxy.size))
                    .border(Color(.cyan), width: 2)
                
                HStack {
                    TextField("Name", text: $memeContainer.meme.wrappedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    Button("Upload") {
                        providerController.upload(memeContainer.meme, memeController: memeController)
                    }
                    .padding(.trailing)
                    .disabled(memeContainer.meme.destination == nil)
                }
                
                List {
                    ForEach(destinations, id: \.self) { destination in
                        DestinationDisclosure(chosenDestination: $memeContainer.meme.destination, destination: destination)
                    }
                }
            }
        }
        .border(Color(.green), width: 2)
        .navigationBarTitle("Meme")
        .navigationBarTitleDisplayMode(.inline)
    }
}
