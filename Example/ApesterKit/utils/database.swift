//
//  database.swift
//  ApesterKit_Example
//
//  Created by Michael Krotorio on 1/28/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Firebase
func saveFavorite(userName: String, favorite: String){
    let key = "\(userName)_favorite"
     UserDefaults.standard.set(favorite,forKey: key)
    UserInfo.shared.setUserFavorite(favoriteId: favorite)
    
}

func removeFavorite(userName: String) {
    let key = "\(userName)_favorite"
    UserDefaults.standard.removeObject(forKey: key)
    UserInfo.shared.setUserFavorite(favoriteId: nil)

}

func loadFavoriteItem(userName: String) -> String? {
    let key = "\(userName)_favorite"
    return UserDefaults.standard.string(forKey: key)
   
}


