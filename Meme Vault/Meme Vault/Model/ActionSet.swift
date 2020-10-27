//
//  ActionSet.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import Foundation

class ActionSet: NSObject, ObservableObject, Identifiable, Codable {
    @Published var name: String
    @Published var actions: [Action]
    
    init(name: String, actions: [Action] = []) {
        self.name = name
        self.actions = actions
    }
    
    /// Appends the given `Action` to the actions list if it is not already present.
    /// - Parameter action: An `Action` to append to the actions list.
    ///
    /// Actions cannot be duplicated as `ActionsView` needs to be able to identify each action,
    /// and if there were duplicate actions, they couldn't be differentiated.
    ///
    /// There can, however, be multiple actions of the same _type_
    /// so long as they have different associated values.
    /// For example, there can be multiple `addToAlbum` actions
    /// if they are referencing different albums.
    func add(action: Action) {
        guard !actions.contains(action) else { return }
        actions.append(action)
    }
    
    //MARK: Codable
    
    enum CodingKeys: CodingKey {
        case name, actions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        actions = try container.decode([Action].self, forKey: .actions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(actions, forKey: .actions)
    }
}
