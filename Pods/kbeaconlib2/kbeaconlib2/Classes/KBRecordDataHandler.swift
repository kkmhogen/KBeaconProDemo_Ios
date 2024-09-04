//
//  KBSensorDataMsgBase.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/26.
//

import Foundation


@objc public enum KBSensorReadOption : Int
{
    case NormalOrder = 0
    case ReverseOrder = 1
    case NewRecord = 2
}

//hex message type
public class KBSensorMsgType : NSObject
{
    @objc static public var  MsgReadSensorInfo = 1
    
    @objc static public var  MsgReadSensorRecord = 2
    
    @objc static public var  MsgClearSensorRecord = 3
}


public class KBRecordDataHandler : NSObject
{
    public var utcOffset:UInt32
    
    public static let MIN_UTC_TIME_SECONDS = 946080000
        
    //object creation factory
    static var kbSensorParserObjects: Dictionary<Int, KBRecordBase.Type> = [
        KBSensorType.VOC: KBRecordVOC.self,
        KBSensorType.CO2: KBRecordCO2.self,
        KBSensorType.Alarm: KBRecordAlarm.self,
        KBSensorType.PIR: KBRecordPIR.self,
        KBSensorType.HTHumidity : KBRecordHumidity.self,
        KBSensorType.Light : KBRecordLight.self
    ]
    
    public override init()
    {
        utcOffset = 0
        super.init()
    }
    
    
    public func makeReadSensorRecordRequest(_ sensorType:Int, readNo: UInt32, option:KBSensorReadOption, max:Int)->Data
    {
        var byMsgReq = Data()

        byMsgReq.append(UInt8(KBSensorMsgType.MsgReadSensorRecord))
        byMsgReq.append(UInt8(sensorType))

        //read pos
        byMsgReq.append(UInt8((readNo >> 24) & 0xFF))
        byMsgReq.append(UInt8((readNo >> 16) & 0xFF))
        byMsgReq.append(UInt8((readNo >> 8) & 0xFF))
        byMsgReq.append(UInt8(readNo & 0xFF))

        //read num
        byMsgReq.append(UInt8((max >> 8) & 0xFF))
        byMsgReq.append(UInt8(max & 0xFF))

        //read direction
        byMsgReq.append(UInt8(option.rawValue))
        
        //high speed (connection interval to 30 ms, unit is 1.25ms)
        byMsgReq.append(UInt8(24))
        
        return byMsgReq
    }
    

    public func parseSensorInfoResponse(rspdata:Data?)->(succ:Bool, KBRecordInfoRsp?, KBException?)
    {
        guard let response = rspdata,
              response.count >= 14,
              response[0] == KBSensorMsgType.MsgReadSensorInfo else {
            return (false, nil, KBException(KBErrorCode.CfgInputInvalid, desc: "sensor response data is null"))
        }

        var nReadDataPos = 1  //skip message type
        let infoRsp = KBRecordInfoRsp()
        
        infoRsp.sensorType = Int(response[nReadDataPos])
        nReadDataPos += 1

        //total record number
        infoRsp.totalRecordNumber = UInt32(ByteConvert.bytesTo4Long(value: response, offset: nReadDataPos))
        nReadDataPos += 4

        //new record number
        infoRsp.unreadRecordNumber = UInt32(ByteConvert.bytesTo4Long(value: response, offset: nReadDataPos))
        nReadDataPos += 4

        //utc offset
        infoRsp.readInfoUtcSeconds = ByteConvert.bytesTo4Long(value:response, offset: nReadDataPos)
        utcOffset = UTCTime.getUTCTimeSecond() - infoRsp.readInfoUtcSeconds
        nReadDataPos += 4;
        
        return (true, infoRsp, nil)
    }

    public func parseSensorRecordResponse(rspdata:Data?)->(succ:Bool, KBRecordDataRsp?, KBException?)
    {
        guard let response = rspdata,
              response.count >= 8,
              response[0] == KBSensorMsgType.MsgReadSensorRecord else {
            return (false, nil, KBException(KBErrorCode.CfgInputInvalid, desc: "device response message head length invalid"))
        }
        
        var nReadIndex = 1;  //skip message type
        
        //check msg length
        let msgLength = (UInt16(response[nReadIndex]) << 8) + UInt16(response[nReadIndex+1])
        nReadIndex += 2
        if (msgLength != response.count - 3)
        {
            return (false, nil, KBException(KBErrorCode.CfgReadNull, desc:"device response message head length invalid"))
        }
        
        //sensor type
        let sensorType = Int(response[nReadIndex])
        nReadIndex += 1
        
        //create sensor type
        guard let newSensorRecord = KBRecordDataHandler.createSensorObject(sensorType) else{
            NSLog("create sensor record failed");
            return (false, nil, KBException(KBErrorCode.CfgReadNull, desc:"app does not support this sensor"))
        }
        
        //next read data pos
        let readDataRsp = KBRecordDataRsp();
        readDataRsp.readDataNextPos = ByteConvert.bytesTo4Long(value: response, offset: nReadIndex)
        nReadIndex += 4;

        //check payload length
        let nPayLoad = (response.count - nReadIndex);
        if (nPayLoad % Int(newSensorRecord.getRecordLen()) != 0)
        {
            readDataRsp.readDataNextPos = KBRecordDataRsp.INVALID_DATA_RECORD_POS;
            NSLog("detected response message length failed")
            return (false, nil, KBException(KBErrorCode.CfgFailed, desc:"device response record length invalid"))
        }

        //read record
        if (nPayLoad >= newSensorRecord.getRecordLen())
        {
            let nTotalRecordLen = nPayLoad / Int(newSensorRecord.getRecordLen())
            for _ in 0..<nTotalRecordLen
            {
                
                let sensorRecord = KBRecordDataHandler.createSensorObject(sensorType)!
                if (!sensorRecord.parseRecord(utcOffset: utcOffset, response: response, dataPtr: nReadIndex))
                {
                    return (false, nil, KBException(KBErrorCode.CfgFailed, desc:"parse device response record failed"))
                }
                
                nReadIndex = nReadIndex + Int(newSensorRecord.getRecordLen())

                readDataRsp.readDataRspList.append(sensorRecord)
            }
        }

        return (true, readDataRsp, nil)
    }
    
    internal static func createSensorObject(_ sensorType:Int)->KBRecordBase?
    {
        if let inistanceObj = kbSensorParserObjects[sensorType]
        {
            let sensorCfg = inistanceObj.init()
            return sensorCfg
        }

        return nil
    }
}
