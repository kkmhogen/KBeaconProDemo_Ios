//
//  KBCfgSensorNFC.swift
//  KBeaconPro
//
//  Created by hogen hu on 2025/1/9.
//

import Foundation

@objc public class KBCfgSensorNFC:  KBCfgSensorBase {

    @objc public static let JSON_SENSOR_NFC_URI_ID = "id"
    @objc public static let JSON_SENSOR_NFC_URI_CONTENT = "uri"
    
    //max uri id value
    @objc public static let  NFC_URI_EMPTY = 0;
    @objc  public static let NFC_URI_HTTP_WWW = 1;
    @objc  public static let NFC_URI_HTTPS_WWW = 2;
    @objc  public static let NFC_URI_HTTP = 3;
    @objc  public static let NFC_URI_HTTPS = 4;
    @objc  public static let NFC_URI_TEL = 5;
    @objc  public static let NFC_URI_MAILTO = 6;

    @objc  public static let MAX_NFC_URI_CONTENT_LEN = 256;
    
    // type, BLE4.0, BLE5.0 PHY Coded, BLE5.0 Ext Adv
    private var uriID:Int?
    
    //scan min rssi
    private var uriContent:String?
    
    @objc public required init() {
        super.init()
        sensorType = KBSensorType.NFC
    }
    
    @objc public override func getSensorType() -> Int {
        return sensorType
    }
    
    @objc public func getUriID() -> Int {
        return uriID ?? KBCfgBase.INVALID_INT
    }
    
    @objc public func setUriID(_ uId:Int)
    {
       uriID = uId
    }
    
    @objc public func getUriContent() -> String? {
        return uriContent
    }
    
    @objc @discardableResult public func setUriContent(_ content:String)->Bool{
        if (content.count <= KBCfgSensorNFC.MAX_NFC_URI_CONTENT_LEN
            && !content.isEmpty)
        {
            uriContent = content
            return true
        }
        else
        {
            return false
        }
    }

    @objc @discardableResult public override func updateConfig(_ para: Dictionary<String, Any>) -> Int {
        var nUpdatePara = super.updateConfig(para)
        if let tempValue = para[KBCfgSensorNFC.JSON_SENSOR_NFC_URI_ID] as? Int {
            uriID = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgSensorNFC.JSON_SENSOR_NFC_URI_CONTENT] as? String {
            uriContent = tempValue
            nUpdatePara += 1
        }

        return nUpdatePara
    }
    
    @objc @discardableResult public override func toDictionary() -> Dictionary<String, Any> {
        var cfgDicts = super.toDictionary()

        if let tempValue = uriID {
            cfgDicts[KBCfgSensorNFC.JSON_SENSOR_NFC_URI_ID]  = tempValue
        }
        
        if let tempValue = uriContent {
            cfgDicts[KBCfgSensorNFC.JSON_SENSOR_NFC_URI_CONTENT]  = tempValue
        }

        return cfgDicts
    }
}
