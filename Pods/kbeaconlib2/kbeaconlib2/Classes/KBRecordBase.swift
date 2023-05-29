//
//  KBRecordBase.swift
//  KBeaconPro
//
//  Created by mac on 2023/5/20.
//

import Foundation

@objc public class KBRecordBase : NSObject{
    @objc public static let MIN_UTC_TIME_SECONDS = 946080000
    
    @objc required override init()
    {
        super.init()
    }

    func getRecordLen()->UInt8
    {
        return 0
    }
    
    func getSenorType()->Int
    {
        return 0
    }
    
    func parseRecord(utcOffset: UInt32, response: Data, dataPtr: Int)->Bool
    {
        return false
    }
}
