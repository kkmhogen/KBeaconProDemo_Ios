//
//  KBCfgAdvIBeacon.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgAdvIBeacon : KBCfgAdvBase{
    @objc public static let JSON_FIELD_IBEACON_UUID  = "uuid"
    @objc public static let  JSON_FIELD_IBEACON_MAJORID  = "majorID"
    @objc public static let  JSON_FIELD_IBEACON_MINORID = "minorID"

    @objc public static let  DEFAULT_UUID = "7777772E-6B6B-6D63-6E2E-636F6D000001"
    @objc public static let  DEFAULT_MAJOR = UInt(0x1)
    @objc public static let  DEFAULT_MINOR = UInt(0x1)

    @objc public static let  MAX_MAJOR_MINOR = UInt(65535)
    @objc public static let  DEFAULT_UUID_LENGTH = 36

    var majorID: UInt?

    var minorID : UInt?

    var uuid : String?
    
    @objc public required init()
    {
        super.init(advType: KBAdvType.IBeacon)
    }

    @objc public func getUuid()->String?
    {
        return uuid
    }

    @objc public func getMajorID()->UInt
    {
        return majorID ?? KBCfgBase.INVALID_UINT
    }

    @objc public func getMinorID()->UInt
    {
        return minorID ?? KBCfgBase.INVALID_UINT
    }

    @objc public func setMajorID(_ majorID: UInt)
    {
        if (majorID <= UInt16.max)
        {
            self.majorID = majorID
        }
    }

    @objc public func setMinorID(_ minorID: UInt)
    {
        if (minorID <= UInt16.max)
        {
            self.minorID = minorID
        }
    }

    @objc @discardableResult public func setUuid(_ uuid: String) ->Bool
    {
        if (uuid.isUUIDString())
        {
            self.uuid = uuid;
            return true
        }
        else
        {
            return false
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"uuid invalid")
        }
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgAdvIBeacon.JSON_FIELD_IBEACON_UUID] as? String {
            uuid = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgAdvIBeacon.JSON_FIELD_IBEACON_MAJORID] as? Int {
            majorID = UInt(bitPattern: tempValue)
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgAdvIBeacon.JSON_FIELD_IBEACON_MINORID] as? Int {
            minorID = UInt(bitPattern:tempValue)
            nUpdatePara += 1
        }

        return nUpdatePara
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        if let tempValue = uuid{
            cfgDicts[KBCfgAdvIBeacon.JSON_FIELD_IBEACON_UUID] = tempValue
        }
        
        if let tempValue = majorID{
            cfgDicts[KBCfgAdvIBeacon.JSON_FIELD_IBEACON_MAJORID] = tempValue
        }
        
        if let tempValue = minorID{
            cfgDicts[KBCfgAdvIBeacon.JSON_FIELD_IBEACON_MINORID] = tempValue
        }

        return cfgDicts;
    }
}
