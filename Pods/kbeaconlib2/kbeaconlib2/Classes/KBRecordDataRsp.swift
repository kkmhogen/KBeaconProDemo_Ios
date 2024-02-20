//
//  KBRecordDataRsp.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/6/6.
//

import Foundation

@objc public class KBRecordDataRsp : NSObject
{
    public static let INVALID_DATA_RECORD_POS = UInt32(4294967295)

    @objc public var readDataNextPos: UInt32

    @objc public var readDataRspList : [NSObject]
    
    @objc public override init()
    {
        readDataNextPos = 0
        readDataRspList = []
        super.init()
    }
};
