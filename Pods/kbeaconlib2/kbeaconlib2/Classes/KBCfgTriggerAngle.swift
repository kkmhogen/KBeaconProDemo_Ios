//
//  KBCfgTriggerAngle.swift
//  KBeaconPro
//
//  Created by hogen hu on 2023/12/11.
//

import UIKit

public class KBCfgTriggerAngle:  KBCfgTrigger {
    //上报间隔 分钟
    public static let JSON_FIELD_TRIGGER_REPEAT_PRD = "rptPrd"
    public static let JSON_FIELD_TRIGGER_ABOVEANGLE = "aAng"
    public static let MAX_TRIGGER_RPT_TIME = 255
    public static let MIN_TRIGGER_RPT_TIME = 0
    public static let MAX_TRIGGER_ANGLE = 90
    public static let MIN_TRIGGER_ANGLE = -90
    
    //when beacon detects that the tilt angle is less or above then the threshold, it will trigger an event.
    //If it is not recovered after reportInterval, it will trigger event again
    //the unit is minute
    private var reportInterval:Int?
    
    //when the beacon tilt angle greater than or equal aboveAngle, a trigger event is sent
    private var aboveAngle:Int?
    
    public required init()
    {
        super.init(0, triggerType: KBTriggerType.AccAngle)
    }
    
    public func getReportingInterval() -> Int? {
        return reportInterval
    }
    
    public func setReportingInterval(_ interval : Int) {
        reportInterval = interval
    }
    
    public func getAboveAngle() -> Int? {
        return aboveAngle
    }
    
    public func setAboveAngle(_ angle:Int) {
        aboveAngle = angle
    }
    
    public override func updateConfig(_ para: Dictionary<String, Any>) -> Int {
        var nUpdatePara = super.updateConfig(para)
        if let tempValue = para[KBCfgTriggerAngle.JSON_FIELD_TRIGGER_REPEAT_PRD] as? Int {
            reportInterval = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgTriggerAngle.JSON_FIELD_TRIGGER_ABOVEANGLE] as? Int {
            aboveAngle = tempValue
            nUpdatePara += 1
        }
        return nUpdatePara
    }
    
    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        if let tempValue = reportInterval{
            cfgDicts[KBCfgTriggerAngle.JSON_FIELD_TRIGGER_REPEAT_PRD] = tempValue
        }
        
        if let tempValue = aboveAngle{
            cfgDicts[KBCfgTriggerAngle.JSON_FIELD_TRIGGER_ABOVEANGLE] = tempValue
        }
        
        return cfgDicts;
    }
}
