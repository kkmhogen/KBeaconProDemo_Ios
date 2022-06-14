//
//  KBCutoffRecord.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/6/5.
//

import Foundation

@objc public class KBCutoffRecord :NSObject{
    @objc public var utcTime : UInt32
    @objc public var cutoffFlag : UInt8
    
    @objc public override init()
    {
        utcTime = 0
        cutoffFlag = 0
        
        super.init()
    }
}
