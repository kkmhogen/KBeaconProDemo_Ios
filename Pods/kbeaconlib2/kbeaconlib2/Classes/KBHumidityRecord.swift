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
}
