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

    //sensor type
    internal var sensorType: Int?

    @objc public func getSensorType() ->Int {
        return sensorType ?? KBSensorType.SensorDisable
    }
    
    @objc public override required init()
    {
        
    }
    
    @objc  public init(sensorType:Int) {
        self.sensorType = sensorType
        
        super.init()
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgSensorBase.JSON_FIELD_SENSOR_TYPE] as? Int {
            sensorType = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara;
    }
    
    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        //sensor type
        if let tempValue = sensorType{
            cfgDicts[KBCfgSensorBase.JSON_FIELD_SENSOR_TYPE] = tempValue
        }
                
        return cfgDicts;
    }
}
