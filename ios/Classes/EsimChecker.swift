//
//  EsimChecker.swift
//  flutter_esim
//
//  Created by Hien Nguyen on 29/02/2024.
//

import Foundation
import CoreTelephony

@available(iOS 10.0, *)
class EsimChecker: NSObject {
    
    
    
     
    // Minimum model numbers for eSIM support
    private let minSupportediPhone = "iPhone11,2" // iPhone XS (first eSIM model)
    private let minSupportediPad = "iPad6,8"     // iPad Pro 12.9" 1st Gen Cellular
    
    // Exceptions (models that shouldn't be supported despite meeting generation requirements)
    private let unsupportediPadModels: Set<String> = [
        "iPad6,11", // iPad 5th Gen (2017)
        "iPad6,12", // iPad 5th Gen (2017)
        "iPad7,5",  // iPad 6th Gen (2018)
        "iPad7,6"   // iPad 6th Gen (2018)
    ]
    
    public var handler: EventCallbackHandler?;
    
    
    public var identifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
    
    func isSupportESim() -> Bool {
        
        if identifier.hasPrefix("iPhone") {
            return isModelNumberGreaterOrEqual(identifier, reference: minSupportediPhone)
        } 
        else if identifier.hasPrefix("iPad") {
            return !unsupportediPadModels.contains(identifier) && 
                   isModelNumberGreaterOrEqual(identifier, reference: minSupportediPad)
        }
        return false
    }
    private func isModelNumberGreaterOrEqual(_ model: String, reference: String) -> Bool {
        let modelGen = model.components(separatedBy: .letters).compactMap { Int($0) }.first ?? 0
        let refGen = reference.components(separatedBy: .letters).compactMap { Int($0) }.first ?? 0
        return modelGen >= refGen
    }
    
    
    func installEsimProfile(address: String, matchingID: String?, oid: String?, confirmationCode: String?, iccid: String?, eid: String?) {
        let ctpr = CTCellularPlanProvisioningRequest();
        ctpr.address = address;
        if((matchingID) != nil) {
            ctpr.matchingID = matchingID;
        }
        if((oid) != nil) {
            ctpr.oid = oid
        }
        if((confirmationCode) != nil) {
            ctpr.confirmationCode = confirmationCode
        }
        if((iccid) != nil) {
            ctpr.iccid = iccid
        }
        if((eid) != nil) {
            ctpr.eid = eid
        }
        
        if #available(iOS 12.0, *) {
            let ctcp =  CTCellularPlanProvisioning()
            if(!ctcp.supportsCellularPlan()){
                handler?.send("unsupport", [:])
                return;
            }
            ctcp.addPlan(with: ctpr) { (result) in
                switch result {
                case .unknown:
                    self.handler?.send("unknown", [:])
                case .fail:
                    self.handler?.send("fail", [:])
                case .success:
                    self.handler?.send("success", [:])
                case .cancel:
                    self.handler?.send("cancel", [:])
                @unknown default:
                    self.handler?.send("unknown", [:])
                }
            }
        }
    }
    
    
}
