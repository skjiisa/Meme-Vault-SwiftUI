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
    
    var memesFetchRequest: FetchRequest<Meme>
    var memes: FetchedResults<Meme> {
        memesFetchRequest.wrappedValue
    }
    
    @State var selectedMeme: Meme?
    @State var showingTrash = false
    var showingDeletedMemes: Binding<Bool>?
    
    init(showDeletedMemes: Binding<Bool>? = nil) {
        let notEmpty = NSPredicate(format: "name != nil OR destination != nil OR uploaded == TRUE")
        let inTrash = NSPredicate(format: "delete == TRUE")
            
        let predicate: NSPredicate
        
        if showDeletedMemes != nil {
            /*
            // For some reason, I cannot get this inTrash predicate to be inverted.
            // None of the attempts in the `else` below work. I have no idea why,
            // and it makes no sense. Simply checking if a boolean is false should
            // be trivial, but I can't get it to work for the life of me.
            // So the feature to exclude deleted Memes is being left out for now.
        if let showDeletedMemes = showDeletedMemes {
             
            if showDeletedMemes.wrappedValue {
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [notEmpty, inTrash])
                predicate = inTrash
            } else {
                let notInTrash = NSCompoundPredicate(notPredicateWithSubpredicate: inTrash)
                let notInTrash = NSPredicate(format: "%K == %d", #keyPath(Meme.delete), false)
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [notEmpty, notInTrash])
                predicate = notEmpty
                predicate = notInTrash
            }
             */
            predicate = notEmpty
        } else {
            predicate = inTrash
        }
        
        memesFetchRequest = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Meme.modified, ascending: false)],
            predicate: predicate)
        
        showingDeletedMemes = showDeletedMemes
    }
    
    var trashButton: some View {
        Button {
            showingTrash = true
        } label: {
            Image(systemName: "trash")
                .imageScale(.large)
                .font(.body)
        }
    }
    
    var deleteAllButton: some View {
        Button("Delete All") {
            print("delete all")
        }
        .font(.body)
    }
    
    var body: some View {
        List {
            /* See init
            if let showingDeletedMemes = showingDeletedMemes {
                Toggle("Show deleted memes", isOn: showingDeletedMemes.animation())
            }
             */
            
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
        .listStyle(PlainListStyle())
        .navigationTitle("Memes")
        .navigationBarItems(trailing: showingDeletedMemes == nil ? AnyView(deleteAllButton) : AnyView(trashButton))
        .onChange(of: selectedMeme) { meme in
            if let meme = meme {
                memeController.load(memes)
                memeController.currentMeme = meme
            }
        }
        .sheet(isPresented: $showingTrash) {
            NavigationView {
                MemesView()
                    .environment(\.managedObjectContext, moc)
                    .environmentObject(memeController)
            }
        }
    }
}

struct MemesView_Previews: PreviewProvider {
    static var previews: some View {
        MemesView()
    }
}
