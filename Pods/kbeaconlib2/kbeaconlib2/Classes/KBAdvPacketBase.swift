//
//  KBAdvPacketBase.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/22.
//

import Foundation

@objc public class KBAdvPacketBase : NSObject
{
    @objc public var name: String?
    
    @objc public var rssi : Int8 = -100
        
    @objc public var connectable: Bool = true
    
    @objc public var lastReceiveTime : TimeInterval
    
    @objc public var peripheralUUID: String?

    private var advType: Int
    
    internal required override init()
    {
        lastReceiveTime = 0
        advType = Int(KBAdvType.AdvNull)
        
        super.init()
    }
    
    @objc public func getAdvType()->Int
    {
        return advType
    }

    @discardableResult internal func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        return true
    }

    internal func updateBasicInfo(_ name:String?, rssi:Int8, isConnect:Bool, peripheralUUID:String?)
    {
        self.name = name
        self.rssi = rssi
        self.connectable = isConnect
        self.lastReceiveTime = NSDate().timeIntervalSince1970
        self.peripheralUUID = peripheralUUID
    }
}
