//
//  KBCfgSensorGeomagnetic.swift
//  KBeaconPro
//
//  Created by hogen hu on 2024/7/10.
//

import UIKit

public class KBCfgSensorGEO: KBCfgSensorBase {

    @objc public static let MAX_PARKING_CHANGE_THD = 65535;
    @objc public static let MIN_PARKING_CHANGE_THD = 256;
    @objc public static let DEFAULT_PARKING_CHANGE_THD = 1000;
    
    @objc public static let MAX_MEASURE_INTERVAL = 100
    @objc public static let MIN_MEASURE_INTERVAL = 1
    
    @objc public static let MAX_PARKING_DELAY_THD = 100;
    @objc public static let MIN_PARKING_DELAY_THD = 1;
    @objc public static let DEFAULT_PARKING_DELAY_THD = 9;
    
    @objc public static let JSON_SENSOR_TYPE_GEO_PTHD = "pThd"

    @objc public static let JSON_SENSOR_TYPE_GEO_PDLY = "pDly"
    
    @objc public static let JSON_SENSOR_TYPE_GEO_TAG = "tag"
    
    @objc public static let JSON_SENSOR_TYPE_GEO_FCL = "fcl"

    //measure interval
    private var measureInterval: Int?
    
    //parking GEO sensor change threshold
    private var parkingThreshold: Int?
    
    //parking delay
    private var parkingDelay: Int?
    
    //idle parking tag
    private var parkingTag: Int?
    
    //force GEO sensor calibration
    private var calibration: Int?
    
    @objc public required init()
    {
        super.init(sensorType:KBSensorType.GEO)
    }
    
    @objc @discardableResult public func setMeasureInterval(_ interval :Int)->Bool
    {
        if (KBCfgSensorGEO.MAX_MEASURE_INTERVAL >= interval
            && KBCfgSensorGEO.MIN_MEASURE_INTERVAL <= interval)
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
    
    @objc public func getParkingThreshold() -> Int {
        if let value = parkingThreshold {
            return value
        }
        return KBCfgSensorGEO.DEFAULT_PARKING_CHANGE_THD
    }
    
    @objc @discardableResult public func setParkingThreshold(_ parkThd:Int) ->Bool{
        if (parkThd <= KBCfgSensorGEO.MAX_PARKING_CHANGE_THD
            && parkThd >= KBCfgSensorGEO.MIN_PARKING_CHANGE_THD)
        {
            parkingThreshold = parkThd
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc public func getPakingDelay() -> Int {
        if let value = parkingDelay {
            return value
        }
        return KBCfgSensorGEO.DEFAULT_PARKING_DELAY_THD
    }
    
    @objc @discardableResult public func setParkingDelay(_ parkDly:Int) ->Bool{
        if (parkDly <= KBCfgSensorGEO.MAX_PARKING_DELAY_THD
            && parkDly >= KBCfgSensorGEO.MIN_PARKING_DELAY_THD)
        {
            parkingDelay = parkDly
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc public func isParkingTaged() -> Bool {
        return parkingTag == 1
    }
    
    @objc public func setParkingTag(_ tag: Bool)
    {
        parkingTag = tag ? 1 : 0;
    }
    
    @objc public func isCalibrated() -> Bool {
        return calibration == 1
    }
    
    @objc public func setCalibration(_ forceCalibration: Bool)
    {
        calibration = forceCalibration ? 1 : 0;
    }

    @objc public override func updateConfig(_ para: Dictionary<String, Any>) -> Int {
        var nUpdatePara = super.updateConfig(para)
        if let tempValue = para[KBCfgSensorBase.JSON_SENSOR_TYPE_MEASURE_INTERVAL] as? Int {
            measureInterval = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_PTHD] as? Int {
            parkingThreshold = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_PDLY] as? Int {
            parkingDelay = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_TAG] as? Int {
            parkingTag = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_FCL] as? Int {
            calibration = tempValue
            nUpdatePara += 1
        }
        return nUpdatePara
    }
    
    @objc public override func toDictionary() -> Dictionary<String, Any> {
        var cfgDicts = super.toDictionary()

        if let tempValue = measureInterval {
            cfgDicts[KBCfgSensorBase.JSON_SENSOR_TYPE_MEASURE_INTERVAL]  = tempValue
        }
        if let tempValue =  parkingThreshold {
            cfgDicts[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_PTHD] = tempValue
        }
        if let tempValue =  parkingDelay {
            cfgDicts[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_PDLY] = tempValue
        }
        if let tempValue =  parkingTag {
            cfgDicts[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_TAG] = tempValue
        }
        if let tempValue = calibration {
            cfgDicts[KBCfgSensorGEO.JSON_SENSOR_TYPE_GEO_FCL]  = tempValue
        }
        return cfgDicts
    }
}
