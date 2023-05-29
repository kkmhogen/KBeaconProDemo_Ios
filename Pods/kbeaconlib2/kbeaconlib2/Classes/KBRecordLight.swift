//
//  KBRecordLight.swift
//  KBeaconPro
//
//  Created by mac on 2023/1/7.
//

import Foundation

@objc public class KBRecordLight : KBRecordBase
{
    @objc public static let LIGHT_RECORD_LEN = UInt8(8)

    @objc public var utcTime : UInt32
    
    @objc public var type : UInt8
        
    @objc public var lightLevel : UInt16
    
    @objc public required init()
    {
        type = 0
        utcTime = 0
        lightLevel = 0
        
        super.init()
    }
    
    public override func getRecordLen() -> UInt8
    {
        return KBRecordLight.LIGHT_RECORD_LEN;
    }
    
    public override func getSenorType()->Int
    {
        return KBSensorType.Light
    }
    
    public override func parseRecord(utcOffset: UInt32, response: Data, dataPtr: Int)->Bool
    {
        var nRecordPtr = dataPtr
        
        utcTime = ByteConvert.bytesTo4Long(value: response, offset: dataPtr)
        if (utcTime < KBRecordBase.MIN_UTC_TIME_SECONDS)
        {
            utcTime += utcOffset;
        }
        nRecordPtr += 4

        //record type
        type = response[nRecordPtr]
        nRecordPtr += 1

        //reserved
        nRecordPtr += 1

        //light level
        lightLevel = (UInt16(response[nRecordPtr]) << 8)
        lightLevel += UInt16(response[nRecordPtr + 1])
        nRecordPtr += 2
        
        return true
    }
}
