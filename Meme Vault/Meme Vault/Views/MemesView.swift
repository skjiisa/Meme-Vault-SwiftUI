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
                if let container = memeController.images[meme] {
                    NavigationLink(destination: MemeView(memeContainer: container), label: {
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
                    })
                } else {
                    Text(meme.name ?? "[No name]")
                        .onAppear {
                            memeController.fetchImage(for: meme)
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
