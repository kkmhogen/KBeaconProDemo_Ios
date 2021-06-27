//
//  KBCfgTriggerBase.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation

@objc public class KBCfgTrigger : KBCfgBase {
    //trigger adv time
    @objc public static let DEFAULT_TRIGGER_ADV_TIME = 30
    @objc public static let MIN_TRIGGER_ADV_TIME = 5
    @objc public static let MAX_TRIGGER_ADV_TIME = 7200
    
    //motion trigger
    @objc public static let DEFAULT_MOTION_SENSITIVITY = 0x2;   //default motion sensitive
    @objc public static let MAX_MOTION_SENSITIVITY = 127;
    @objc public static let MIN_MOTION_SENSITIVITY = 2;
    
    //humidity trigger
    @objc public static let KBTriggerConditionDefaultHumidityAbove = 80
    @objc public static let KBTriggerConditionDefaultHumidityBelow = 20
    @objc public static let MIN_HUMIDITY_VALUE = 1
    @objc public static let MAX_HUMIDITY_VALUE = 99
    
    //temperature trigger
    @objc public static let KBTriggerConditionDefaultTemperatureAbove = 60
    @objc public static let KBTriggerConditionDefaultTemperatureBelow = -10;
    @objc public static let MAX_TEMPERATURE_VALUE = 1000;
    @objc public static let MIN_TEMPERATURE_VALUE = -50;

    @objc public static let JSON_FIELD_TRIGGER_OBJ_LIST = "trObj"
    @objc public static let JSON_FIELD_TRIGGER_INDEX = "trIdx";
    @objc public static let JSON_FIELD_TRIGGER_TYPE = "trType"
    @objc public static let JSON_FIELD_TRIGGER_ACTION = "trAct"
    @objc public static let JSON_FIELD_TRIGGER_PARA = "trPara"
    @objc public static let JSON_FIELD_TRIGGER_ADV_CHANGE_MODE = "trAChg"
    @objc public static let JSON_FIELD_TRIGGER_ADV_SLOT = "slot"
    @objc public static let JSON_FIELD_TRIGGER_ADV_TIME = "trATm"

    //trigger index
    var triggerIndex: Int
    
    //trigger type
    var triggerType: Int

    //trigger action, advertise, report app or alert
    var triggerAction: Int?

    //trigger advMode
    var triggerAdvChangeMode: Int?
    
    //trigger para
    var triggerPara : Int?

    //trigger advertise slot
    var triggerAdvSlot: Int?

    //trigger advertise time
    var triggerAdvTime : Int?
    
    @objc public required override init(){
        triggerType = KBTriggerType.AccMotion
        triggerIndex = 0
    }
    
    @objc  public init(_ triggerIndex:Int, triggerType:Int){
        self.triggerIndex = triggerIndex
        self.triggerType = triggerType;
        super.init()
    }
    
    @objc public func getTriggerIndex()->Int
    {
        return triggerIndex
    }

    @objc public func getTriggerType()->Int
    {
        return triggerType
    }

    @objc public func getTriggerAction()->Int
    {
        return triggerAction ?? KBCfgBase.INVALID_INT
    }
    
    @objc public func getTriggerPara()->Int
    {
        return triggerPara ?? KBCfgBase.INVALID_INT
    }

    @objc public func getTriggerAdvChgMode()->Int
    {
        return triggerAdvChangeMode ?? KBCfgBase.INVALID_INT
    }

    @objc public func getTriggerAdvSlot()->Int
    {
        return triggerAdvSlot ?? KBCfgBase.INVALID_INT
    }

    @objc public func getTriggerAdvTime()->Int
    {
        return triggerAdvTime ?? KBCfgBase.INVALID_INT
    }

    public func setTriggerAction(_ action:Int)
    {
        self.triggerAction = action
    }

    /**
     When we set multiple triggers to the same slot broadcast, we can set mode to 0x01 in order to distinguish different triggers based on broadcast content
     
     :param: mode if set to 0x01, the trigger advertisement content of UUID = configured UUID + trigger type.
    */
    public func setTriggerAdvChangeMode(_ mode:Int)
    {
        triggerAdvChangeMode = mode
    }
    

    /**
     Different trigger types have different corresponding parameter ranges,
     
     :param: para For Motion Trigger: This parameter indicates the sensitivity of sensor detection, the range is 2~126, unit is 16mg
            For Humidity trigger: This parameter indicates the humidity threshold. unit is 1%
            For Temperature trigger: This parameter indicates the temperature threshold. unit is 1 Celsius
    */
    public func setTriggerPara(_ para:Int)
    {
        triggerPara = para
    }
    
    public func setTriggerIndex(_ index:Int)
    {
        triggerIndex = index
    }
    
    public func setTriggerType(_ type: Int)
    {
        triggerType = type
    }

    @discardableResult public func setTriggerAdvSlot(_ slot: Int) ->Bool {
        if (slot <= KBCfgAdvBase.MAX_SLOT_INDEX)
        {
            self.triggerAdvSlot = slot
            return true
        }else{
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"trigger slot invalid");
            return false
        }
    }
    
    @discardableResult public func setTriggerAdvTime(_ time : Int) ->Bool
    {
        if (time >= KBCfgTrigger.MIN_TRIGGER_ADV_TIME
                && time <= KBCfgTrigger.MAX_TRIGGER_ADV_TIME) {
            self.triggerAdvTime = time
            return true
        }else{
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"trigger adv time invalid");
            return false
        }
    }
    
    @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)
        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_INDEX] as? Int {
            triggerIndex = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_TYPE] as? Int {
            triggerType = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_ACTION] as? Int {
            triggerAction = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_CHANGE_MODE] as? Int {
            triggerAdvChangeMode = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_PARA] as? Int {
            triggerPara = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_SLOT] as? Int {
            triggerAdvSlot = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_TIME] as? Int {
            triggerAdvTime = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara;
    }

    
    public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        //trigger type
        cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_INDEX] = self.triggerIndex
        
        //trigger type
        cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_TYPE] = triggerType
        
        if let tempValue = triggerAction{
            cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_ACTION] = tempValue
        }

        if let tempValue = triggerAdvChangeMode{
            cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_CHANGE_MODE] = tempValue
        }

        if let tempValue = triggerAdvSlot{
            cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_SLOT] = tempValue
        }
        
        if let tempValue = triggerAdvTime{
            cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_TIME] = tempValue
        }
        
        if let tempValue = triggerPara{
            cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_PARA] = tempValue
        }

        return cfgDicts;
    }

}
