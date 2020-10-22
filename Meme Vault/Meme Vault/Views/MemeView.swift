//
//  MemeView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/22/20.
//

import SwiftUI
import Photos

//MARK: Meme View

struct MemeView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: Destination.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "parent = nil")) var destinations: FetchedResults<Destination>
    
    @EnvironmentObject var memeController: MemeController
    @EnvironmentObject var providerController: ProviderController
    
    @State private var maxHeight: CGFloat = 0
    
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
                       // Ideally make the image square.
                       // If the keyboard is showing, make the image 64
                       // pixels shorter than the frame to give space
                       // for the text field.
                       // Otherwise, make sure it doesn't take up more
                       // than 2/3 of the screen height.
                       height: min(proxy.size.width,
                                   proxy.size.height < maxHeight
                                    ? abs(proxy.size.height - 64)
                                    : proxy.size.height * 3/5))
                
                if let meme = memeController.currentMeme {
                    MemeForm(meme: meme)
                }
            }
            .onAppear {
                maxHeight = proxy.size.height
            }
            // This could potentially be removed,
            // assuming the view appears at its max height
            // (i.e., without the keyboard showing).
            .onChange(of: proxy.size.height) { height in
                if height > maxHeight {
                    maxHeight = height
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

//MARK: Image View

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

//MARK: Meme Form

struct MemeForm: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        predicate: NSPredicate(format: "parent = nil"))
    var destinations: FetchedResults<Destination>
    
    @EnvironmentObject var memeController: MemeController
    @EnvironmentObject var providerController: ProviderController
    @EnvironmentObject var actionController: ActionController
    
    @ObservedObject var meme: Meme
    
    @State private var showingActions = false
    @State private var shareSheet: ShareSheet? = nil
    @State private var showingShareSheet = false
    
    var body: some View {
        ProgressView(value: providerController.uploadProgress[meme]
                        ?? meme.uploaded.float)
        
        HStack {
            TextField("Name", text: $meme.wrappedName, onCommit: {
                meme.modified = Date()
            })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
            Button("Upload") {
                dismissKeyboard()
                providerController.upload(meme, memeController: memeController, context: moc) { success in
                    if success {
                        DispatchQueue.main.async {
                            withAnimation {
                                memeController.nextMeme()
                            }
                        }
                    }
                }
            }
            .padding(.trailing)
            .disabled(meme.destination == nil)
        }
        
        ScrollViewReader { proxy in
            List {
                Picker("Tab", selection: $showingActions) {
                    Text("Destinations").tag(false)
                    Text("Actions").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: showingActions) { _ in
                    withAnimation {
                        proxy.scrollTo(1, anchor: .top)
                    }
                }
                .onChange(of: meme.uploaded) { uploaded in
                    if uploaded {
                        withAnimation {
                            showingActions = true
                        }
                    }
                }
                
                if !showingActions {
                    ForEach(destinations) { destination in
                        DestinationDisclosure(chosenDestination: $meme.destination, destination: destination, meme: meme)
                    }
                    .id(1)
                } else {
                    ForEach(actionController.defaultActions, id: \.self) { action in
                        Button {
                            perform(action: action)
                        } label: {
                            Text(actionController.title(for: action))
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(1, anchor: .top)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            shareSheet = nil
        } content: {
            if let shareSheet = shareSheet {
                shareSheet
            } else {
                EmptyView()
            }
        }
    }
    
    func perform(action: Action) {
        guard let asset = memeController.fetchAsset(for: meme) else { return }
        switch action {
        case .share:
            memeController.share(meme: meme) { shareSheet in
                self.shareSheet = shareSheet
                showingShareSheet = shareSheet != nil
            }
        case .delete:
            memeController.markForDelete(meme: meme, context: moc)
        default:
            actionController.perform(action: action, on: asset)
        }
    }
}
