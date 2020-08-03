//
//  MemesView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct MemesView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var memeController: MemeController
    @FetchRequest(entity: Meme.entity(), sortDescriptors: []) var memes: FetchedResults<Meme>
    
    var body: some View {
        List {
            ForEach(memes, id: \.self) { meme in
                NavigationLink(destination: MemeView(startingMeme: meme)) {
                    //TODO: Ensure this is running lazily / update it to be work lazily
                    if let container = memeController.container(for: meme) {
                        Image(uiImage: container.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64,
                                   height: container.thumbnailHeight)
                        VStack {
                            Text(meme.name ?? "[No name]")
                            if let destination = meme.destination {
                                Text(destination.name ?? "")
                                    .font(.caption)
                            }
                        }
                    } else {
                        Text(meme.name ?? "[No name]")
                            .onAppear {
                                //TODO: remove this whole onAppear and load the fetchedResults when the NavigationLink changes
                                memeController.load(memes)
                            }
                    }
                }
            }
        }
        .navigationTitle("Memes")
    }
}

struct MemesView_Previews: PreviewProvider {
    static var previews: some View {
        MemesView()
    }
}
