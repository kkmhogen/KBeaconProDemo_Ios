//
//  KBLightDataMsg.swift
//  KBeaconPro
//
//  Created by mac on 2023/1/7.
//
import Foundation

@objc public class KBLightDataMsg : KBSensorDataMsgBase
{
    @objc public static let KBSensorDataTypeLight = Int(16)

    @objc public static let LIGHT_RECORD_LEN = 8

    @objc public static let LUX_TYPE_MASK = UInt8(2)
    @objc public static let PIR_TYPE_MASK = UInt8(1)

    @objc public override init()
    {
    }

    @objc public override func getSensorDataType()->Int
    {
        return KBLightDataMsg.KBSensorDataTypeLight
    }

    @objc public override func parseSensorDataResponse(_ beacon:KBeacon, dataPtr:Int, response:Data)->Any?
    {
        //sensor data type
        var nReadIndex = dataPtr;
        if (response[nReadIndex] != KBLightDataMsg.KBSensorDataTypeLight)
        {
            NSLog("read light response data type failed")
            return nil
        }
        nReadIndex += 1

        //next read data pos
        let readDataRsp = KBReadSensorRsp();
        readDataRsp.readDataNextPos = ByteConvert.bytesTo4Long(value: response, offset: nReadIndex)
        nReadIndex += 4;

        //check payload length
        let nPayLoad = (response.count - nReadIndex);
        if (nPayLoad % 8 != 0)
        {
            readDataRsp.readDataNextPos = KBSensorDataMsgBase.INVALID_DATA_RECORD_POS;
            NSLog("parse light response data failed")
            return nil
        }

        //read record
        if (nPayLoad >= 8)
        {
            var nRecordPtr = nReadIndex;
            let nTotalRecordLen = nPayLoad / 8
            for _ in 0..<nTotalRecordLen
            {
                let record = KBLightRecord();
                
                //utc time
                record.utcTime = ByteConvert.bytesTo4Long(value: response, offset: nRecordPtr)
                if (record.utcTime < KBSensorDataMsgBase.MIN_UTC_TIME_SECONDS)
                {
                    record.utcTime += self.utcOffset;
                }
                nRecordPtr += 4
                
                //record type
                record.type = response[nRecordPtr]
                nRecordPtr += 1

                //pir indication
                if ((record.type & KBLightDataMsg.PIR_TYPE_MASK) > 0) {
                    record.pirIndication = response[nRecordPtr]
                }else{
                    record.pirIndication = 0;
                }
                nRecordPtr += 1

                //light level
                if ((record.type & KBLightDataMsg.LUX_TYPE_MASK) > 0) {
                    record.lightLevel = (UInt16(response[nRecordPtr]) << 8)
                    record.lightLevel += UInt16(response[nRecordPtr + 1])
                }else{
                    record.lightLevel = 0;
                }
                nRecordPtr += 2
                
                readDataRsp.readDataRspList.append(record)
            }
        }

        return readDataRsp;
    }
}
