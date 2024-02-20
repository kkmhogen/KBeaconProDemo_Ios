//
//  KBAdvPacketAOA.swift
//  KBeaconPro
//
//  Created by hogen hu on 2023/11/17.
//

import Foundation

//connect status
@objc public enum KBAOAChannel:Int
{
    case CHANNEL_37 = 1
    case CHANNEL_38 = 2
    case CHANNEL_39 = 3
}

extension KBAOAChannel {
    var title: String {
        switch self {
        case .CHANNEL_37:
            return "37"
        case .CHANNEL_38:
            return "38"
        case .CHANNEL_39:
            return "39"
        }
    }
}

@objc public class KBAdvPacketAOA : KBAdvPacketBase
{
    public static let AOA_MASK_ACC_AIX:UInt8 = 0x8
    
    //scan response message
     public var channel: KBAOAChannel?

    public var txPower: Int?
    
     public var  battery: Int?//百分比
    
     public var freq: Double?
    
    //acceleration sensor data
    private var accSensor: KBAccAOAValue?
    
    private static let txPowerArray = [0,3,4,-40,-20,-16,-12,-8,-4,-30]
    
    private static let freqDict = [0x7E:300,0x6A:100,0x65:50,0x5E:30,0x54:20,0x4A:10,0x49:9,0x48:8,0x47:7,0x46:6,0x45:5,0x44:4,0x43:3,0x42:2,0x41:1,0x2:0.5,0x5:0.2,0xA:0.1,0x14:0.05,0x25:0.02,0x2A:0.01]

    internal required init()
    {
        super.init()
    }
    
    @objc public override func getAdvType()->Int
    {
        return KBAdvType.AOA;
    }
    
    public func isAccSupport()->Bool {
        return accSensor != nil
    }
    
    public func getAccSensor() ->KBAccAOAValue?
    {
        return accSensor
    }

    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index: index)
        
        if (data.count - index < 3)
        {
            return false;
        }
        var nSrvIndex = index
        //命令字 , 默认为A0 (使用标准SDK,不开启接收窗口)
        let bySensorMask = data[nSrvIndex]
        nSrvIndex += 1
        if (bySensorMask & KBAdvPacketAOA.AOA_MASK_ACC_AIX) > 0
        {
            accSensor = KBAccAOAValue()
            accSensor!.xAis = Int8(bitPattern: data[nSrvIndex])
            nSrvIndex += 1
            
            accSensor!.yAis = Int8(bitPattern: data[nSrvIndex])
            nSrvIndex += 1

            accSensor!.zAis = Int8(bitPattern: data[nSrvIndex])
            
//           print(String(format:"x:%d;y:%d;z:%d",
//                        accSensor!.xAis,
//                        accSensor!.yAis,
//                        accSensor!.zAis))
            return true
        }
        //数据内容1
        //[0:2]bit 发射信道  , 000 2401 MHZ , 001 2402 MHZ , 010 2426 MHZ , 011 2480 MHZ , 100 2481 MHZ , 标准SDK仅支持 2402,2426,2480三个信道 对应 37,38,39三个信道
//        CHANNEL_37         = 0x1 ,
//        CHANNEL_38        = 0x2 ,
//        CHANNEL_39        = 0x3 ,
        //[3]bit 是否开启接收模式 , 1 --上电开启接收模式 , 0 --上电没有开启接收模式
        //[4:7] 发射功率  , 0 0dBm , 1 3dBm , 2 4dBm , 3 -40dBm , 4 -20dBm , 5 -16dBm , 6 -12dBm , 7 -8dBm , 8 -4dBm , 9 -30dBm //Nordic
        
        //数据内容2
        //[4:7]  : 电池电量单位百分比 ,范围 0-10
        
        //数据内容3
        //bit[0:6] : 发射频率
        
        let firstData = UInt8(data[nSrvIndex])
        nSrvIndex += 1
        //battery level
        //取低3位 0111
        let channelValue = Int(firstData & 0x7)
        channel = KBAOAChannel(rawValue: channelValue)
        
        let txPowerKey = Int(firstData >> 4)
        if txPowerKey < KBAdvPacketAOA.txPowerArray.count {
            txPower = KBAdvPacketAOA.txPowerArray[txPowerKey]
        }
     
        let secondData = data[nSrvIndex]
        nSrvIndex += 1;
        let batteryKey = Int(secondData >> 4)
        battery = batteryKey * 10//1-10百分比
   
        let thirdData = Int(data[nSrvIndex])
        freq = KBAdvPacketAOA.freqDict[thirdData]
        return true;
    }
}
