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
                .font(.body)
        }
    }
    
    var body: some View {
        List {
            ForEach(actionController.actionSets) { actionSet in
                NavigationLink(actionSet.name, destination: ActionsView(actionSet: actionSet))
            }
        }
        .navigationTitle("Action Sets")
        .navigationBarItems(trailing: addButton)
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
