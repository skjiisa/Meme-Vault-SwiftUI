//
//  ActionSetsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/21/20.
//

import SwiftUI

struct ActionSetsView: View {
    @EnvironmentObject var actionController: ActionController
    
    var body: some View {
        List {
            ForEach(actionController.actionSets) { actionSet in
                NavigationLink(actionSet.name, destination: ActionsView(actionSet: actionSet))
            }
        }
        .navigationTitle("Action Sets")
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
