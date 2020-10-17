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
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: Destination.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "parent = nil")) var destinations: FetchedResults<Destination>
    
    @EnvironmentObject var memeController: MemeController
    @EnvironmentObject var providerController: ProviderController
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                TabView(selection: $memeController.currentMeme) {
                    ForEach(memeController.memes) { meme in
                        ImageView(meme: meme)
                            .padding(memeController.images[meme] == nil ? (proxy.size.width - 40) / 2 : 0)
                            .tag(meme as Meme?)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(width: proxy.size.width,
                       height: min(proxy.size.width, abs(proxy.size.height - 52)))
                
                if let meme = memeController.currentMeme {
                    MemeForm(meme: meme)
                }
            }
        }
        .border(Color(.green), width: 2)
        .navigationBarTitle("Meme")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if memeController.currentMeme == nil {
                memeController.currentMeme = memeController.memes.first
            }
        }
        .onDisappear {
            if !presentationMode.wrappedValue.isPresented {
                memeController.currentMeme = nil
            }
            try? moc.save()
        }
    }
}

struct ImageView: View {
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var memeController: MemeController
    @State private var fetchStarted = false
    
    var meme: Meme
    
    var body: some View {
        Image(uiImage: memeController.images[meme], orSystemName: "photo")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .border(Color(.cyan), width: 2)
            .onAppear {
                if !fetchStarted {
                    memeController.fetchImage(for: meme)
                    fetchStarted = true
                }
                
                /*
                // SwiftUI has a bug where TabViews don't update to load new data
                // So this functionality to add new Memes to the end of the list
                // dosn't work.
                if memeController.assets != nil,
                   meme == memeController.memes.last {
                    memeController.getNextAssetMeme(context: moc)
                    print(memeController.memes.count)
                }
                 */
            }
    }
}

struct MemeForm: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        predicate: NSPredicate(format: "parent = nil"))
    var destinations: FetchedResults<Destination>
    
    @EnvironmentObject var memeController: MemeController
    @EnvironmentObject var providerController: ProviderController
    
    @ObservedObject var meme: Meme
    
    var body: some View {
        HStack {
            TextField("Name", text: $meme.wrappedName, onCommit: {
                meme.modified = Date()
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
            Button("Upload") {
                providerController.upload(meme, memeController: memeController, context: moc)
            }
            .padding(.trailing)
            .disabled(meme.destination == nil)
        }
        
        List {
            ForEach(destinations) { destination in
                DestinationDisclosure(chosenDestination: $meme.destination, destination: destination, meme: meme)
            }
        }
    }
}
