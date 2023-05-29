//
//  KBCfgSensorHT.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation

@objc public class KBCfgSensorHT : KBCfgSensorBase{
    @objc public static  let JSON_SENSOR_TYPE_HT_TEMP_CHANGE_THD = "tsThd"
    @objc public static  let JSON_SENSOR_TYPE_HT_HUMIDITY_CHANGE_THD = "hsThd"

    //measure interval
    @objc public static let DEFAULT_HT_MEASURE_INTERVAL = 3
    @objc public static let MAX_MEASURE_INTERVAL = 200
    @objc public static let MIN_MEASURE_INTERVAL = 1

    //temperature change threshold
    @objc public static let DEFAULT_HT_TEMP_CHANGE_THD = 5   //0.1 Celsius
    @objc public static let MAX_HT_TEMP_CHANGE_LOG_THD = 200  //max value is 20 Celsius
    @objc public static let MIN_HT_TEMP_CHANGE_LOG_THD = 0

    //humidity change threshold
    @objc public static let DEFAULT_HT_HUMIDITY_CHANGE_THD = 30  //unit is 0.1%
    @objc public static let MAX_HT_HUMIDITY_CHANGE_LOG_THD = 200  //max value is 20%
    @objc public static let MIN_HT_HUMIDITY_CHANGE_LOG_THD = 0

    //log enable
    private var logEnable: Bool?

    //measure interval
    private var measureInterval: Int?

    //temperature interval
    private var temperatureChangeThreshold: Int?

    //humidity interval
    private var humidityChangeThreshold:Int?

    @objc public required init()
    {
        super.init(sensorType:KBSensorType.HTHumidity)
    }

    @objc public func getLogEnable() ->Bool{
        return logEnable ?? false
    }

    @objc public func setLogEnable(_ enable:Bool) {
        self.logEnable = enable
    }


    @objc public func getSensorHtMeasureInterval()->Int
    {
        return measureInterval ?? KBCfgBase.INVALID_INT
    }

    @objc public  func getTemperatureChangeThreshold()->Int
    {
        return temperatureChangeThreshold ?? KBCfgBase.INVALID_INT
    }

    @objc public func getHumidityChangeThreshold()->Int
    {
        return humidityChangeThreshold ?? KBCfgBase.INVALID_INT
    }

    @objc @discardableResult public func setSensorMeasureInterval(_ interval :Int)->Bool
    {
        if (KBCfgSensorHT.MIN_MEASURE_INTERVAL >= interval
            && KBCfgSensorHT.MAX_MEASURE_INTERVAL <= interval)
        {
            measureInterval = interval
            return true
        }
        else
        {
            return false
        }
    }

    @objc @discardableResult public func setTemperatureChangeThreshold(_ threshold:Int)->Bool
    {
        if (KBCfgSensorHT.MIN_HT_TEMP_CHANGE_LOG_THD >= threshold
            && KBCfgSensorHT.MAX_HT_TEMP_CHANGE_LOG_THD <= threshold)
        {
            temperatureChangeThreshold = threshold
            return true
        }
        else
        {
            return false
        }
    }

    @objc @discardableResult public func setHumidityChangeThreshold(_ threshold:Int)->Bool
    {
        if (KBCfgSensorHT.MIN_HT_HUMIDITY_CHANGE_LOG_THD >= threshold
            && KBCfgSensorHT.MAX_HT_HUMIDITY_CHANGE_LOG_THD <= threshold)
        {
            humidityChangeThreshold = threshold
            return true
        }
        else
        {
            return false
        }
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

        if let tempValue = para[KBCfgSensorHT.JSON_SENSOR_TYPE_HT_TEMP_CHANGE_THD] as? Int {
            temperatureChangeThreshold = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorHT.JSON_SENSOR_TYPE_HT_HUMIDITY_CHANGE_THD] as? Int {
            humidityChangeThreshold = tempValue
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

        if let tempValue = temperatureChangeThreshold{
            cfgDicts[KBCfgSensorHT.JSON_SENSOR_TYPE_HT_TEMP_CHANGE_THD] = tempValue
        }

        if let tempValue = humidityChangeThreshold{
            cfgDicts[KBCfgSensorHT.JSON_SENSOR_TYPE_HT_HUMIDITY_CHANGE_THD] = tempValue
        }

        return cfgDicts;
    }

}
