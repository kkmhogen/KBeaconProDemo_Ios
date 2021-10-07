//
//  KBCfgType.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgType : NSObject
{
    //device common parameters
    @objc public static let CommonPara = 0x1

    //slot advertisement parameters
    @objc public static let AdvPara = 0x2

    //trigger parameters
    @objc public static let TriggerPara = 0x4

    //sensor parameters
    @objc public static let SensorPara = 0x8
}
