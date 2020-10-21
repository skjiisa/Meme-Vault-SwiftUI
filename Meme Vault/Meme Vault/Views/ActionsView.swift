//
//  ActionsView.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import SwiftUI

struct ActionsView: View {
    @EnvironmentObject var actionController: ActionController
    
    var body: some View {
        List {
            ForEach(actionController.defaultActions, id: \.self) { action in
                Text(actionController.title(for: action))
            }
        }
        .navigationTitle("Actions")
    }
}

struct ActionsView_Previews: PreviewProvider {
    static var previews: some View {
        ActionsView()
    }
}
