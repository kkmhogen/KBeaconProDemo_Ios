//
//  KBAdvPacketSystem.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAdvPacketSystem : KBAdvPacketBase
{
    public static let MIN_ADV_PACKET_LEN = 11;

    @objc public var batteryPercent: UInt8 = 0

    @objc public var firmwareVersion: String = ""

    @objc public var model:UInt8 = 0

    @objc public var macAddress:String?
    
  
    internal required init() {
        super.init()
    }
    
    public override func getAdvType()->Int
    {
        return KBAdvType.System
    }
    
    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index: index)
        
        var nSrvIndex = index

        //model
        model = (data[nSrvIndex] & 0xFF);
        nSrvIndex += 1

        //battery level
        batteryPercent = (data[nSrvIndex] & 0xFF);
        nSrvIndex += 1

        //mac address
        macAddress = String(format:"%02X:%02X:%02X:%02X:%02X:%02X",
                     data[nSrvIndex + 0],
                     data[nSrvIndex + 1],
                     data[nSrvIndex + 2],
                     data[nSrvIndex + 3],
                     data[nSrvIndex + 4],
                     data[nSrvIndex + 5]);
        nSrvIndex += 6;

        //firmware version
        firmwareVersion = String(format:"%d.%d",
                (data[nSrvIndex] & 0xFF),(data[nSrvIndex+1] & 0xFF));
        nSrvIndex += 2;

        return true;
    }
}
