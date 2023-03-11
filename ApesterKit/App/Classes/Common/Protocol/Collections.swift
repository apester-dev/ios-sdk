//
//  Collections.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/7/22.
//
import Foundation
///
///
///
protocol Collection : AnyObject
{
    var isEmpty : Bool { get }
    var   count : Int  { get }
}
///
///
///
protocol OrderedCollection : Collection
{
    // MARK: Associated types
    
    /// The type of items in the data source.
    associatedtype Item
    
    // MARK: - Methods
    
    /// - Parameters:
    ///    - indexPath: An index path specifying a row and section in the data source.
    ///
    /// - returns: The item specified by indexPath, or `nil`.
    ///
    @discardableResult
    func item(at location: Int) -> Item?
}
