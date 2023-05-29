//
//  KBRecordPIR.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/6/5.
//

import Foundation

@objc public class KBRecordPIR : KBRecordBase
{
    @objc public static let PIR_RECORD_LEN = UInt8(5)
    
    @objc public var utcTime : UInt32

    @objc public var pirIndication : UInt8
    
    @objc public required init()
    {
        utcTime = 0
        pirIndication = 0
        
        super.init()
    }
    
    public override func getRecordLen() -> UInt8
    {
        return KBRecordPIR.PIR_RECORD_LEN;
    }
    
    public override func getSenorType()->Int
    {
        return KBSensorType.PIR
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

        //pir type
        pirIndication = response[nRecordPtr];
        nRecordPtr += 1
        
        return true
    }
}
