//
//  Action.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 10/20/20.
//

import Foundation

enum Action: Hashable {
    case share
    case delete
    case favorite
    case unfavorite
    case addToAlbum(id: String)
    case removeFromAlbum(id: String?)
}

extension Action: CaseIterable {
    static var allCases: [Action] {[
        share,
        delete,
        favorite,
        unfavorite,
        addToAlbum(id: ""),
        removeFromAlbum(id: nil)
    ]}
}

extension Action: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case action, id
    }
    
    private enum ActionKey: String, Codable {
        case share, delete, favorite, unfavorite, addToAlbum, removeFromAlbum
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let action = try container.decode(ActionKey.self, forKey: .action)
        switch action {
        case .share:
            self = .share
        case .delete:
            self = .delete
        case .favorite:
            self = .favorite
        case .unfavorite:
            self = .unfavorite
        case .addToAlbum:
            let id = try container.decode(String.self, forKey: .id)
            self = .addToAlbum(id: id)
        case .removeFromAlbum:
            let id = try container.decode(String?.self, forKey: .id)
            self = .removeFromAlbum(id: id)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .share:
            try container.encode(ActionKey.share, forKey: .action)
        case .delete:
            try container.encode(ActionKey.delete, forKey: .action)
        case .favorite:
            try container.encode(ActionKey.favorite, forKey: .action)
        case .unfavorite:
            try container.encode(ActionKey.unfavorite, forKey: .action)
        case .addToAlbum(id: let id):
            try container.encode(ActionKey.addToAlbum, forKey: .action)
            try container.encode(id, forKey: .id)
        case .removeFromAlbum(id: let id):
            try container.encode(ActionKey.removeFromAlbum, forKey: .action)
            try container.encode(id, forKey: .id)
        }
    }
    
}
