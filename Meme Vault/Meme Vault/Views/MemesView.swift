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
    
    @State var selectedMeme: Meme?
    
    var body: some View {
        List {
            ForEach(memes, id: \.self) { meme in
                NavigationLink(destination: MemeView(startingMeme: meme), tag: meme, selection: $selectedMeme) {
                    Image(memeContainer: memeController.container(for: meme))?
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64,
                               height: memeController.container(for: meme)?.thumbnailHeight ?? 64)
                    VStack(alignment: .leading) {
                        Text(meme.name ?? "[No name]")
                        Text(optionalString: meme.destination?.name)
                            .font(.caption)
                    }
                }
            }
            .onDelete(perform: { indexSet in
                guard let index = indexSet.first else { return }
                memeController.delete(meme: memes[index], context: moc)
            })
        }
        .navigationTitle("Memes")
        .onChange(of: selectedMeme) { meme in
            if meme != nil {
                memeController.load(memes)
            }
        }
    }
}

struct MemesView_Previews: PreviewProvider {
    static var previews: some View {
        MemesView()
    }
}
