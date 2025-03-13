//
//  KBAdvPacketIBeacon.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAdvPacketIBeacon : KBAdvPacketBase
{
    //notify: this is not standard iBeacon protocol, we get major ID from KKM private
    //scan response message
    @objc public var majorID: UInt = KBCfgBase.INVALID_UINT
    
    //get majorID from advertisement packet
    //notify: this is not standard iBeacon protocol, we get minor ID from KKM private
    //scan response message
    @objc public var minorID: UInt = KBCfgBase.INVALID_UINT

    //uuid
    @objc public var uuid: String?

    //ref tx power
    @objc public var refTxPower: Int8 = KBCfgBase.INVALID_INT8
    
    internal required init()
    {
        super.init()
    }
    
    @objc public override func getAdvType()->Int
    {
        return KBAdvType.IBeacon;
    }

    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index: index)
        
        //only advertisement mac address
        if data[index] == 0 {
             return true
        }
        //iBeacon type
        if (data[index] & 0x4) == 0
        {
            return false
        }
        
        if (data.count - index < 5)
        {
            return false
        }
        
        var nStartIndex = index
        nStartIndex += 1
        
        //major id
        majorID = (UInt(data[nStartIndex]) << 8) + UInt(data[nStartIndex+1])
        nStartIndex += 2
        
        //minor id
        minorID = (UInt(data[nStartIndex]) << 8) + UInt(data[nStartIndex + 1])
        
        return true
    }
}
