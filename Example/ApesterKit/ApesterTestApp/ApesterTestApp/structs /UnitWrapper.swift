//
//  UnitWrapper.swift
//  ApesterTestApp
//
//  Created by Michael Krotorio on 11/29/23.
//

import Foundation
import SwiftUI

struct UnitWrapper: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // implement methods
    }
    
    let mediaId: String
    
    init(mediaId: String) {
        self.mediaId = mediaId
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "UnitWrapper")
    }
}
