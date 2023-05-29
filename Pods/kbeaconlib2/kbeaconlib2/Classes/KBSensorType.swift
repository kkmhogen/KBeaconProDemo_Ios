//
//  KBSensorType.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation

@objc public class KBSensorType :NSObject {
    @objc public static let SensorDisable = 0x0
    @objc public static let Acc = 0x1
    @objc public static let HTHumidity = 0x2
    @objc public static let Cutoff = 0x8
    @objc public static let PIR = 0x10
    @objc public static let Light = 0x20
    @objc public static let VOC = 0x40
    @objc public static let CO2 = 0x41
}
