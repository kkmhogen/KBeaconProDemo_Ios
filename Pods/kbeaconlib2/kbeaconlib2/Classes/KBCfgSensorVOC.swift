//
//  KBCfgSensorVOC.swift
//  KBeaconPro
//
//  Created by mac on 2023/5/19.
//

import Foundation

@objc public class KBCfgSensorVOC : KBCfgSensorBase{

    @objc public static let JSON_SENSOR_TYPE_VOC_CHANGE_THD = "vocThd"
    @objc public static let JSON_SENSOR_TYPE_NOX_CHANGE_THD = "noxThd"

    //measure interval
    @objc public static let  DEFAULT_MEASURE_INTERVAL = 10;
    @objc public static let MAX_MEASURE_INTERVAL = 200;
    @objc public static let MIN_MEASURE_INTERVAL = 3;

    //voc change threshold
    @objc public static let DEFAULT_VOC_CHANGE_LOG_THD = 20;
    @objc public static let MAX_VOC_CHANGE_LOG_THD = 250;
    @objc public static let MIN_VOC_CHANGE_LOG_THD = 1;

    //voc change threshold
    @objc public static let DEFAULT_NOX_CHANGE_LOG_THD = 1;
    @objc public static let MAX_NOX_CHANGE_LOG_THD = 250;
    @objc public static let MIN_NOX_CHANGE_LOG_THD = 1;


    //log enable
    private var logEnable: Bool?
    
    //log interval
//    private var logInterval: Int?

    //asc enable
    private var ascEnable: Bool?
    
    //measure interval
    private var measureInterval: Int?

    //voc change threshold
    private var logVocChangeThreshold: Int?
    
    //nox change threshold
    private var logNoxChangeThreshold: Int?

    @objc public required init()
    {
        super.init(sensorType:KBSensorType.VOC)
    }

    @objc public func getLogEnable() ->Bool{
        return logEnable ?? false
    }
    
    @objc public func setLogEnable(_ enable:Bool) {
        self.logEnable = enable
    }
    
    @objc @discardableResult public func setMeasureInterval(_ interval :Int)->Bool
    {
        if (KBCfgSensorVOC.MAX_MEASURE_INTERVAL >= interval
            && KBCfgSensorVOC.MIN_MEASURE_INTERVAL <= interval)
        {
            measureInterval = interval
            return true
        }
        else
        {
            return false
        }
    }

    @objc public func getMeasureInterval()->Int
    {
        return measureInterval ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setVocLogChangeThreshold(_ threshold :Int)->Bool
    {
        if (KBCfgSensorVOC.MAX_VOC_CHANGE_LOG_THD >= threshold
            && KBCfgSensorVOC.MIN_VOC_CHANGE_LOG_THD <= threshold)
        {
            logVocChangeThreshold = threshold
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc public func getVocLogChangeThreshold()->Int
    {
        return logVocChangeThreshold ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setLogNoxChangeThreshold(_ threshold :Int)->Bool
    {
        if (KBCfgSensorVOC.MAX_NOX_CHANGE_LOG_THD >= threshold
            && KBCfgSensorVOC.MIN_NOX_CHANGE_LOG_THD <= threshold)
        {
            logNoxChangeThreshold = threshold
            return true
        }
        else
        {
            return false
        }
    }

    @objc public func getLogNoxChangeThreshold()->Int
    {
        return logNoxChangeThreshold ?? KBCfgBase.INVALID_INT
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

        if let tempValue = para[KBCfgSensorVOC.JSON_SENSOR_TYPE_VOC_CHANGE_THD] as? Int {
            logVocChangeThreshold = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgSensorVOC.JSON_SENSOR_TYPE_NOX_CHANGE_THD] as? Int {
            logNoxChangeThreshold = tempValue
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

        if let tempValue = logInterval{
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_TYPE_LOG_INTERVAL] = tempValue
        }

        if let tempValue = logVocChangeThreshold{
            cfgDicts[KBCfgSensorVOC.JSON_SENSOR_TYPE_VOC_CHANGE_THD] = tempValue
        }

        if let tempValue = logNoxChangeThreshold{
            cfgDicts[KBCfgSensorVOC.JSON_SENSOR_TYPE_NOX_CHANGE_THD] = tempValue
        }

        return cfgDicts;
    }
}
