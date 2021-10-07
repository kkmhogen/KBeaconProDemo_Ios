//
//  KBAdvPacketEddyUID.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAdvPacketEddyUID : KBAdvPacketBase
{
    static let MIN_EDDY_UID_ADV_LEN = 19
    
    @objc public var nid : String?
    
    @objc public var sid : String?
    
    //tx power at 0 cent-meter
    @objc public var refTxPower: Int8 = KBCfgBase.INVALID_INT8
    
    internal required init() {
        super.init()
    }
    
    @objc public override func getAdvType()->Int
    {
        return KBAdvType.EddyUID
    }
    
    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index: index)
        
        if (data.count - index < KBAdvPacketEddyUID.MIN_EDDY_UID_ADV_LEN)
        {
            return false;
        }

        //ref tx power
        var nSrvIndex = index
        refTxPower = Int8(bitPattern: data[nSrvIndex])
        nSrvIndex += 1
        
        //nid
        nid = String(format:"0x%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                     data[nSrvIndex + 0],
                     data[nSrvIndex + 1],
                     data[nSrvIndex + 2],
                     data[nSrvIndex + 3],
                     data[nSrvIndex + 4],
                     data[nSrvIndex + 5],
                     data[nSrvIndex + 6],
                     data[nSrvIndex + 7],
                     data[nSrvIndex + 8],
                     data[nSrvIndex + 9]);
        nSrvIndex += 10;

        //sid
        sid = String(format:"0x%02X%02X%02X%02X%02X%02X",
                     data[nSrvIndex + 0],
                     data[nSrvIndex + 1],
                     data[nSrvIndex + 2],
                     data[nSrvIndex + 3],
                     data[nSrvIndex + 4],
                     data[nSrvIndex + 5]);
        
        return true;
    }
}
