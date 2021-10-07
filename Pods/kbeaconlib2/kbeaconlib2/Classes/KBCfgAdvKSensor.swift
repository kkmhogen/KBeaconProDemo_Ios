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

    var htSensorInclude: Bool?
    var axisSensorInclude: Bool?

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

        return cfgDicts;
    }
}
