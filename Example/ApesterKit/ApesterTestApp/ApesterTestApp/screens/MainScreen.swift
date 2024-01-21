//
//  MainScreen.swift
//  ApesterTestApp
//
//  Created by Michael Krotorio on 11/29/23.
//

import Foundation
import SwiftUI

struct MainScreen: View {
    var body: some View {
        TabView {
            UnitWrapper(mediaId: "65673b98b5c744a440d4a8df")
            .tabItem {
                Text("Poll")
            }
            UnitWrapper(mediaId: "65673b98b5c744a440d4a8df")
            .tabItem {
                Text("Poll")
            }
            UnitWrapper(mediaId: "65673b98b5c744a440d4a8df")
            .tabItem {
                Text("Poll")
            }
        }
    }
}

