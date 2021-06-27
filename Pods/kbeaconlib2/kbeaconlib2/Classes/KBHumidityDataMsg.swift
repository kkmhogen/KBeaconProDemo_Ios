//
//  KBHumidityDataMsg.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/26.
//

import Foundation

@objc public class ReadHTSensorInfoRsp : NSObject
{
    @objc public var totalRecordNumber: UInt32 = 0

    @objc public var unreadRecordNumber: UInt32 = 0

    @objc public var readInfoUtcSeconds :UInt32 = 0
    
    @objc public override init()
    {
        super.init()
    }
};

@objc public class ReadHTSensorDataRsp : NSObject
{
    @objc public var readDataNextPos: UInt32

    @objc public var readDataRspList : [KBHumidityRecord]
    
    @objc public override init()
    {
        readDataNextPos = 0
        readDataRspList = []
        super.init()
    }
};

@objc public class KBHumidityDataMsg : KBSensorDataMsgBase
{
    @objc public static let KBSensorDataTypeHumidity = Int(2)
    @objc public static let MIN_UTC_TIME_SECONDS = 946080000

    private var utcOffset:UInt32
    
    @objc public override init()
    {
        utcOffset = 0
    }

    @objc public override func getSensorDataType()->Int
    {
        return KBHumidityDataMsg.KBSensorDataTypeHumidity
    }

    @objc public override func parseSensorInfoResponse(_ beacon:KBeacon, dataPtr:Int, response:Data)->Any?
    {
        if (response.count -  dataPtr < 8)
        {
            return nil;
        }

        let infoRsp = ReadHTSensorInfoRsp()

        //total record number
        var nReadDataPos = dataPtr
        infoRsp.totalRecordNumber = UInt32(ByteConvert.bytesToShort(value: response, offset: nReadDataPos))
        nReadDataPos += 2

        //total record number
        infoRsp.unreadRecordNumber = UInt32(ByteConvert.bytesToShort(value: response, offset: nReadDataPos))
        nReadDataPos += 2

        //utc offset
        infoRsp.readInfoUtcSeconds = ByteConvert.bytesTo4Long(value:response, offset: nReadDataPos)
        utcOffset = UTCTime.getUTCTimeSecond() - infoRsp.readInfoUtcSeconds
        nReadDataPos += 4;
        
        return infoRsp
    }

    @objc public override func parseSensorDataResponse(_ beacon:KBeacon, dataPtr:Int, response:Data)->Any?
    {
        //sensor data type
        var nReadIndex = dataPtr;
        if (response[nReadIndex] != KBSensorType.HTHumidity)
        {
            NSLog("read HT response data type failed")
            return nil
        }
        nReadIndex += 1

        //next read data pos
        let readDataRsp = ReadHTSensorDataRsp();
        readDataRsp.readDataNextPos = ByteConvert.bytesTo4Long(value: response, offset: nReadIndex)
        nReadIndex += 4;

        //check payload length
        let nPayLoad = (response.count - nReadIndex);
        if (nPayLoad % 8 != 0)
        {
            readDataRsp.readDataNextPos = KBSensorDataMsgBase.INVALID_DATA_RECORD_POS;
            NSLog("parse HT response data failed")
            return nil
        }

        //read record
        if (nPayLoad >= 8)
        {
            var nRecordPtr = nReadIndex;
            let nTotalRecordLen = nPayLoad / 8
            for _ in 0..<nTotalRecordLen
            {
                let record = KBHumidityRecord();
                
                //utc time
                record.utcTime = ByteConvert.bytesTo4Long(value: response, offset: nRecordPtr)
                if (record.utcTime < KBHumidityDataMsg.MIN_UTC_TIME_SECONDS)
                {
                    record.utcTime += self.utcOffset;
                }
                nRecordPtr += 4;

                record.temperature = KBUtility.signedBytes2Float(byte1: Int8(bitPattern:response[nRecordPtr]), byte2: response[nRecordPtr + 1]);
                nRecordPtr += 2;

                record.humidity = KBUtility.signedBytes2Float(byte1: Int8(bitPattern:response[nRecordPtr]), byte2: response[nRecordPtr+1]);
                nRecordPtr += 2;

                readDataRsp.readDataRspList.append(record)
            }
        }

        return readDataRsp
    }
}
