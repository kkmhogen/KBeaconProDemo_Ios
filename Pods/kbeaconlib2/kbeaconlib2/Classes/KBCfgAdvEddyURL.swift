//
//  KBCfgAdvEddyURL.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgAdvEddyURL : KBCfgAdvBase{

    @objc public static let JSON_FIELD_EDDY_URL_ADDR  = "url"
    @objc public static let DEFAULT_URL_ADDRESS = "https://www.google.com/"
    @objc public static let MAX_URL_LENGTH = 30

    private var url : String?

    @objc public required init()
    {
        super.init(advType: KBAdvType.EddyURL)
    }

    @objc public func getUrl() -> String?
    {
        return url;
    }

    @objc @discardableResult public func setUrl(_ url : String) ->Bool
    {
        let strUrl = url.replacingOccurrences(of: " ", with: "")
        if (strUrl.count >= 3)
        {
            self.url = strUrl;
            return true
        }
        else
        {
            return false
            //throw KBException(cause:KBErrorType.CfgInputInvalid, desc:"url invalid")
        }
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgAdvEddyURL.JSON_FIELD_EDDY_URL_ADDR] as? String {
            url = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara;
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary()
        if let tempValue = url{
            cfgDicts[KBCfgAdvEddyURL.JSON_FIELD_EDDY_URL_ADDR] = tempValue
        }

        return cfgDicts;
    }
}
