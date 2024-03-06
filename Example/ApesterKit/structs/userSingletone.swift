//
//  userSingletone.swift
//  ApesterKit_Example
//
//  Created by Michael Krotorio on 1/28/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

@objcMembers class UserInfo: NSObject {
    static let shared = UserInfo()

    var userId: String?
    var userEmail: String?
    var favoriteId: String?
    // Add other user-related properties here

   override private init() {} // Private initialization to ensure just one instance is created.

    func setUserInfo(userId: String, userEmail: String, favoriteId: String?) {
        self.userId = userId
        self.userEmail = userEmail
        self.favoriteId = favoriteId
        // Set other properties as needed
    }
    func setUserFavorite(favoriteId: String?){
        self.favoriteId = favoriteId
    }

    func clearUserInfo() {
        userId = nil
        userEmail = nil
        // Clear other properties as needed
    }
}
