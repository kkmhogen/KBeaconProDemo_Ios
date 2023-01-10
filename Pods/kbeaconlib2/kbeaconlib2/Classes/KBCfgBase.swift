//
//  KBCfgBase.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgBase : NSObject
{
    
    @objc public static let INVALID_FLOAT = Float(0xFFFFFF)
    @objc public static let INVALID_INT = Int(0x7FFFFFFF)
    @objc public static let INVALID_UINT = UInt(0xFFFFFFFF)
    @objc public static let INVALID_INT8 = Int8(0x7F)
    @objc public static let INVALID_UINT8 = UInt8(0xFF)
    @objc public static let INVALID_UINT16 = UInt16(0xFFFF)

    @objc public static let JSON_MSG_TYPE_KEY = "msg";
    @objc public static let JSON_MSG_TYPE_CFG = "cfg";
    @objc public static let JSON_MSG_TYPE_GET_PARA = "getPara";
    @objc public static let JSON_FIELD_SUBTYPE = "type";
    
    @objc override init()
    {
        super.init()
    }
    
    @objc @discardableResult public func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        return 0
    }
    
    @objc public func toJsonObject()->[String:Any]
    {
       return toDictionary()
    }

    @objc public static func JsonString2HashMap(_ jsonMsg: String)->[String:Any]?
    {
        return jsonMsg.toDictionary()
    }
    
    @objc public func parseFloat(_ value:Any?)->NSNumber?
    {
        var parseData:NSNumber?
        if let oPeriodData = value
        {
            if let tempValue =  oPeriodData as? Float
            {
                parseData = NSNumber(value: tempValue);
            }
            else if let tempValue =  oPeriodData as? Double
            {
                parseData = NSNumber(value: Float(tempValue))
            }
            else if let tempValue =  oPeriodData as? Int
            {
                parseData = NSNumber(value: Float(tempValue))
            }
        }

        return parseData
    }
    
    @objc public func toDictionary()->Dictionary<String, Any>
    {
        let cfgDicts:Dictionary<String, Any> = Dictionary()
        
        return cfgDicts
    }

}
