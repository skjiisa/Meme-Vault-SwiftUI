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
    
    @State private var images: [Meme: UIImage] = [:]
    
    private func fetchImage(for meme: Meme) {
        guard images[meme] == nil else { return }
        memeController.fetchImage(for: meme) { image in
            guard let image = image else { return }
            images[meme] = image
        }
    }
    
    var body: some View {
        List {
            ForEach(memes, id: \.self) { meme in
                HStack {
                    if let image = images[meme] {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64,
                                   height: image.size.height < image.size.width ? 64 * image.size.height / image.size.width : 64)
                    }
                    Text(meme.name ?? "[No name]")
                }
                .onAppear {
                    fetchImage(for: meme)
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
