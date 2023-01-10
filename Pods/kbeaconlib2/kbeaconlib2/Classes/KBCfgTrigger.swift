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
    @objc public static let MIN_TRIGGER_ADV_TIME = 2
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
    
    //humidity report interval
    @objc public static let KBTriggerConditionDefaultHumidityRptInterval = 300
    @objc public static let MIN_HUMIDITY_RPT_INTERVAL = 3;
    @objc public static let MAX_HUMIDITY_RPT_INTERVAL = 36000;
    
    //PIR repeat detected interval
    @objc public static let KBTriggerConditionPIRRepeatRptInterval = 30;
    @objc public static let MAX_PIR_REPORT_INTERVAL_VALUE = 3600;
    @objc public static let MIN_PIR_REPORT_INTERVAL_VALUE = 5;
    
    //Light level
    @objc public static let MAX_LIGHT_LEVEL_VALUE = 65535
    @objc public static let MIN_LIGHT_LEVEL_VALUE = 1

    @objc public static let JSON_FIELD_TRIGGER_OBJ_LIST = "trObj"
    @objc public static let JSON_FIELD_TRIGGER_INDEX = "trIdx";
    @objc public static let JSON_FIELD_TRIGGER_TYPE = "trType"
    @objc public static let JSON_FIELD_TRIGGER_ACTION = "trAct"
    @objc public static let JSON_FIELD_TRIGGER_PARA = "trPara"
    @objc public static let JSON_FIELD_TRIGGER_ADV_CHANGE_MODE = "trAChg"
    @objc public static let JSON_FIELD_TRIGGER_ADV_SLOT = "slot"
    @objc public static let JSON_FIELD_TRIGGER_ADV_TIME = "trATm"
    @objc public static let JSON_FIELD_TRIGGER_ADV_PERIOD = "trAPrd";
    @objc public static let JSON_FIELD_TRIGGER_ADV_POWER = "trAPwr";
    

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
    
    //trigger adv period
    var triggerAdvPeriod : Float?
    
    //trigger adv tx power
    var triggerAdvTxPower : Int?
    
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
    
    @objc public func getTriggerAdvPeriod()->Float
    {
        return triggerAdvPeriod ?? KBCfgBase.INVALID_FLOAT
    }
    
    @objc public func getTriggerAdvTxPower()->Int
    {
        return triggerAdvTxPower ?? KBCfgBase.INVALID_INT
    }

    @objc public func setTriggerAction(_ action:Int)
    {
        self.triggerAction = action
    }

    /**
     When we set multiple triggers to the same slot broadcast, we can set mode to 0x01 in order to distinguish different triggers based on broadcast content
     
     :param: mode if set to 0x01, the trigger advertisement content of UUID = configured UUID + trigger type.
    */
    @objc public func setTriggerAdvChangeMode(_ mode:Int)
    {
        triggerAdvChangeMode = mode
    }
    

    /**
     Different trigger types have different corresponding parameter ranges,
     
     :param: para For Motion Trigger: This parameter indicates the sensitivity of sensor detection, the range is 2~126, unit is 16mg
            For Humidity trigger: This parameter indicates the humidity threshold. unit is 1%
            For Temperature trigger: This parameter indicates the temperature threshold. unit is 1 Celsius
    */
    @objc public func setTriggerPara(_ para:Int)
    {
        triggerPara = para
    }
    
    @objc public func setTriggerIndex(_ index:Int)
    {
        triggerIndex = index
    }
    
    @objc public func setTriggerType(_ type: Int)
    {
        triggerType = type
    }

    @objc @discardableResult public func setTriggerAdvSlot(_ slot: Int) ->Bool {
        if (slot <= KBCfgAdvBase.MAX_SLOT_INDEX)
        {
            self.triggerAdvSlot = slot
            return true
        }else{
            return false
        }
    }
    
    @objc @discardableResult public func setTriggerAdvTime(_ time : Int) ->Bool
    {
        if (time >= KBCfgTrigger.MIN_TRIGGER_ADV_TIME
                && time <= KBCfgTrigger.MAX_TRIGGER_ADV_TIME) {
            self.triggerAdvTime = time
            return true
        }else{
            return false
        }
    }
    
    @objc @discardableResult public func setTriggerAdvPeriod(_ advPeriod : Float) ->Bool
    {
        if (advPeriod >= KBCfgAdvBase.MIN_ADV_PERIOD) {
            self.triggerAdvPeriod = advPeriod
            return true;
        } else {
            return false;
        }
    }

    //set trigger adv tx power
    @objc @discardableResult public func setTriggerAdvTxPower(_ txPower:Int) ->Bool
    {
        if (txPower >= KBAdvTxPower.RADIO_TXPOWER_MIN_TXPOWER && txPower <= KBAdvTxPower.RADIO_TXPOWER_MAX_TXPOWER) {
            self.triggerAdvTxPower = txPower;
            return true
        } else {
            return false
        }
    }
    
    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
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
        
        if let tempValue = para[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_POWER] as? Int {
            triggerAdvTxPower = tempValue;
            nUpdatePara += 1
        }


        let nTempFloat = parseFloat(para[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_PERIOD]);
        if (nTempFloat != nil) {
            triggerAdvPeriod = nTempFloat!.floatValue
            nUpdatePara += 1
        }
        return nUpdatePara;
    }

    
    @objc public override func toDictionary()->Dictionary<String, Any>
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
        
        //tx power
        if let tempValue = triggerAdvTxPower{
            cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_POWER] = tempValue
        }
        
        if let tempValue = triggerAdvPeriod{
            cfgDicts[KBCfgTrigger.JSON_FIELD_TRIGGER_ADV_PERIOD] = tempValue
        }

        return cfgDicts;
    }

}
