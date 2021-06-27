//
//  KBSensorDataMsgBase.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/26.
//

import Foundation

public typealias onSensorDataCommandCallback = (_ result:Bool, _ obj:Any?, _ error:KBException?)->Void

@objc public enum KBSensorReadOption : Int
{
    case NormalOrder = 0
    case ReverseOrder = 1
    case NewRecord = 2
}

@objc public class KBSensorDataMsgBase : NSObject
{
    //read sensor summary
    private static let MSG_READ_SENSOR_INFO_REQ = 1
    private static let MSG_READ_SENSOR_INFO_RSP = 1

    //read sensor data record
    private static let MSG_READ_SENSOR_DATA_REQ = 2
    private static let MSG_READ_SENSOR_DATA_RSP = 2
    
    //clear all sensor data
    private static let MSG_CLR_SENSOR_DATA_REQ = 3

    @objc public static let INVALID_DATA_RECORD_POS = UInt32(4294967295)

    internal var mReadSensorCallback : onSensorDataCommandCallback?
    
    @objc public override init()
    {
    }

    @objc public func getSensorDataType()->Int
    {
        return KBSensorType.SensorDisable
    }

    @objc public func makeReadSensorDataReq(_ readNo: UInt32, option:KBSensorReadOption, max:Int)->[UInt8]
    {
        var byMsgReq:[UInt8] = []

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
        
        return byMsgReq
    }

    @objc public func parseSensorDataResponse(_ beacon:KBeacon, dataPtr:Int, response:Data)->Any?
    {
        return nil
    }

    @objc public func parseSensorInfoResponse(_ beacon:KBeacon, dataPtr:Int, response:Data)->Any?
    {
        return nil
    }

    @objc public func readSensorDataInfo(_ beacon:KBeacon, callback: @escaping onSensorDataCommandCallback)->Void
    {
        var reqInfoMsg = Data()

        reqInfoMsg.append(UInt8(KBSensorDataMsgBase.MSG_READ_SENSOR_INFO_REQ))
        let sensorType = UInt8(getSensorDataType())
        reqInfoMsg.append(sensorType)
        mReadSensorCallback = callback

        //send message
        beacon.sendSensorMessage(reqInfoMsg, callback: { (succ, rspData, except) in
            var responseData:Any? = nil
            var error:KBException? = nil
            var ret = false
            if (succ)
            {
                if let reqInfRsp = rspData,
                   reqInfRsp.count > 2 &&
                    reqInfRsp[0] == KBSensorDataMsgBase.MSG_READ_SENSOR_INFO_RSP &&
                    reqInfRsp[1] == UInt8(self.getSensorDataType())
                {
                    responseData = self.parseSensorInfoResponse(beacon, dataPtr: 2, response: reqInfRsp)
                }
                if (responseData == nil){
                    error = KBException(KBErrorCode.ParseSensorInfoResponseFailed, desc: "Parse sensor info response failed")
                }else{
                    ret = true
                }
            }else{
                error = except
                ret = false
            }
            
            if let tempCallback = self.mReadSensorCallback
            {
                self.mReadSensorCallback = nil
                tempCallback(ret, responseData, error)
            }
        });
    }

    @objc public func readSensorRecord(_ beacon:KBeacon,
                                   number:UInt32,
                                   option:KBSensorReadOption,
                                   max:Int,
                                   callback: onSensorDataCommandCallback?)->Void
    {
        let reqDataMsgBody = makeReadSensorDataReq(number, option: option, max: max)
        
        var reqDataMsg = Data()
        reqDataMsg.append(UInt8(KBSensorDataMsgBase.MSG_READ_SENSOR_DATA_REQ))
        reqDataMsg.append(UInt8(getSensorDataType()))
        reqDataMsg.append(contentsOf: reqDataMsgBody)

        //send message
        mReadSensorCallback = callback;
        beacon.sendSensorMessage(reqDataMsg, callback: { (succ, responsePara, except) in
            var responseData:Any? = nil
            var error:KBException? = nil
            var ret = false

            if (succ)
            {
                //tag
                if let data = responsePara,
                   data.count > 2 && data[0] == KBSensorDataMsgBase.MSG_READ_SENSOR_DATA_RSP
                {
                    var nReadIndex = 1
                    let dataLen = ByteConvert.bytesToShort(value: data, offset: nReadIndex)
                    nReadIndex += 2
                    
                    //parse data
                    if (dataLen == data.count - 3){
                        responseData = self.parseSensorDataResponse(beacon, dataPtr: nReadIndex, response: data)
                    }
                }
                
                if (responseData == nil){
                    error = KBException(KBErrorCode.ParseSensorDataResponseFailed, desc: "Parse device's response data failed")
                }else{
                    ret = true
                }
            }else{
                error = except
                ret = false
            }
            
            if let tempCallback = self.mReadSensorCallback
            {
                self.mReadSensorCallback = nil
                tempCallback(ret, responseData, error)
            }
            
        });
    }

    @objc public func clearSensorRecord(_ beacon:KBeacon, callback: onSensorDataCommandCallback?)
    {
        var bySensorInfoReq = Data()
        bySensorInfoReq.append(UInt8(KBSensorDataMsgBase.MSG_CLR_SENSOR_DATA_REQ))
        bySensorInfoReq.append(UInt8(getSensorDataType()))

        mReadSensorCallback = callback;
        
        beacon.sendSensorMessage(bySensorInfoReq, callback: { (cause, responsePara, except) in
            if let tempCallback = self.mReadSensorCallback{
                self.mReadSensorCallback = nil
                tempCallback(cause, nil, except)
            }
        });
    }
}
