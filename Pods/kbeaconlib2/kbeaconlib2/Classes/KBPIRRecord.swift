//
//  KBPIRRecord.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/6/5.
//

import Foundation

@objc public class KBPIRRecord : NSObject{
    @objc public var utcTime : UInt32
    @objc public var pirIndication : UInt8
    
    @objc public override init()
    {
        utcTime = 0
        pirIndication = 0
        
        super.init()
    }
}
