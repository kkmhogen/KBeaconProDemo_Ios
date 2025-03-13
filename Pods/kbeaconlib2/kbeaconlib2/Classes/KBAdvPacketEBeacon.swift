//
//  KBAdvPacketEBeacon.swift
//  KBeaconPro
//
//  Created by hogen hu on 2024/8/29.
//

import UIKit

@objc public class KBAdvPacketEBeacon : KBAdvPacketBase
{
    //uuid
    @objc public var uuid: String?
    
    //ref tx power
    @objc public var utcSecCount:UInt32 = 0
    
    @objc public var measurePower:Int8 = -59
    
    internal required init()
    {
        super.init()
    }
    
    @objc public override func getAdvType()->Int
    {
        return KBAdvType.EBeacon;
    }

    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index: index)
        
        var nStartIndex = index
        
        //check remain data length
        if (data.count - index < 21)
        {
            return false
        }
        
        //remain length
        let length = data[nStartIndex]
        nStartIndex += 1
        if (data.count - nStartIndex != length)
        {
            return false;
        }
        
        //decrypt UUID
        if let decryptData = decryptMD5Data(nStartIndex, data: data, length: 16)
        {
            uuid = Data(decryptData.data).toHexString().hexStringToUUID()
            utcSecCount = decryptData.utc
            nStartIndex += 20
        }
        else
        {
            return false
        }
        
        //measure power
        measurePower = Int8(bitPattern: data[nStartIndex])
        
        return true
    }
}
