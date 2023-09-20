//
//  ChatMessage.swift
//  xtoy
//
//  Created by DeAndre Lim Hai Jie on 10/9/23.
//

import Foundation

struct ChatMessage: Identifiable {
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, message: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        fromId = data["fromId"] as? String ?? ""
        toId = data["toId"] as? String ?? ""
        message = data["message"] as? String ?? ""
    }
}
