//
//  KBAdvPacketEddyTLM.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAdvPacketEddyTLM : KBAdvPacketBase
{
    static let MIN_EDDY_TLM_ADV_LEN = 13
    
    private static let DAYS_SECONDS = Int(3600*24)

    
    //battery level, uint is mV (not percent)
    @objc public var batteryLevel: Int16 = 0

    @objc public var temperature: Float = 0
    
    @objc public var advCount: UInt32 = 0

    @objc public var secCount:UInt32 = 0

    @objc public var tlmVersion:UInt8 = 0
    
    internal required init()
    {
        super.init()
    }
    
    @objc public override func getAdvType()->Int
    {
        return KBAdvType.EddyTLM
    }

    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index: index);
        
        var nSrvIndex = index
        
        if (data.count - index < KBAdvPacketEddyTLM.MIN_EDDY_TLM_ADV_LEN)
        {
            return false
        }
        
        //version
        tlmVersion = data[nSrvIndex]
        nSrvIndex += 1
        
        //battery
        batteryLevel = (Int16(data[nSrvIndex]) << 8) + Int16(data[nSrvIndex+1])
        nSrvIndex += 2
        
        //temputure
        let tempHeigh = Int8(bitPattern:data[nSrvIndex]);
        nSrvIndex += 1
        let tempLow = data[nSrvIndex];
        nSrvIndex += 1
        temperature = KBUtility.signedBytes2Float(byte1: tempHeigh, byte2: tempLow);
        
        //adv count
        advCount = (UInt32(data[nSrvIndex]) << 24) +
            (UInt32(data[nSrvIndex+1]) << 16) +
            (UInt32(data[nSrvIndex+2]) << 8) +
            UInt32(data[nSrvIndex+3])
        nSrvIndex += 4
        
        //sec count
        let count100Ms = (UInt32(data[nSrvIndex]) << 24) +
            (UInt32(data[nSrvIndex+1]) << 16) +
            (UInt32(data[nSrvIndex+2]) << 8) +
            UInt32(data[nSrvIndex+3])
        nSrvIndex += 4
        secCount = UInt32(count100Ms / 10)
        
        return true;
    }
    
    @objc public func getElapseTime()->KBTLMElapseTime
    {
        //days
        let totalSec = Int64(secCount)
        let days = UInt(totalSec / Int64(KBAdvPacketEddyTLM.DAYS_SECONDS))
        let dayRemainSec = Int(totalSec % Int64(KBAdvPacketEddyTLM.DAYS_SECONDS))
        
        //hours
        let hours = UInt(dayRemainSec / 3600)
        let hourRemainSec = (dayRemainSec % 3600);
        
        //minutes
        let minutes = UInt(hourRemainSec / 60);
        
        //seconds
        let second = UInt(hourRemainSec % 60);
        
        return KBTLMElapseTime(days, hour: hours, minute: minutes, second: second)
    }
}
