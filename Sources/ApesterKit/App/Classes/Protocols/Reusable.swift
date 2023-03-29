//
//  Reusable.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//

import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String { String(describing: self) }
}
