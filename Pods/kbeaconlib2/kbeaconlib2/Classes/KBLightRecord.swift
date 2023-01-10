//
//  KBLightRecord.swift
//  KBeaconPro
//
//  Created by mac on 2023/1/7.
//

import Foundation

@objc public class KBLightRecord : NSObject{
    @objc public var utcTime : UInt32
    
    @objc public var type : UInt8
    
    @objc public var pirIndication : UInt8
    
    @objc public var lightLevel : UInt16
    
    @objc public override init()
    {
        type = 0
        utcTime = 0
        pirIndication = 0
        lightLevel = 0
        
        super.init()
    }
}
