//
//  KBCfgTriggerMotion.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/9/5.
//

import Foundation

@objc public class KBCfgTriggerMotion: KBCfgTrigger{
    @objc public static let ACC_ODR_1_HZ = 0x0
    @objc public static let ACC_ODR_10_HZ = 0x1
    @objc public static let ACC_ODR_25_HZ = 0x2
    @objc public static let ACC_ODR_50_HZ = 0x3

    @objc public static let MIN_WAKEUP_DURATION = 1
    @objc public static let MAX_WAKEUP_DURATION = 255

    @objc public static let ACC_DEFAULT_ODR = 0x2
    @objc public static let ACC_DEFAULT_WAKEUP_DURATION = 1

    @objc public static let JSON_FIELD_TRIGGER_MOTION_ACC_ODR = "odr"
    @objc public static let JSON_FIELD_TRIGGER_MOTION_DURATION = "ocnt"

    var accODR: Int?

    //the wakeup duration unit is 1/odr
    var wakeupDuration: Int?
    
    @objc public required init()
    {
        super.init(0, triggerType: KBTriggerType.AccMotion)
    }
    
    @objc public func getAccODR()->Int
    {
        return accODR ?? KBCfgTriggerMotion.ACC_ODR_25_HZ
    }

    @objc public func getWakeupDuration()->Int
    {
        return wakeupDuration ?? KBCfgBase.INVALID_INT
    }
    
    @objc @discardableResult public func setAccODR(_ odr:Int)->Bool
    {
        if (odr < KBCfgTriggerMotion.ACC_ODR_1_HZ || odr > KBCfgTriggerMotion.ACC_ODR_50_HZ) {
            return false
        }
        accODR = odr;
        return true
    }

    @objc @discardableResult public func setWakeupDuration(_ duration:Int)->Bool
    {
        if (duration < KBCfgTriggerMotion.MIN_WAKEUP_DURATION || duration > KBCfgTriggerMotion.MAX_WAKEUP_DURATION)
        {
            return false
        }

        wakeupDuration = duration
        return true
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)
        
        if let tempValue = para[KBCfgTriggerMotion.JSON_FIELD_TRIGGER_MOTION_ACC_ODR] as? Int {
            accODR = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgTriggerMotion.JSON_FIELD_TRIGGER_MOTION_DURATION] as? Int {
            wakeupDuration = tempValue
            nUpdatePara += 1
        }
        
        return nUpdatePara;
    }

    
    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        if let tempValue = accODR{
            cfgDicts[KBCfgTriggerMotion.JSON_FIELD_TRIGGER_MOTION_ACC_ODR] = tempValue
        }
        
        if let tempValue = wakeupDuration{
            cfgDicts[KBCfgTriggerMotion.JSON_FIELD_TRIGGER_MOTION_DURATION] = tempValue
        }

        return cfgDicts;
    }
}
