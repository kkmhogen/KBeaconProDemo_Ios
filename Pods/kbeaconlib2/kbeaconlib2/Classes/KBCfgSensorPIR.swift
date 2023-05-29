//
//  KBCfgSensorPIR.swift
//  KBeaconPro
//
//  Created by mac on 2023/5/19.
//

import Foundation


@objc public class KBCfgSensorPIR : KBCfgSensorBase{

    @objc public static let JSON_SENSOR_TYPE_PIR_LOG_BACKOFF_TIME = "bkOff"
    
    //measure interval
    @objc public static let DEFAULT_PIR_MEASURE_INTERVAL = 1;
    @objc public static let MAX_MEASURE_INTERVAL = 200;
    @objc public static let MIN_MEASURE_INTERVAL = 1;

    //voc change threshold
    @objc public static let DEFAULT_BACKOFF_TIME_SEC = 30;
    @objc public static let MAX_BACKOFF_TIME_SEC = 3600;
    @objc public static let MIN_BACKOFF_TIME_SEC = 5;

    //log enable
    private var logEnable: Bool?

    //asc enable
    private var ascEnable: Bool?
    
    //measure interval
    private var measureInterval: Int?

    //logger backoff time
    private var logBackoffTime: Int?


    @objc public required init()
    {
        super.init(sensorType:KBSensorType.PIR)
    }

    @objc public func getLogEnable() ->Bool{
        return logEnable ?? false
    }
    
    @objc public func setLogEnable(_ enable:Bool) {
        self.logEnable = enable
    }

    @objc public func getMeasureInterval()->Int
    {
        return measureInterval ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setMeasureInterval(_ interval :Int)->Bool
    {
        if (KBCfgSensorPIR.MIN_MEASURE_INTERVAL >= interval
            && KBCfgSensorPIR.MAX_MEASURE_INTERVAL <= interval)
        {
            measureInterval = interval
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc @discardableResult public func setLogBackoffTime(_ backOff :Int)->Bool
    {
        if (KBCfgSensorPIR.MIN_BACKOFF_TIME_SEC >= backOff
            && KBCfgSensorPIR.MAX_BACKOFF_TIME_SEC <= backOff)
        {
            logBackoffTime = backOff
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc public func getLogBackoffTime()->Int
    {
        return logBackoffTime ?? KBCfgBase.INVALID_INT
    }


    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_TYPE_LOG_ENABLE] as? Int {
            logEnable = (tempValue > 0)
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_TYPE_MEASURE_INTERVAL] as? Int {
            measureInterval = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorPIR.JSON_SENSOR_TYPE_PIR_LOG_BACKOFF_TIME] as? Int {
            logBackoffTime = tempValue
            nUpdatePara += 1
        }


        return nUpdatePara;
    }
    
    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        if let tempValue = logEnable{
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_TYPE_LOG_ENABLE] = (tempValue ? 1 : 0)
        }
        
        if let tempValue = measureInterval{
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_TYPE_MEASURE_INTERVAL] = tempValue
        }

        if let tempValue = logBackoffTime{
            cfgDicts[KBCfgSensorPIR.JSON_SENSOR_TYPE_PIR_LOG_BACKOFF_TIME] = tempValue
        }

        return cfgDicts;
    }
}
