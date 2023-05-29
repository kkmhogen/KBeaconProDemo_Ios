//
//  KBRecordInfoRsp.swift
//  KBeaconPro
//
//  Created by mac on 2023/5/24.
//

import Foundation

@objc public class KBRecordInfoRsp : NSObject
{
    @objc public var sensorType: Int = 0
    
    @objc public var totalRecordNumber: UInt32 = 0

    @objc public var unreadRecordNumber: UInt32 = 0

    @objc public var readInfoUtcSeconds :UInt32 = 0
    
    @objc public override init()
    {
        super.init()
    }
};
