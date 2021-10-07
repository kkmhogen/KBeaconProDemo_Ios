//
//  KBHumidityRecord.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/26.
//

import Foundation

@objc public class KBHumidityRecord :NSObject{
    @objc public var utcTime : UInt32
    @objc public var temperature : Float
    @objc public var humidity : Float
    
    @objc public override init()
    {
        utcTime = 0
        temperature = 0
        humidity = 0
        
        super.init()
    }
    
    @objc public init(dicts dictPara:[String:Any])
    {
        utcTime = 0
        temperature = 0
        humidity = 0
        
        super.init()
        
        self.fromDictory(dictPara)
    }
    
    @objc public init(decode aDecoder: NSCoder)
    {
        //decode prope
        self.utcTime       = UInt32(bitPattern: aDecoder.decodeInt32(forKey: "utc"))
        self.temperature   = aDecoder.decodeFloat(forKey: "temp")
        self.humidity       = aDecoder.decodeFloat(forKey: "hum")
        
        super.init()
    }
    
    @objc public func encodeWithCoder(_ aCoder: NSCoder)
    {
        //encode properties/values
        aCoder.encode(Int32(bitPattern: self.utcTime), forKey: "utc")
        aCoder.encode(self.temperature, forKey: "temp")
        aCoder.encode(self.humidity, forKey: "hum")
    }
     

    @objc public func toDictory()->[String:Any]
    {
        return ["utc":self.utcTime, "temp": self.temperature, "hum": self.humidity]
    }

    @objc public func fromDictory(_ dicts:[String:Any])
    {
        if let nTemp = dicts["utc"] as? UInt32
        {
            self.utcTime = nTemp
        }
        if let nTemp = dicts["temp"] as? Float
        {
            self.temperature = nTemp
        }
        if let nTemp = dicts["hum"] as? Float
        {
            self.humidity = nTemp
        }
    }
}
