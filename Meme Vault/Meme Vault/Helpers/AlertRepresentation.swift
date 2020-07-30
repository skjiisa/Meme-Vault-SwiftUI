//
//  AlertRepresentation.swift
//  Meme Vault
//
//  Created by Isaac Lyons on 7/30/20.
//

import SwiftUI

class AlertRepresentation: Identifiable {
    var title: String
    var message: String?
    
    init(title: String, message: String? = nil) {
        self.title = title
        self.message = message
    }
    
    var alert: Alert {
        if let message = message {
            return Alert(title: Text(title), message: Text(message))
        }
        
        return Alert(title: Text(title))
    }
}
