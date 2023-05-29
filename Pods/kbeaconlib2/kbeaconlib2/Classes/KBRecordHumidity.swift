//
//  KBRecordHumidity.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/26.
//

import Foundation

@objc public class KBRecordHumidity :KBRecordBase
{
    @objc public static let HT_RECORD_LEN = UInt8(8)

    @objc public var utcTime : UInt32
    
    @objc public var temperature : Float
    
    @objc public var humidity : Float
    
    @objc public required init()
    {
        utcTime = 0
        temperature = 0
        humidity = 0
        
        super.init()
    }
    
    public override func getRecordLen() -> UInt8
    {
        return KBRecordHumidity.HT_RECORD_LEN;
    }
    
    public override func getSenorType()->Int
    {
        return KBSensorType.Cutoff
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
        
        temperature = KBUtility.signedBytes2Float(byte1: Int8(bitPattern:response[nRecordPtr]), byte2: response[nRecordPtr + 1]);
        nRecordPtr += 2;

        humidity = KBUtility.signedBytes2Float(byte1: Int8(bitPattern:response[nRecordPtr]), byte2: response[nRecordPtr+1]);
        nRecordPtr += 2;
        
        return true
    }

}
