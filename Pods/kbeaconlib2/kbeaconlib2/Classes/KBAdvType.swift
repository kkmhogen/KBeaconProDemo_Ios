//
//  KBAdvType.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAdvType : NSObject
{
    @objc public static let AdvNull = Int(0)
    @objc public static let Sensor = Int(1)
    @objc public static let EddyUID = Int(2)
    @objc public static let EddyTLM = Int(3)
    @objc public static let EddyURL = Int(4)
    @objc public static let IBeacon = Int(5)
    @objc public static let System = Int(6)
    @objc public static let AOA = Int(7)
    @objc public static let EBeacon = Int(8)
    @objc public static let MAXValue = Int()
    
    @objc public static let SensorString = "KSensor"
    @objc public static let EddyUIDString = "UID"
    @objc public static let IBeaconString = "iBeacon"
    @objc public static let EddyTLMString = "TLM"
    @objc public static let EddyURLString = "URL"
    @objc public static let SystemString  = "System"
    @objc public static let AOAString  = "AOA"
    @objc public static let EBeaconString = "EBeacon"
    @objc public static let AdvNullString  = "Disabled"
    
    @objc public static func getAdvTypeString(_ advType:Int)->String
    {
       var strAdv = "";
       switch advType
       {
           case AdvNull:
               strAdv = AdvNullString;
           case Sensor:
               strAdv = SensorString;
           case EddyUID:
               strAdv = EddyUIDString;
           case EddyTLM:
               strAdv = EddyTLMString;
           case EddyURL:
               strAdv = EddyURLString;
           case IBeacon:
               strAdv = IBeaconString;
           case System:
               strAdv = SystemString;
            case AOA:
                strAdv = AOAString;
            case EBeacon:
                strAdv = EBeaconString
           default:
               strAdv = "Unknown";
       }
       return strAdv;
   }
}
