//
//  KBCfgSensorAcc.swift
//  KBeaconPro
//
//  Created by hogen hu on 2023/7/11.
//

import UIKit

public class KBCfgSensorAcc: KBCfgSensorBase {
    public static let JSON_SENSOR_TYPE_ACC_MODEL = "model"
    
    //Acc type
    private var accModel:Int?
    
    public required init() {
        super.init()
        sensorType = KBSensorType.Acc
    }
    
    public override func getSensorType() -> Int {
        return sensorType
    }
    
    public func getAccModel() -> Int? {
        return accModel 
    }
    
    public override func updateConfig(_ para: Dictionary<String, Any>) -> Int {
        var nUpdatePara = super.updateConfig(para)
        if let tempValue = para[KBCfgSensorAcc.JSON_SENSOR_TYPE_ACC_MODEL] as? Int {
            accModel = tempValue
            nUpdatePara += 1
        }
        return nUpdatePara
    }
    
    
    public override func toDictionary() -> Dictionary<String, Any> {
        var cfgDicts = super.toDictionary()

        if let tempValue = accModel {
            cfgDicts[KBCfgSensorAcc.JSON_SENSOR_TYPE_ACC_MODEL]  = tempValue
        }
        return cfgDicts
    }
}
