//
//  KBTriggerAdvChgMode.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation

@objc public class KBTriggerAdvChgMode : KBAdvPacketBase {
    //the trigger advertisement content is same as configruation
    @objc public static let KBTriggerAdvChangeModeDisable = 0

    //the device will change the UUID of iBeacon advertisement when trigger event happened
    @objc public static let KBTriggerAdvChangeModeUUID = 1
}
