//
//  KBConnPara.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/27.
//

import Foundation

@objc public class KBConnPara : NSObject
{
    //sync the current phone's UTC time to device
    @objc public var syncUtcTime : Bool = true 
    
    //read common paramters while connection
    @objc public var readCommPara : Bool = true
    
    //read advertisement slots parameters while connection
    @objc public var readSlotPara : Bool = true
    
    //read trigger parameters while connecting
    @objc public var readTriggerPara : Bool = true
    
    //Read sensor parameters while connecting
    @objc public var readSensorPara :Bool = false

    @objc public override init()
    {
    }
}
