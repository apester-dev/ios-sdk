//
//  ViewModelable.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//

import UIKit

protocol ViewModelable {
    associatedtype VM: ViewModel
    var viewModel: VM! { get set }
}

extension ViewModelable where Self: UIViewController {
    
    init(viewModel: VM) {
        self.init()
        self.viewModel = viewModel
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, viewModel: VM) {
        
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.viewModel = viewModel
    }
}

extension ViewModelable where Self: UICollectionViewController {
    
    init(collectionViewLayout layout: UICollectionViewLayout, viewModel: VM) {
        
        self.init(collectionViewLayout: layout)
        self.viewModel = viewModel
    }
}
