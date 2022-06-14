//
//  KBCfgSensor.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation

@objc public class KBCfgSensorBase : KBCfgBase{
    @objc public static let JSON_FIELD_SENSOR_OBJ_LIST = "srObj"
    
    @objc public static let JSON_FIELD_SENSOR_TYPE = "srType"
    
    @objc public static let JSON_SENSOR_DISABLE_PERIOD0 = "dPrd0"
    @objc public static let JSON_SENSOR_DISABLE_PERIOD1 = "dPrd1"
    @objc public static let JSON_SENSOR_DISABLE_PERIOD2 = "dPrd2"
    
    //sensor type
    internal var sensorType: Int
    
    internal var disablePeriod0: UInt32?

    internal var disablePeriod1: UInt32?
    
    internal var disablePeriod2: UInt32?

    @objc public func getSensorType() ->Int {
        return sensorType
    }
    
    @objc public func setSensorType(_ type: Int)
    {
        self.sensorType = type
    }
    
    @objc public override required init()
    {
        sensorType = KBSensorType.SensorDisable
    }
    
    @objc public init(sensorType:Int) {
        self.sensorType = sensorType
        
        super.init()
    }
    
    @objc public func getDisablePeriod0()->KBTimeRange?
    {
        if (disablePeriod0 == nil)
        {
            return nil
        }
        else
        {
            return KBTimeRange(disablePeriod0!)
        }
    }
    
    @objc public func getDisablePeriod1()->KBTimeRange?
    {
        if (disablePeriod1 == nil)
        {
            return nil
        }
        else
        {
            return KBTimeRange(disablePeriod1!)
        }
    }
    
    @objc public func getDisablePeriod2()->KBTimeRange?
    {
        if (disablePeriod2 == nil)
        {
            return nil
        }
        else
        {
            return KBTimeRange(disablePeriod2!)
        }
    }
    
    @objc public func setDisablePeriod0(_ period : KBTimeRange)
    {
        self.disablePeriod0 = period.toUTCInteger()
    }

    @objc public func setDisablePeriod1(_ period : KBTimeRange)
    {
        self.disablePeriod1 = period.toUTCInteger()
    }
    
    @objc public func setDisablePeriod2(_ period : KBTimeRange)
    {
        self.disablePeriod2 = period.toUTCInteger()
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgSensorBase.JSON_FIELD_SENSOR_TYPE] as? Int {
            sensorType = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_DISABLE_PERIOD0] as? UInt32 {
            disablePeriod0 = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_DISABLE_PERIOD1] as? UInt32 {
            disablePeriod1 = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_DISABLE_PERIOD2] as? UInt32 {
            disablePeriod2 = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara;
    }
    
    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        //sensor type
        cfgDicts[KBCfgSensorBase.JSON_FIELD_SENSOR_TYPE] = sensorType
        
        if let tempPeriod = disablePeriod0
        {
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_DISABLE_PERIOD0] = tempPeriod
        }
        
        if let tempPeriod = disablePeriod1
        {
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_DISABLE_PERIOD1] = tempPeriod
        }
        
        if let tempPeriod = disablePeriod2
        {
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_DISABLE_PERIOD2] = tempPeriod
        }
                
        return cfgDicts;
    }
}
