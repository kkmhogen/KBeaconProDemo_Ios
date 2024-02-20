//
//  KBAccSensorValue.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAccSensorValue : NSObject
{
    @objc public var xAis: Int16 = 0
    
    @objc public var yAis: Int16 = 0
    
    @objc public var zAis: Int16 = 0
}

@objc public class KBAccAOAValue : NSObject
{
    @objc public var xAis: Int8 = 0
    
    @objc public var yAis: Int8 = 0
    
    @objc public var zAis: Int8 = 0
}
