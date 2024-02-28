//
//  WaitingScreenViewModel.swift
//  ApesterDemo
//
//  Created by Arkadi Yoskovitz on 12/5/22.
//
import Foundation
import ApesterKit
///
///
///
class WaitingScreenViewModel : NSObject , ViewModel
{
    // MARK: - Keys
    enum EncodingKeys : String , CustomStringConvertible
    {
        case persistence
        var description : String { self.rawValue }
    }
    
    // MARK: - properties
    var model: EnvironmentModel
    
    // MARK: -
    init(
        _ modelObject: EnvironmentModel
    ) {
        self.model = modelObject
        super.init()
    }
}
