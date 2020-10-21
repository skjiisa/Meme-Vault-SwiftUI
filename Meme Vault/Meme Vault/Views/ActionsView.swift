//
//  ActionsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import SwiftUI

struct ActionsView: View {
    @EnvironmentObject var actionController: ActionController
    
    @ObservedObject var actionSet: ActionSet
    
    var body: some View {
        List {
            ForEach(actionSet.actions, id: \.self) { action in
                Text(actionController.title(for: action))
            }
        }
        .navigationTitle("Actions")
    }
}

struct ActionsView_Previews: PreviewProvider {
    static let actionController = ActionController()
    
    static var previews: some View {
        NavigationView {
            ActionsView(actionSet: actionController.defaultActions)
                .environmentObject(actionController)
        }
    }
}
