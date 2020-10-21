//
//  ActionSet.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import Foundation

class ActionSet: ObservableObject {
    @Published var actions: [Action]
    
    init(actions: [Action] = []) {
        self.actions = actions
    }
}
