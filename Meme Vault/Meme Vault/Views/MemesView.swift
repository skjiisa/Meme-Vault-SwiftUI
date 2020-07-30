//
//  MemesView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

struct MemesView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Meme.entity(), sortDescriptors: []) var memes: FetchedResults<Meme>
    
    @State private var images: [Meme: UIImage] = [:]
    
    private func fetchImage(for meme: Meme) {
        
    }
    
    var body: some View {
        List {
            ForEach(memes, id: \.self) { meme in
                HStack {
                    if let image = images[meme] {
                        Image(uiImage: image)
                    }
                    Text(meme.name ?? "[No name]")
                }
                .onAppear {
                    fetchImage(for: meme)
                }
            }
        }
    }
}

struct MemesView_Previews: PreviewProvider {
    static var previews: some View {
        MemesView()
    }
}
