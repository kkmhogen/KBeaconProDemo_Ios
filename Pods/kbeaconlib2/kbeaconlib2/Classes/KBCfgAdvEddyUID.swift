//
//  KBCfgAdvEddyUID.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgAdvEddyUID : KBCfgAdvBase
{
    @objc public static let JSON_FIELD_EDDY_UID_NID  = "nid"
    @objc public static let JSON_FIELD_EDDY_UID_SID  = "sid"

    @objc public static let DEFAULT_NAMESPACE_ID = "0x00000000000000000001"
    @objc public static let DEFAULT_SERIALD_ID = "0x000000000001"
    @objc public static let NAMESPACE_ID_LENGTH = 22
    @objc public static let SERIAL_ID_LENGTH = 14

    //nid
    private var nid : String?

    //sid
    private var sid : String?

    @objc public required init()
    {
        super.init(advType: KBAdvType.EddyUID);
    }

    @objc public func getNid()->String?
    {
        return nid;
    }

    @objc public func getSid()->String?
    {
        return sid;
    }

    @objc @discardableResult public func setNid(_ nid: String) ->Bool
    {
        if (nid.count == 22 && nid.isHexString())
        {
            self.nid = nid;
            return true
        }
        else
        {
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"nid invalid")
            return false
        }
    }

    @objc @discardableResult public func setSid(_ sid: String) ->Bool
    {
        if (sid.count == 14 && sid.isHexString()) {
            self.sid = sid;
            return true
        } else {
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"sid invalid")
            return false
        }
    }


    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgAdvEddyUID.JSON_FIELD_EDDY_UID_NID] as? String {
            nid = tempValue
            nUpdatePara += 1
        }

        if let tempValue = para[KBCfgAdvEddyUID.JSON_FIELD_EDDY_UID_SID] as? String {
            sid = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara;
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary();
        
        if let tempValue = nid{
            cfgDicts[KBCfgAdvEddyUID.JSON_FIELD_EDDY_UID_NID] = tempValue
        }
        
        if let tempValue = sid{
            cfgDicts[KBCfgAdvEddyUID.JSON_FIELD_EDDY_UID_SID] = tempValue
        }

        return cfgDicts;
    }
}
