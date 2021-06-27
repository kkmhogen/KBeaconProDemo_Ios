//
//  KBAdvTxPower.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBAdvTxPower : NSObject
{
    @objc public static let  RADIO_Neg40dBm = Int8(-40)
    @objc public static let  RADIO_Neg20dBm = Int8(-20)
    @objc public static let  RADIO_Neg16dBm = Int8(-16)
    @objc public static let  RADIO_Neg12dBm = Int8(-12)
    @objc public static let  RADIO_Neg8dBm = Int8(-8)
    @objc public static let  RADIO_Neg4dBm = Int8(-4)
    @objc public static let  RADIO_0dBm = Int8(0)
    @objc public static let  RADIO_Pos3dBm = Int8(3)
    @objc public static let  RADIO_Pos4dBm = Int8(4)
    @objc public static let  RADIO_Pos5dBm = Int8(5)
    @objc public static let  RADIO_Pos6dBm = Int8(6)
    @objc public static let  RADIO_Pos7dBm = Int8(7)
    @objc public static let  RADIO_Pos8dBm = Int8(8)
    
    //invalid tx power
    @objc public static let  RADIO_INVALID_TX_POWER = Int8(-100)


    @objc public static let RADIO_TXPOWER_MIN_TXPOWER = Int8(-40)
    @objc public static let RADIO_TXPOWER_MAX_TXPOWER = Int8(8)
}
