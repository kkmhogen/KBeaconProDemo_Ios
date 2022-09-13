//
//  KBCfgAdvBase.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgAdvBase: KBCfgBase
{
    @objc public static let DEFAULT_ADV_PERIOD = Float(1000.0)
    @objc public static let MIN_ADV_PERIOD = Float(100.0)
    @objc public static let MAX_ADV_PERIOD = Float(20000.0)

    @objc public static let MAX_SLOT_INDEX = 4
    @objc public static let INVALID_SLOT_INDEX = 0xff

    @objc public static let DEFAULT_TX_POWER = Int(0)
    @objc public static let DEFAULT_ADV_CONNECTABLE = true
    @objc public static let DEFAULT_ADV_TRIGGER_ONLY = false
    @objc public static let DEFAULT_ADV_MODE = KBAdvMode.Legacy

    @objc public static let JSON_FIELD_ADV_OBJ_LIST = "advObj";

    @objc public static let  JSON_FIELD_SLOT = "slot"
    @objc public static let  JSON_FIELD_TX_PWR = "txPwr"
    @objc public static let  JSON_FIELD_ADV_PERIOD = "advPrd"
    @objc public static let  JSON_FIELD_BEACON_TYPE = "type"
    @objc public static let  JSON_FIELD_ADV_TRIGGER_ONLY = "trAdv"
    @objc public static let  JSON_FIELD_ADV_CONNECTABLE = "conn"
    @objc public static let  JSON_FIELD_ADV_MODE = "mode"

    var slotIndex : Int?
    
    var advType: Int? //beacon type (iBeacon, Eddy TLM/UID/ etc.,)
    
    var txPower : Int?

    var advPeriod: Float?

    var advConnectable : Bool? //is beacon can be connectable

    var advMode : Int?       //advertisement mode

    var advTriggerOnly: Bool?  //trigger only
    
    @objc public required override init()
    {
        super.init()
    }
    
    @objc public init(advType:Int)
    {
        self.advType = advType
        
        super.init()
    }

    //return KBCfgBase.INVALID_INT if is null
    @objc public func getSlotIndex()->Int
    {
        return slotIndex ?? KBCfgBase.INVALID_INT
    }

    //return KBCfgBase.INVALID_INT if is null
    @objc public func getAdvType()->Int
    {
        return advType ?? KBCfgBase.INVALID_INT
    }

    //return KBCfgBase.INVALID_FLOAT if is null
    @objc public func getAdvPeriod()->Float
    {
        return advPeriod ?? KBCfgBase.INVALID_FLOAT
    }

    //default is true
    @objc public func isAdvConnectable()->Bool
    {
        return advConnectable ?? true
    }

    //return KBCfgBase.INVALID_INT8 if is null
    @objc public func getTxPower()->Int
    {
        return txPower ?? KBCfgBase.INVALID_INT
    }

    //return KBCfgBase.INVALID_INT8 if is null
    @objc public func getAdvMode()->Int
    {
        return advMode ?? KBCfgBase.INVALID_INT
    }

    @objc public func isAdvTriggerOnly()->Bool
    {
        return advTriggerOnly ?? false
    }

    @objc public func setAdvTriggerOnly(_ enable:Bool)
    {
        self.advTriggerOnly = enable
    }

    @objc @discardableResult public func setSlotIndex(_ nSlotIndex:Int) ->Bool
    {
        if (nSlotIndex > KBCfgAdvBase.MAX_SLOT_INDEX)
        {
            return false
            //throw KBException(cause:KBErrorType.CfgInputInvalid,
            //                  desc:"adv type invalid");
        }
        slotIndex = nSlotIndex;
        return true
    }

    //set adv type
    @objc @discardableResult func setAdvType(_ advType:Int) ->Bool
    {
        if (advType > KBAdvType.MAXValue){
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc: "adv type invalid");
            return false
        }else{
            self.advType = advType;
            return true
        }
    }

    //set adv period
    @objc @discardableResult public func setAdvPeriod(_ advPeriod: Float) ->Bool
    {
        if (advPeriod >= KBCfgAdvBase.MIN_ADV_PERIOD)
        {
            self.advPeriod = advPeriod
            return true
        }
        else
        {
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"adv period invalid");
            return false
        }
    }

    //set KBeacon tx power
    @objc @discardableResult public func setTxPower(_ txPower:Int) ->Bool
    {
        if (txPower >= KBAdvTxPower.RADIO_TXPOWER_MIN_TXPOWER && txPower <= KBAdvTxPower.RADIO_TXPOWER_MAX_TXPOWER) {
            self.txPower = txPower;
            return true
        } else {
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"invalid tx power data");
            return false
        }
    }

    @objc public func setAdvConnectable(_ nConnectable:Bool)
    {
        advConnectable = nConnectable;
    }

    @objc @discardableResult public func setAdvMode(_ advMode:Int) ->Bool
    {
        if (advMode != KBAdvMode.Legacy
                && advMode != KBAdvMode.LongRange
                && advMode != KBAdvMode.K2Mbps) {
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"invalid advertise mode");
            return false
        }else{
            self.advMode = advMode;
            return true
        }
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdateParaNum = super.updateConfig(para);

        if let tempValue = para[KBCfgAdvBase.JSON_FIELD_BEACON_TYPE] as? Int {
            advType = tempValue;
            nUpdateParaNum += 1
        }
        
        if let tempValue = para[KBCfgAdvBase.JSON_FIELD_SLOT] as? Int {
            slotIndex = tempValue;
            nUpdateParaNum += 1
        }
        
        if let tempValue = para[KBCfgAdvBase.JSON_FIELD_TX_PWR] as? Int {
            txPower = tempValue;
            nUpdateParaNum += 1
        }

        let nTempFloat = parseFloat(para[KBCfgAdvBase.JSON_FIELD_ADV_PERIOD]);
        if (nTempFloat != nil) {
            advPeriod = nTempFloat!.floatValue
            nUpdateParaNum += 1
        }


        if let tempValue = para[KBCfgAdvBase.JSON_FIELD_ADV_CONNECTABLE] as? Int {
            advConnectable = (tempValue > 0);
            nUpdateParaNum += 1
        }

        if let tempValue = para[KBCfgAdvBase.JSON_FIELD_ADV_MODE] as? Int {
            advMode = tempValue;
            nUpdateParaNum += 1
        }

        if let tempValue = para[KBCfgAdvBase.JSON_FIELD_ADV_TRIGGER_ONLY] as? Int {
            advTriggerOnly = (tempValue > 0)
            nUpdateParaNum += 1
        }

        return nUpdateParaNum;
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary();
        
        //adv type
        if let tempValue = advType{
            cfgDicts[KBCfgAdvBase.JSON_FIELD_BEACON_TYPE] = tempValue
        }
        
        //slot
        if let tempValue = slotIndex{
            cfgDicts[KBCfgAdvBase.JSON_FIELD_SLOT] = tempValue
        }

        //tx power
        if let tempValue = txPower{
            cfgDicts[KBCfgAdvEddyUID.JSON_FIELD_TX_PWR] = tempValue
        }

        if let tempValue = advPeriod{
            cfgDicts[KBCfgAdvEddyUID.JSON_FIELD_ADV_PERIOD] = tempValue
        }

        if let tempValue = advConnectable{
            cfgDicts[KBCfgAdvEddyUID.JSON_FIELD_ADV_CONNECTABLE] = tempValue ? 1 : 0
        }

        if let tempValue = advMode{
            cfgDicts[KBCfgAdvEddyUID.JSON_FIELD_ADV_MODE] = tempValue
        }

        if let tempValue = advTriggerOnly{
            cfgDicts[KBCfgAdvEddyUID.JSON_FIELD_ADV_TRIGGER_ONLY] = tempValue ? 1 : 0
        }

        return cfgDicts;
    }
}
