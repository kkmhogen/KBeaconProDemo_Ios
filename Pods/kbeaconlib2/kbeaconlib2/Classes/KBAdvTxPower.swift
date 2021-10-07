//
//  KBAdvTxPower.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBAdvTxPower : NSObject
{
    @objc public static let  RADIO_Neg40dBm = Int(-40)
    @objc public static let  RADIO_Neg20dBm = Int(-20)
    @objc public static let  RADIO_Neg16dBm = Int(-16)
    @objc public static let  RADIO_Neg12dBm = Int(-12)
    @objc public static let  RADIO_Neg8dBm = Int(-8)
    @objc public static let  RADIO_Neg4dBm = Int(-4)
    @objc public static let  RADIO_0dBm = Int(0)
    @objc public static let  RADIO_Pos3dBm = Int(3)
    @objc public static let  RADIO_Pos4dBm = Int(4)
    @objc public static let  RADIO_Pos5dBm = Int(5)
    @objc public static let  RADIO_Pos6dBm = Int(6)
    @objc public static let  RADIO_Pos7dBm = Int(7)
    @objc public static let  RADIO_Pos8dBm = Int(8)
    
    //invalid tx power
    @objc public static let  RADIO_INVALID_TX_POWER = Int(-100)


    @objc public static let RADIO_TXPOWER_MIN_TXPOWER = Int(-40)
    @objc public static let RADIO_TXPOWER_MAX_TXPOWER = Int(8)
}
