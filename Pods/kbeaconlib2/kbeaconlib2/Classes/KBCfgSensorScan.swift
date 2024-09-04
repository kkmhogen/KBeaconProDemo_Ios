//
//  KBCfgSensorScan.swift
//  KBeaconPro
//
//  Created by hogen hu on 2024/8/9.
//

import Foundation

@objc public class KBCfgSensorScan:  KBCfgSensorBase {
    
    public static let MIN_FILTER_RSSI = -100;
    public static let MAX_FILTER_RSSI = 10;

    public static let MIN_SCAN_PERIPHERIAL_COUNT = 1;
    public static let MAX_SCAN_PERIPHERIAL_COUNT = 20;
    
    public static let MIN_SCAN_DURATION = 1;
    public static let MAX_SCAN_DURATION = 60000;
    
    @objc public static let JSON_SENSOR_TYPE_SCAN_MODE = "mode"
    @objc public static let JSON_SENSOR_TYPE_SCAN_RSSI = "rssi"
    @objc public static let JSON_SENSOR_TYPE_SCAN_DUR = "dur"
    @objc public static let JSON_SENSOR_TYPE_SCAN_MSK = "chMsk"
    @objc public static let JSON_SENSOR_TYPE_SCAN_MAX = "max"
    
    // type, BLE4.0, BLE5.0 PHY Coded, BLE5.0 Ext Adv
    private var scanMode:Int?
    
    //scan min rssi
    private var scanRssi:Int?
    
    //scan duration, unit is 10ms
    private var scanDuration:Int?
    
    //scan channel mask
    private var scanChMsk:UInt8?
    
    //The maximum number of devices scanned
    private var scanMax:Int?
    
    @objc public required init() {
        super.init()
        sensorType = KBSensorType.SCAN
    }
    
    @objc public override func getSensorType() -> Int {
        return sensorType
    }
    
    @objc public func getScanModel() -> Int {
        return scanMode ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setScanModel(_ model:Int)->Bool
    {
        if (model != KBAdvMode.Legacy
                && model != KBAdvMode.LongRange
                && model != KBAdvMode.K2Mbps)
        {
            return false
        }else{
            self.scanMode = model;
            return true
        }
    }
    
    @objc public func getScanRssi() -> Int {
        return scanRssi ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setScanRssi(_ rssi:Int)->Bool{
        if (rssi >= KBCfgSensorScan.MIN_FILTER_RSSI
            && rssi <= KBCfgSensorScan.MAX_FILTER_RSSI)
        {
            scanRssi = rssi
            return true
        }
        else
        {
            return false
        }
    }
    
    @objc public func getScanMax() -> Int {
        return scanMax ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setScanMax(_ max:Int) ->Bool{
        if (max >= KBCfgSensorScan.MIN_SCAN_PERIPHERIAL_COUNT
            && max <= KBCfgSensorScan.MAX_SCAN_PERIPHERIAL_COUNT)
        {
            scanMax = max
            return true
        }else{
            return false
        }
    }
    
    @objc public func getScanDuration() -> Int {
        return scanDuration ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setScanDuration(_ duration:Int)->Bool{
        if (duration >= KBCfgSensorScan.MIN_SCAN_DURATION
            && duration <= KBCfgSensorScan.MAX_SCAN_DURATION)
        {
            scanDuration = duration
            return true
        }else{
            return false
        }
    }
    
    @objc public func getScanChanelMask() -> UInt8 {
        return scanChMsk ?? KBCfgBase.INVALID_UINT8
    }
    
    @objc @discardableResult public func setScanChanelMask(_ chMask: UInt8) -> Bool {
        if (chMask < 7) {
            self.scanChMsk = chMask
            return true
        } else {
            return false
        }
    }
    
    @objc @discardableResult public override func updateConfig(_ para: Dictionary<String, Any>) -> Int {
        var nUpdatePara = super.updateConfig(para)
        if let tempValue = para[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_MODE] as? Int {
            scanMode = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_RSSI] as? Int {
            scanRssi = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_DUR] as? Int {
            scanDuration = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_MSK] as? UInt8 {
            scanChMsk = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_MAX] as? Int {
            scanMax = tempValue
            nUpdatePara += 1
        }
        return nUpdatePara
    }
    
    @objc @discardableResult public override func toDictionary() -> Dictionary<String, Any> {
        var cfgDicts = super.toDictionary()

        if let tempValue = scanMode {
            cfgDicts[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_MODE]  = tempValue
        }
        
        if let tempValue = scanRssi {
            cfgDicts[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_RSSI]  = tempValue
        }
        
        if let tempValue = scanDuration {
            cfgDicts[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_DUR]  = tempValue
        }
        
        if let tempValue = scanChMsk {
            cfgDicts[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_MSK]  = tempValue
        }
        
        if let tempValue = scanMax {
            cfgDicts[KBCfgSensorScan.JSON_SENSOR_TYPE_SCAN_MAX]  = tempValue
        }
        return cfgDicts
    }
}
