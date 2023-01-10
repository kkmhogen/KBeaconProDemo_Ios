//
//  KBPIRDataMsg.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/6/5.
//

import Foundation

@objc public class KBPIRDataMsg : KBSensorDataMsgBase
{
    @objc public static let KBSensorDataTypePIR = Int(8)
    @objc public static let PIR_RECORD_LEN = 5
    
    @objc public override init()
    {
    }

    @objc public override func getSensorDataType()->Int
    {
        return KBPIRDataMsg.KBSensorDataTypePIR
    }

    @objc public override func parseSensorDataResponse(_ beacon:KBeacon, dataPtr:Int, response:Data)->Any?
    {
        //sensor data type
        var nReadIndex = dataPtr;
        if (response[nReadIndex] != KBPIRDataMsg.KBSensorDataTypePIR)
        {
            NSLog("read pir response data type failed")
            return nil
        }
        nReadIndex += 1

        //next read data pos
        let readDataRsp = KBReadSensorRsp();
        readDataRsp.readDataNextPos = ByteConvert.bytesTo4Long(value: response, offset: nReadIndex)
        nReadIndex += 4;

        //check payload length
        let nPayLoad = (response.count - nReadIndex);
        if (nPayLoad % KBPIRDataMsg.PIR_RECORD_LEN != 0)
        {
            readDataRsp.readDataNextPos = KBSensorDataMsgBase.INVALID_DATA_RECORD_POS;
            NSLog("parse HT response data failed")
            return nil
        }

        //read record
        if (nPayLoad >= KBPIRDataMsg.PIR_RECORD_LEN)
        {
            var nRecordPtr = nReadIndex;
            let nTotalRecordLen = nPayLoad / KBPIRDataMsg.PIR_RECORD_LEN
            for _ in 0..<nTotalRecordLen
            {
                let record = KBPIRRecord();
                
                //utc time
                record.utcTime = ByteConvert.bytesTo4Long(value: response, offset: nRecordPtr)
                if (record.utcTime < KBSensorDataMsgBase.MIN_UTC_TIME_SECONDS)
                {
                    record.utcTime += self.utcOffset;
                }
                nRecordPtr += 4;

                record.pirIndication = response[nRecordPtr];
                nRecordPtr += 1;

                readDataRsp.readDataRspList.append(record)
            }
        }

        return readDataRsp
    }
}
