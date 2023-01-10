//
//  KBReadSensorResponse.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/6/6.
//

import Foundation

@objc public class KBReadSensorRsp : NSObject
{
    @objc public var readDataNextPos: UInt32

    @objc public var readDataRspList : [NSObject]
    
    @objc public override init()
    {
        readDataNextPos = 0
        readDataRspList = []
        super.init()
    }
};
