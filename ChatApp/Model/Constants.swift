//
//  Constants.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/8/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import Foundation
struct Constants {
    
    // MARK: NotificationKeys
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    // MARK: MessageFields
    
    struct MessageInfo {
        static let content = "content"
        static let photo = "photo"
        static let userId = "userId"
        static let date = "date"
        static let id = "id"
    }
    
    struct PersonInfo {
        static let name = "name"
        static let email = "email"
        static let photo = "photo"
        static let password = "password"
        static let id = "id"
    }
}
