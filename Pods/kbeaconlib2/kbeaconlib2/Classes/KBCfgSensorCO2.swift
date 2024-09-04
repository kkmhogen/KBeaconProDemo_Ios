//
//  KBCfgSensorCO2.swift
//  KBeaconPro
//
//  Created by mac on 2023/5/19.
//

import Foundation


@objc public class KBCfgSensorCO2 : KBCfgSensorBase{

    @objc public static let JSON_SENSOR_TYPE_CO2_CHANGE_THD = "co2Thd"
    @objc public static let JSON_SENSOR_TYPE_CO2_ASC_ENABLE = "asc"

    //measure interval
    @objc public static let DEFAULT_MEASURE_INTERVAL = 300
    @objc public static let MAX_MEASURE_INTERVAL = 3600
    @objc public static let MIN_MEASURE_INTERVAL = 10

    //co2 change thd
    @objc public static let DEFAULT_CO2_CHANGE_LOG_THD = 20
    @objc public static let MAX_CO2_CHANGE_LOG_THD = 256
    @objc public static let MIN_CO2_CHANGE_LOG_THD = 0;

    //log enable
    private var logEnable: Bool?
    

    //asc enable
    private var ascEnable: Bool?
    
    //measure interval
    private var measureInterval: Int?

    //co2 save threshold
    private var logCO2SaveThd: Int?

    @objc public required init()
    {
        super.init(sensorType:KBSensorType.CO2)
    }

    @objc public func getLogEnable() ->Bool{
        return logEnable ?? false
    }
    
    @objc public func setLogEnable(_ enable:Bool) {
        self.logEnable = enable
    }
    
    @objc public func getAscEnable() ->Bool{
        return ascEnable ?? false
    }

    @objc public func setAscEnable(_ enable:Bool) {
        self.ascEnable = enable
    }

    @objc public func getMeasureInterval()->Int
    {
        return measureInterval ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setMeasureInterval(_ interval :Int)->Bool
    {
        if (interval >= KBCfgSensorCO2.MIN_MEASURE_INTERVAL
            && interval <= KBCfgSensorCO2.MAX_MEASURE_INTERVAL)
        {
            measureInterval = interval
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc @discardableResult public func setCO2SaveThreshold(_ threshold :Int)->Bool
    {
        if (threshold <= KBCfgSensorCO2.MAX_CO2_CHANGE_LOG_THD
            && threshold >= KBCfgSensorCO2.MIN_CO2_CHANGE_LOG_THD)
        {
            logCO2SaveThd = threshold
            return true
        }
        else
        {
            return false
        }
    }

    @objc public func getCO2SaveThreshold()->Int
    {
        return logCO2SaveThd ?? KBCfgBase.INVALID_INT
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_TYPE_LOG_ENABLE] as? Int {
            logEnable = (tempValue > 0)
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_TYPE_LOG_INTERVAL] as? Int {
            logInterval = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_TYPE_MEASURE_INTERVAL] as? Int {
            measureInterval = tempValue
            nUpdatePara += 1
        }
        
      

        if let tempValue = para[KBCfgSensorCO2.JSON_SENSOR_TYPE_CO2_CHANGE_THD] as? Int {
            logCO2SaveThd = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorCO2.JSON_SENSOR_TYPE_CO2_ASC_ENABLE] as? Int {
            ascEnable = (tempValue > 0)
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
        
        if let tempValue = logInterval{
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_TYPE_LOG_INTERVAL] = tempValue
        }
        
        if let tempValue = measureInterval{
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_TYPE_MEASURE_INTERVAL] = tempValue
        }

        if let tempValue = ascEnable{
            cfgDicts[KBCfgSensorCO2.JSON_SENSOR_TYPE_CO2_ASC_ENABLE] = (tempValue ? 1 : 0)
        }

        if let tempValue = logCO2SaveThd{
            cfgDicts[KBCfgSensorCO2.JSON_SENSOR_TYPE_CO2_CHANGE_THD] = tempValue
        }
        
       
        
        return cfgDicts;
    }

}
