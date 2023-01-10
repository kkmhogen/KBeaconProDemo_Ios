//
//  KBCfgCommon.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation


@objc public class KBCfgCommon : KBCfgBase{
    @objc public static let  KB_CAPABILITY_KEY = 0x1
    @objc public static let  KB_CAPABILITY_BEEP =  0x2
    @objc public static let  KB_CAPABILITY_ACC = 0x4
    @objc public static let  KB_CAPABILITY_TEMP = 0x8
    @objc public static let  KB_CAPABILITY_HUMIDITY = 0x10

    @objc public static let MAX_NAME_LENGTH = 18

    @objc public static let MIN_REFERENCE_POWER = -100
    @objc public static let MAX_REFERENCE_POWER = 10
    @objc public static let MIN_ADV_PERIOD_MS = Float(100.0)
    @objc public static let MAX_ADV_PERIOD_MS = Float(40000.0)

    @objc public static let JSON_FIELD_MAX_SLOT_NUM = "maxSlot"
    @objc public static let  JSON_FIELD_BEACON_MODEL = "model"
    @objc public static let  JSON_FIELD_BEACON_VER = "ver"
    @objc public static let  JSON_FIELD_BEACON_HVER = "hver"
    @objc public static let  JSON_FIELD_MIN_TX_PWR = "minPwr"
    @objc public static let  JSON_FIELD_MAX_TX_PWR = "maxPwr"
    @objc public static let JSON_FIELD_MAX_TRIGGER_NUM = "maxTg"
    @objc public static let  JSON_FIELD_BASIC_CAPABILITY = "bCap"
    @objc public static let JSON_FIELD_TRIG_CAPABILITY = "trCap"
    @objc public static let JSON_FIELD_BATTERY_PERCENT = "btPt"

    //configurable parameters
    @objc public static let  JSON_FIELD_DEV_NAME = "name"
    @objc public static let  JSON_FIELD_PWD = "pwd"
    @objc public static let  JSON_FIELD_MEA_PWR = "meaPwr"
    @objc public static let  JSON_FIELD_AUTO_POWER_ON = "atPwr"
    @objc public static let  JSON_FIELD_MAX_ADV_PERIOD = "maxPrd";

    //basic capiblity
    private var maxSlot: Int?
    
    private var maxTrigger: Int?
    
    private var maxAdvPeriod: Float?
    
    private var basicCapability: Int?

    private var trigCapability: Int?

    private var maxTxPower: Int?

    private var minTxPower: Int?
    
    private var batteryPercent: Int?
    
    private var  model: String?

    private var  version: String?

    private var hversion : String?

    ////////////////////can be configruation able///////////////////////
    private var refPower1Meters:Int?   //received RSSI at 1 meters

    private var password: String?

    private var name: String?

    private var alwaysPowerOn : Bool? //beacon automatic start advertisement after powen on

    @objc public func getMaxSlot()->Int
    {
        return maxSlot ?? 5
    }
    
    @objc public func getMaxAdvPeriod()->Float
    {
        return maxAdvPeriod ?? 10000.0
    }
    
    @objc public func getMaxTrigger()->Int
    {
        return maxTrigger ?? 5
    }

    //basic capability
    @objc public func getBasicCapability()->Int
    {
        return basicCapability ?? 0
    }
    
    @objc public func isSupportAdvType(_ advType:Int)->Bool
    {
        if let tempAdvCap = self.basicCapability{
            let rightMoveBit = 8 + advType - 1
            return ((tempAdvCap >> rightMoveBit) & 0x1) > 0;
        }else{
            return false
        }
    }
    
    //is the device support iBeacon
    @objc public func isSupportIBeacon()->Bool
    {
        return isSupportAdvType(KBAdvType.IBeacon)
    }

    //is the device support URL
    @objc public func isSupportEddyURL()->Bool
    {
        return isSupportAdvType(KBAdvType.EddyURL)
    }

    //is the device support TLM
    @objc public func isSupportEddyTLM()->Bool
    {
        return isSupportAdvType(KBAdvType.EddyTLM)
    }

    //is the device support UID
    @objc public func isSupportEddyUID()->Bool
    {
        return isSupportAdvType(KBAdvType.EddyUID)
    }

    //support kb sensor
    @objc public func isSupportKBSensor()->Bool
    {
        return isSupportAdvType(KBAdvType.Sensor)
    }
    
    //support kb system adv
    @objc public func isSupportKBSystem()->Bool
    {
        return isSupportAdvType(KBAdvType.System)
    }

    //support BLE5 LongRange
    @objc public func isSupportBLELongRangeAdv()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return ((tempAdvCap >> 16) & 0x2) > 0
        }else{
            return false
        }
    }

    //support BLE5 2MBPS
    @objc public func isSupportBLE2MBps()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return ((tempAdvCap >> 16) & 0x4) > 0;
        }else{
            return false
        }
    }

    //support security DFU
    @objc public func isSupportSecurityDFU()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return ((tempAdvCap >> 16) & 0x8) > 0;
        }else{
            return false
        }
    }

    //is support button
    @objc public func isSupportButton()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x1) > 0
        }else{
            return false
        }
    }

    //is support beep
    @objc public func isSupportBeep()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x2) > 0
        }else{
            return false
        }
    }

    //is support acc sensor
    @objc public func isSupportAccSensor()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x4) > 0
        }else{
            return false
        }
    }

    //is support humidity sensor
    @objc public func isSupportHumiditySensor()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x8) > 0
        }else{
            return false
        }
    }
    
    //is support history
    @objc public func isSupportHistoryRecord()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x100000) > 0
        }else{
            return false
        }
    }
    
    //is support cutoff sensor
    @objc public func isSupportCutoffSensor()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x10) > 0
        }else{
            return false
        }
    }
    
    //is support pir sensor
    @objc public func isSupportPIRSensor()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x20) > 0
        }else{
            return false
        }
    }
    
    //is support light sensor
    @objc public func isSupportLightSensor()->Bool
    {
        if let tempAdvCap = self.basicCapability{
            return (tempAdvCap & 0x40) > 0
        }else{
            return false
        }
    }
    
    //is support button
    @objc public func isSupportTrigger(_ triggerType:Int)->Bool
    {
        if let tmpTriggerCap = self.trigCapability{
            let triggerMask = 0x1 << (triggerType - 1)
            return (tmpTriggerCap & triggerMask) > 0
        }else{
            return false
        }
    }

    //trigger capability
    @objc public func getTrigCapability()->Int
    {
        return trigCapability ?? 0
    }

    @objc public func getMaxTxPower()->Int
    {
        return maxTxPower ?? KBCfgBase.INVALID_INT
    }

    @objc public func getMinTxPower()->Int
    {
        return minTxPower ?? KBCfgBase.INVALID_INT
    }

    @objc public func getRefPower1Meters()->Int
    {
        return refPower1Meters ?? KBCfgBase.INVALID_INT
    }

    @objc public func getModel()->String?
    {
        return model
    }

    @objc public func getVersion()->String?
    {
        return version
    }

    @objc public func getHardwareVersion()->String?
    {
        return hversion
    }

    @objc public func getName()->String?
    {
        return name
    }

    @objc public override init() {
        super.init()
    }

    @objc public func isAlwaysPowerOn()->Bool
    {
        return alwaysPowerOn ?? false
    }


    @objc @discardableResult public func setRefPower1Meters(_ value: Int)->Bool{
        if (value < -10 && value > -100) {
            self.refPower1Meters = value;
            return true
        } else {
            return false
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"reference power invalid");
        }
    }

    @objc @discardableResult public func setPassword(_ password: String) ->Bool{
        if (password.count >= 8 && password.count <= 16) {
            self.password = password;
            return true
        } else {
            return false
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc: "password length invalid");
        }
    }

    @objc @discardableResult public func setName(_ name: String) ->Bool{
        if (name.count <= KBCfgCommon.MAX_NAME_LENGTH) {
            self.name = name;
            return true
        } else {
            return false
        }
    }

    @objc public func setAlwaysPowerOn(_ isEnable: Bool) {
        self.alwaysPowerOn = isEnable
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgCommon.JSON_FIELD_BEACON_MODEL] as? String {
            model = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_BEACON_VER] as? String {
            version = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_BEACON_HVER] as? String {
            hversion = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_MAX_TX_PWR] as? Int {
            maxTxPower = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_MIN_TX_PWR] as? Int {
            minTxPower = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_MAX_SLOT_NUM] as? Int {
            maxSlot = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_MAX_TRIGGER_NUM] as? Int {
            maxTrigger = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_MAX_ADV_PERIOD] as? Float {
            maxAdvPeriod = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_BASIC_CAPABILITY] as? Int {
            basicCapability = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_TRIG_CAPABILITY] as? Int {
            trigCapability = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgCommon.JSON_FIELD_MEA_PWR] as? Int {
            refPower1Meters = tempValue
            nUpdatePara += 1
        }

        //password
        if let tempValue = para[KBCfgCommon.JSON_FIELD_PWD] as? String {
            password = tempValue
            nUpdatePara += 1
        }

        //device name
        if let tempValue = para[KBCfgCommon.JSON_FIELD_DEV_NAME] as? String {
            name = tempValue
            nUpdatePara += 1
        }

        //auto power on
        if let tempValue = para[KBCfgCommon.JSON_FIELD_AUTO_POWER_ON] as? Int {
            alwaysPowerOn = (tempValue > 0)
            nUpdatePara += 1
        }
        
        //battery percent
        if let tempValue = para[KBCfgCommon.JSON_FIELD_BATTERY_PERCENT] as? Int {
            batteryPercent = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara;
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var configDicts = super.toDictionary()

        //reference power
        if let tempValue = refPower1Meters {
            configDicts[KBCfgCommon.JSON_FIELD_MEA_PWR] = tempValue
        }

        //password
        if let tempValue = self.password, tempValue.count >= 8, tempValue.count <= 16 {
            configDicts[KBCfgCommon.JSON_FIELD_PWD] = tempValue
        }

        //device name
        if let tempValue = name {
            configDicts[KBCfgCommon.JSON_FIELD_DEV_NAME] = tempValue
        }

        //auto power
        if let tempValue = alwaysPowerOn {
            configDicts[KBCfgCommon.JSON_FIELD_AUTO_POWER_ON] = tempValue ? 1 : 0;
        }

        return configDicts;
    }
}
