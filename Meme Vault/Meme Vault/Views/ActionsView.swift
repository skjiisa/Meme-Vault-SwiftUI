//
//  ActionsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import SwiftUI

struct ActionsView: View {
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var actionController: ActionController
    
    @ObservedObject var actionSet: ActionSet
    
    @State private var showingAddAction = false
    @State private var showingAlbumPicker = false
    @State private var addToAlbum = false
    
    var actionButtons: [ActionSheet.Button] {
        [Action.share, Action.delete, Action.removeFromAlbum(id: nil)].compactMap { action in
            guard !actionSet.actions.contains(action) else { return nil }
            return ActionSheet.Button.default(Text(actionController.title(for: action))) {
                withAnimation {
                    actionSet.add(action: action)
                }
            }
        } + [
            .default(Text("Remove from album...")) {
                addToAlbum = false
                showingAlbumPicker = true
            },
            .default(Text("Add to album...")) {
                addToAlbum = true
                showingAlbumPicker = true
            },
            .cancel()
        ]
    }
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Action Set Name", text: $actionSet.name)
            }
            
            Section(header: Text("Actions")) {
                ForEach(actionSet.actions, id: \.self) { action in
                    Text(actionController.title(for: action))
                }
                .onDelete { indexSet in
                    actionSet.actions.remove(atOffsets: indexSet)
                }
                .onMove { indices, newOffset in
                    actionSet.actions.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    Button("Add Action") {
                        showingAddAction = true
                    }
                    .foregroundColor(.accentColor)
                    // I wish I didn't have to disable the button in edit
                    // mode, but it doesn't work in edit mode anyway, so
                    // this is to make the UI more clear.
                    .disabled(editMode?.wrappedValue.isEditing ?? false)
                    Spacer()
                }
            }
        }
        .navigationTitle("Actions")
        .navigationBarItems(trailing: EditButton())
        .actionSheet(isPresented: $showingAddAction) {
            ActionSheet(title: Text("Add Action"), buttons: actionButtons)
        }
        .sheet(isPresented: $showingAlbumPicker) {
            NavigationView {
                AlbumsView() { assetCollection in
                    showingAlbumPicker = false
                    withAnimation {
                        if addToAlbum {
                            actionSet.add(action: .addToAlbum(id: assetCollection.localIdentifier))
                        } else {
                            actionSet.add(action: .removeFromAlbum(id: assetCollection.localIdentifier))
                        }
                    }
                }
                .environmentObject(actionController)
            }
        }
    }
    
}

struct ActionsView_Previews: PreviewProvider {
    static let actionController = ActionController()
    
    static var previews: some View {
        NavigationView {
            NavigationLink("", destination: ActionsView(actionSet: actionController.actionSets[0]), isActive: .constant(true))
        }
        .environmentObject(actionController)
    }
}
