//
//  ExtensionsSelector.swift
//
//
//  Created by Arkadi Yoskovitz on 12/4/22.
//
import ObjectiveC
///
///
///
extension Selector {
    
    public func isMember(of aProtocol: Protocol) -> Bool {
        
        if  isMember(of: aProtocol, isRequired: true , isInstance: true ) ||
            isMember(of: aProtocol, isRequired: true , isInstance: false) ||
            isMember(of: aProtocol, isRequired: false, isInstance: true ) ||
            isMember(of: aProtocol, isRequired: false, isInstance: false)
        {
            return true
        }
        return false
    }
    
    private func isMember(of aProtocol: Protocol, isRequired required: Bool, isInstance instance: Bool) -> Bool {
        
        var outCount = UInt32(0)
        guard let descriptions = protocol_copyMethodDescriptionList(aProtocol, required, instance, &outCount) else { return false }
        
        defer { descriptions.deallocate() }
        
        for itemIndex in 0 ... Int(outCount) {
            
            guard let name = descriptions[itemIndex].name , name == self else { continue }
            return true
        }
        return false
    }
}
