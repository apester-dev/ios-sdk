//
//  Nibable.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//

import UIKit

protocol Nibable {

    static var nib: UINib { get }

    static func instantiate() -> Self
}

extension Nibable {
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: .main) }
}

extension Nibable where Self: UIView {
    static func instantiate() -> Self {
        return nib.instantiate(withOwner: self).first as! Self
    }
}

extension Nibable where Self: UIViewController {
    static func instantiate() -> Self {
        return Self(nibName: String(describing: self), bundle: .main)
    }
}

extension Nibable where Self: UIViewController, Self: ViewModelable {
    static func instantiate(with viewModel: VM) -> Self {
        return Self(nibName: String(describing: self), bundle: .main, viewModel: viewModel)
    }
}
