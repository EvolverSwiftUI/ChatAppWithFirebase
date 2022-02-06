//
//  ChatUser.swift
//  ChatAppWithFirebase
//
//  Created by Sivaram Yadav on 2/7/22.
//

import Foundation

struct ChatUser {
    
    let userId: String
    let email: String
    let profileImageUrl: String
    
    init(data: [String: Any]) {
        self.userId = data["userId"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
