//
//  MemeView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos

struct MemeView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var memeController: MemeController
    @EnvironmentObject var providerController: ProviderController
    @FetchRequest(entity: Destination.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "parent = nil")) var destinations: FetchedResults<Destination>
    
    @State private var currentMeme: Meme
    
    init?(startingMeme: Meme?) {
        guard let startingMeme = startingMeme else { return nil }
        _currentMeme = .init(initialValue: startingMeme)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                TabView(selection: $currentMeme) {
                    ForEach(memeController.memes, id: \.self) { meme in
                        Image(uiImage: memeController.container(for: meme)?.image, orSystemName: "photo", meme: meme)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .padding(memeController.images[meme] == nil ? (proxy.size.width - 40) / 2 : 0)
                            .border(Color(.cyan), width: 2)
                        // Remove this and uncomment tabViewStyle when Apple fixes PageTabViewStyle
                            .tabItem {
                                Text(meme.name ?? "Meme")
                            }
                    }
                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(width: proxy.size.width,
                       height: min(proxy.size.width, abs(proxy.size.height - 52)))
                
                HStack {
                    TextField("Name", text: $currentMeme.wrappedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    Button("Upload") {
                        providerController.upload(currentMeme, memeController: memeController)
                    }
                    .padding(.trailing)
                    .disabled(currentMeme.destination == nil)
                }
                
                //TODO: Maybe convert this to a new SwiftUI 2 list with children?
                List {
                    ForEach(destinations, id: \.self) { destination in
                        DestinationDisclosure(chosenDestination: $currentMeme.destination, destination: destination)
                    }
                }
            }
        }
        .border(Color(.green), width: 2)
        .navigationBarTitle("Meme")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: currentMeme) { meme in
            if memeController.assets != nil,
               meme == memeController.memes.last {
                memeController.getNextAssetMeme(context: moc)
            }
        }
    }
}
