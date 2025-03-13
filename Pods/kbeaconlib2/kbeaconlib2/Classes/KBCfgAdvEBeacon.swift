//
//  KBCfgAdvEBeacon.swift
//  KBeaconPro
//
//  Created by hogen hu on 2024/8/29.
//

import Foundation

@objc public class KBCfgAdvEBeacon : KBCfgAdvBase{
    @objc public static let JSON_FIELD_EBEACON_UUID  = "uuid"
    @objc public static let  JSON_FIELD_EBEACON_AES_TYPE  = "aes"
    @objc public static let  JSON_FIELD_EBEACON_INTERVAL = "enItvl"

    @objc public static let  DEFAULT_UUID = "7777772E-6B6B-6D63-6E2E-636F6D000001"
    
    //0: AES ECB
    @objc public static let  AES_ECB_TYPE = UInt8(0x1)
    
    @objc public static let  DEFAULT_INTERVER = UInt8(0x5)

    @objc public static let  DEFAULT_UUID_LENGTH = 36

    @objc public static let  MIN_INTERVAL = 1
    @objc public static let  MAX_INTERVAL = 100
    
    //aes type, 0: aes ECB
    var aesType: UInt8?

    //encrypt interval, unit is second
    var enItvl : UInt8?

    //UUID for encrypt
    var uuid : String?
    
    @objc public required init()
    {
        super.init(advType: KBAdvType.EBeacon)
    }

    @objc public func getUuid()->String?
    {
        return uuid
    }

    @objc public func getAESType()->UInt8
    {
        return aesType ?? KBCfgBase.INVALID_UINT8
    }

    @objc public func getEncryptInterval()->UInt8
    {
        return enItvl ?? KBCfgBase.INVALID_UINT8
    }

    //set AES encrypt type
    @objc public func setAESType(_ type: UInt8)
    {
        aesType = type
    }

    //When Beacon broadcasts, it will update the UTC time every x(enItvl) seconds
    //and the encryption algorithm is re-run.
    @objc @discardableResult public func setEncryptInterval(_ interval: UInt8) -> Bool
    {
        if (interval <= KBCfgAdvEBeacon.MAX_INTERVAL && interval >= KBCfgAdvEBeacon.MIN_INTERVAL)
        {
            enItvl = interval
            return true
        }
        return false
    }

    //Set the UUID of the broadcast to be encrypted
    @objc @discardableResult public func setUuid(_ uuid: String) ->Bool
    {
        if (uuid.isUUIDString())
        {
            self.uuid = uuid;
            return true
        }
        return false
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgAdvEBeacon.JSON_FIELD_EBEACON_UUID] as? String {
            uuid = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgAdvEBeacon.JSON_FIELD_EBEACON_INTERVAL] as? UInt8 {
            enItvl = tempValue
            nUpdatePara += 1
        }
        
        if let tempValue = para[KBCfgAdvEBeacon.JSON_FIELD_EBEACON_AES_TYPE] as? UInt8 {
            aesType = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        
        if let tempValue = uuid{
            cfgDicts[KBCfgAdvEBeacon.JSON_FIELD_EBEACON_UUID] = tempValue
        }
        
        if let tempValue = enItvl{
            cfgDicts[KBCfgAdvEBeacon.JSON_FIELD_EBEACON_INTERVAL] = tempValue
        }
        
        if let tempValue = aesType{
            cfgDicts[KBCfgAdvEBeacon.JSON_FIELD_EBEACON_AES_TYPE] = tempValue
        }

        return cfgDicts;
    }
}
