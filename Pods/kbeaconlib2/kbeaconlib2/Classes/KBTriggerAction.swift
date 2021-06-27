//
//  KBTriggerAction.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation

@objc public class KBTriggerAction : NSObject{
    //action option
    @objc public static let ActionOff = 0x0    //disable trigger
    @objc public static let Advertisement = 0x1    //start advertisement when trigger event happened
    @objc public static let Alert = 0x2  //start beep led flash when trigger event happened
    @objc public static let Record = 0x4
    @objc public static let Vibration = 0x8
    @objc public static let ReportToApp = 0x10
    
    @objc public static let AllMask = (0x1 | 0x2 | 0x4 | 0x8 | 0x10)
}
