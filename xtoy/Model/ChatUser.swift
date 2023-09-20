//
//  ChatUser.swift
//  xtoy
//
//  Created by DeAndre Lim Hai Jie on 6/9/23.
//

import Foundation

struct ChatUser {
    let xId, xEmail, xName, xProfileImageUrl, pair, yId, yEmail, yName, yProfileImageUrl: String
    
    init(data: [String: Any]) {
        xId = data["xId"] as? String ?? ""
        xEmail = data["xEmail"] as? String ?? ""
        xName = data["xName"] as? String ?? ""
        xProfileImageUrl = data["xProfileImageUrl"] as? String ?? ""
        
        pair = data["pair"] as? String ?? ""
        
        yId = data["yId"] as? String ?? ""
        yEmail = data["yEmail"] as? String ?? ""
        yName = data["yName"] as? String ?? ""
        yProfileImageUrl = data["yProfileImageUrl"] as? String ?? ""
    }
}
