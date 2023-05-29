//
//  KBRecordVOC.swift
//  KBeaconPro
//
//  Created by mac on 2023/5/20.
//

import Foundation

@objc public class KBRecordVOC : KBRecordBase{
    
    @objc public static let VOC_RECORD_LEN = UInt8(8)
    
    @objc public var utcTime : UInt32
    
    @objc public var vocIndex : UInt16
    
    @objc public var noxIndex : UInt16

    
    @objc public required init()
    {
        utcTime = 0
        vocIndex = 0
        noxIndex = 0
        super.init()
    }
    
    public override func getRecordLen() -> UInt8
    {
        return KBRecordVOC.VOC_RECORD_LEN;
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

        //voc
        vocIndex = (UInt16(response[nRecordPtr]) << 8)
        vocIndex += UInt16(response[nRecordPtr + 1])
        nRecordPtr += 2
        
        //temperature
        noxIndex = (UInt16(response[nRecordPtr]) << 8)
        noxIndex += UInt16(response[nRecordPtr + 1])
        nRecordPtr += 2
        
        return true
    }
}
