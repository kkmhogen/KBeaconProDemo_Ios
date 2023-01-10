//
//  KBCfgAdvKSensor.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgAdvKSensor : KBCfgAdvBase{
    @objc public static let JSON_FIELD_SENSOR_HUMIDITY = "ht"
    @objc public static let JSON_FIELD_SENSOR_AXIS = "axis"
    @objc public static let JSON_FIELD_SENSOR_LUX = "lux"
    @objc public static let JSON_FIELD_SENSOR_PIR = "pir"
    
    var htSensorInclude: Bool?
    var axisSensorInclude: Bool?
    var lightSensorInclude: Bool?
    var pirSensorInclude: Bool?

    @objc public required init()
    {
        super.init(advType: KBAdvType.Sensor)
    }

    @objc public func setAxisSensorInclude(_ axisInclude: Bool ) {
        self.axisSensorInclude = axisInclude
    }

    @objc public func isAxisSensorEnable() ->Bool
    {
        return axisSensorInclude ?? false
    }

    @objc public func setHtSensorInclude(_ htSensorInclude : Bool) {
        self.htSensorInclude = htSensorInclude
    }

    @objc public func isHtSensorInclude()->Bool {
        return htSensorInclude ?? false
    }
    
    @objc public func setLightSensorInclude(_ sensorInclude : Bool) {
        self.lightSensorInclude = sensorInclude
    }
    
    @objc public func isLightSensorInclude()->Bool {
        return lightSensorInclude ?? false
    }

    @objc public func setPirSensorInclude(_ sensorInclude : Bool) {
        self.pirSensorInclude = sensorInclude
    }
    
    
    @objc public func isPirSensorInclude()->Bool {
        return pirSensorInclude ?? false
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgAdvKSensor.JSON_FIELD_SENSOR_HUMIDITY] as? Int {
            htSensorInclude = (tempValue > 0)
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgAdvKSensor.JSON_FIELD_SENSOR_AXIS] as? Int {
            axisSensorInclude = (tempValue > 0)
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgAdvKSensor.JSON_FIELD_SENSOR_LUX] as? Int {
            lightSensorInclude = (tempValue > 0)
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgAdvKSensor.JSON_FIELD_SENSOR_PIR] as? Int {
            pirSensorInclude = (tempValue > 0)
            nUpdatePara += 1
        }

        return nUpdatePara;
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()

        if let tempValue = htSensorInclude{
            cfgDicts[KBCfgAdvKSensor.JSON_FIELD_SENSOR_HUMIDITY] = (tempValue ? 1 : 0)
        }

        if let tempValue = axisSensorInclude{
            cfgDicts[KBCfgAdvKSensor.JSON_FIELD_SENSOR_AXIS] = (tempValue ? 1 : 0)
        }
        
        if let tempValue = lightSensorInclude{
            cfgDicts[KBCfgAdvKSensor.JSON_FIELD_SENSOR_LUX] = (tempValue ? 1 : 0)
        }
        
        if let tempValue = pirSensorInclude{
            cfgDicts[KBCfgAdvKSensor.JSON_FIELD_SENSOR_PIR] = (tempValue ? 1 : 0)
        }

        return cfgDicts;
    }
}
