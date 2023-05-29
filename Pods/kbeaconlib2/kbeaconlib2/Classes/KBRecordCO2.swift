//
//  KBRecordCO2.swift
//  KBeaconPro
//
//  Created by mac on 2023/5/20.
//

import Foundation

@objc public class KBRecordCO2 : KBRecordBase{
    
    @objc public static let CO2_RECORD_LEN = UInt8(10)

    
    @objc public var utcTime : UInt32
    
    @objc public var CO2 : UInt16
    
    @objc public var temperature : Float
    
    @objc public var humidity : Float
    
    @objc public required init()
    {
        utcTime = 0
        CO2 = 0
        temperature = 0.0
        humidity = 0.0
        
        super.init()
    }
    
    public override func getRecordLen() -> UInt8
    {
        return KBRecordCO2.CO2_RECORD_LEN;
    }
    
    public override func getSenorType()->Int
    {
        return KBSensorType.VOC
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

        //co2
        CO2 = (UInt16(response[nRecordPtr]) << 8)
        CO2 += UInt16(response[nRecordPtr + 1])
        nRecordPtr += 2
        
        //temperature
        temperature = KBUtility.signedBytes2Float(byte1: Int8(bitPattern:response[nRecordPtr]), byte2: response[nRecordPtr + 1]);
        nRecordPtr += 2;

        //humidity
        humidity = KBUtility.signedBytes2Float(byte1: Int8(bitPattern:response[nRecordPtr]), byte2: response[nRecordPtr+1]);
        nRecordPtr += 2;
        
        return true
    }
}
