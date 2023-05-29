//
//  KBCfgSensorLight.swift
//  KBeaconPro
//
//  Created by mac on 2023/1/7.
//

import Foundation

@objc public class KBCfgSensorLight: KBCfgSensorBase{
    @objc public static let JSON_SENSOR_TYPE_LUX_LOG_ENABLE = "log";
    @objc public static let JSON_SENSOR_TYPE_LUX_MEASURE_INTERVAL = "msItvl";
    @objc public static let SON_SENSOR_TYPE_LUX_CHANGE_THD = "luxThd";

    //measure interval
    @objc public static let DEFAULT_LUX_MEASURE_INTERVAL = 5
    @objc public static let MAX_MEASURE_INTERVAL = 200
    @objc public static let MIN_MEASURE_INTERVAL = 1

    //light change threshold
    @objc public static let DEFAULT_LIGHT_CHANGE_LOG_THD = 20
    @objc public static let MAX_LIGHT_CHANGE_LOG_THD = 65535
    @objc public static let MIN_LIGHT_CHANGE_LOG_THD = 1
    

    //log enable
    private var logEnable: Bool?

    //measure interval
    private var measureInterval: Int?

    //light change threshold
    private var logChangeThreshold: Int?
    
    @objc public required init()
    {
        super.init(sensorType:KBSensorType.Light)
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

    @objc public func getLogChangeThreshold()->Int
    {
        return logChangeThreshold ?? KBCfgBase.INVALID_INT
    }

    @objc @discardableResult public func setMeasureInterval(_ interval :Int)->Bool
    {
        if (KBCfgSensorLight.MIN_MEASURE_INTERVAL >= interval
            && KBCfgSensorLight.MAX_MEASURE_INTERVAL <= interval)
        {
            measureInterval = interval
            return true
        }
        else
        {
            return false
        }
    }

    @objc public func setLogChangeThreshold(_ threshold:Int)
    {
        logChangeThreshold = threshold;
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgSensorLight.JSON_SENSOR_TYPE_LUX_LOG_ENABLE] as? Int {
            logEnable = (tempValue > 0)
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorLight.JSON_SENSOR_TYPE_LUX_MEASURE_INTERVAL] as? Int {
            measureInterval = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorLight.SON_SENSOR_TYPE_LUX_CHANGE_THD] as? Int {
            logChangeThreshold = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara;
    }
    
    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        if let tempValue = logEnable{
            cfgDicts[KBCfgSensorLight.JSON_SENSOR_TYPE_LUX_LOG_ENABLE] = (tempValue ? 1 : 0)
        }
        
        if let tempValue = measureInterval{
            cfgDicts[KBCfgSensorLight.JSON_SENSOR_TYPE_LUX_MEASURE_INTERVAL] = tempValue
        }

        if let tempValue = logChangeThreshold{
            cfgDicts[KBCfgSensorLight.SON_SENSOR_TYPE_LUX_CHANGE_THD] = tempValue
        }

        return cfgDicts;
    }
}
