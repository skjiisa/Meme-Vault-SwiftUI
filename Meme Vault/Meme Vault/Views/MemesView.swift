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
    @FetchRequest(
        entity: Meme.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Meme.modified, ascending: false)],
        predicate: NSPredicate(format: "name != nil OR destination != nil OR uploaded == TRUE OR delete == TRUE"))
    var memes: FetchedResults<Meme>
    
    @State var selectedMeme: Meme?
    
    var body: some View {
        List {
            ForEach(memes) { meme in
                NavigationLink(destination: MemeView(), tag: meme, selection: $selectedMeme) {
                    HStack {
                        if let image = memeController.images[meme] {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64,
                                       height: 64 * min(1, image.size.height / image.size.width))
                                .opacity(meme.delete ? 0.5 : 1.0)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(meme.name ?? "[No name]")
                            Text(optionalString: meme.destination?.name)
                                .font(.caption)
                        }
                        .foregroundColor(meme.delete ? .secondary : .primary)
                        
                        if meme.uploaded || meme.delete {
                            Spacer()
                            if meme.delete {
                                Image(systemName: "trash")
                            }
                            if meme.uploaded {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
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
            if let meme = meme {
                memeController.load(memes)
                memeController.currentMeme = meme
            }
        }
    }
}

struct MemesView_Previews: PreviewProvider {
    static var previews: some View {
        MemesView()
    }
}
