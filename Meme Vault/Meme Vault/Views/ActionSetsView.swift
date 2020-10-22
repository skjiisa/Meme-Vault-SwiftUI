//
//  ActionSetsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/21/20.
//

import SwiftUI

struct ActionSetsView: View {
    @EnvironmentObject var actionController: ActionController
    
    @State private var editMode: EditMode = .inactive
    
    var addButton: some View {
        Button {
            actionController.createActionSet()
        } label: {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    var buttonStack: some View {
        HStack {
            EditButton()
                .padding(.trailing)
            addButton
        }
        .font(.body)
    }
    
    var body: some View {
        List {
            ForEach(actionController.actionSets) { actionSet in
                NavigationLink(actionSet.name, destination: ActionsView(actionSet: actionSet))
            }
            .onDelete { indexSet in
                actionController.removeActionSets(atOffsets: indexSet)
            }
            .onMove { indices, newOffset in
                actionController.moveActionSets(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .navigationTitle("Action Sets")
        .navigationBarItems(trailing: buttonStack)
        .sheet(item: $actionController.newActionSet) {
            withAnimation {
                actionController.actionSets.removeAll(where: { $0.name.isEmpty && $0.actions.count == 0 })
            }
        } content: { newActionSet in
            NavigationView {
                ActionsView(actionSet: newActionSet)
                    .environmentObject(actionController)
            }
        }
    }
}

struct ActionSetsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActionSetsView()
                .environmentObject(ActionController())
        }
    }
}
