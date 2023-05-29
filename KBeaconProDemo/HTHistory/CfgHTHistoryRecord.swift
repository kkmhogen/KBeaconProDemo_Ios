//
//  CfgHTHistoryRecord.swift
//  KBeaconProDemo
//
//  Created by Shuhui Hu on 2022/6/14.
//

import Foundation
import kbeaconlib2


public class CfgHTHistoryRecord {
    @objc public var record : KBRecordHumidity
    
    @objc public  init()
    {
        record = KBRecordHumidity()
    }
    
    @objc public required init(dicts dictPara:[String:Any])
    {
        record = KBRecordHumidity()
                
        self.fromDictory(dictPara)
    }
    
    @objc public func getTitle() -> String {
        return "UTC \t Temperature \t Humidity\n"
    }
    
    @objc public init(decode aDecoder: NSCoder)
    {
        record = KBRecordHumidity()

        //decode prope
        record.utcTime       = UInt32(bitPattern: aDecoder.decodeInt32(forKey: "utc"))
        record.temperature   = aDecoder.decodeFloat(forKey: "temp")
        record.humidity       = aDecoder.decodeFloat(forKey: "hum")
    }
    
    @objc public func encodeWithCoder(_ aCoder: NSCoder)
    {
        //encode properties/values
        aCoder.encode(Int32(bitPattern: record.utcTime), forKey: "utc")
        aCoder.encode(record.temperature, forKey: "temp")
        aCoder.encode(record.humidity, forKey: "hum")
    }
    
    @objc public func toUIStringLine()->String
    {
        let strNearbyUtcTime = localTimeFromUTCSeconds(record.utcTime)
        let strWriteLine = String(format:"%@\t%.2f\t%.2f\n",
                              strNearbyUtcTime, record.temperature, record.humidity)
        return strWriteLine
    }
     

    @objc public func toDictory()->[String:Any]
    {
        return ["utc":record.utcTime, "temp": record.temperature, "hum": record.humidity]
    }

    @objc public func fromDictory(_ dicts:[String:Any])
    {
        if let nTemp = dicts["utc"] as? UInt32
        {
            record.utcTime = nTemp
        }
        if let nTemp = dicts["temp"] as? Float
        {
            record.temperature = nTemp
        }
        if let nTemp = dicts["hum"] as? Float
        {
            record.humidity = nTemp
        }
    }
    
    func localTimeFromUTCSeconds(_ utcSecond : UInt32)->String
    {
        let date = Date(timeIntervalSince1970: Double(utcSecond))
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        return dateString
    }
}
