//
//  KBAdvPacketHandler.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation
import CoreBluetooth

internal class KBAdvPacketHandler : NSObject
{
    internal var mAdvPackets = [Int:KBAdvPacketBase]()
    
    //filter adv type
    internal var filterAdvType: Int?
    
    internal var batteryPercent:UInt8?
    {
        get{
            if rawBatteryPercent != nil
            {
                return rawBatteryPercent!
            }
            else if let sysAdv = getAdvPacket(KBAdvType.System) as? KBAdvPacketSystem
            {
                return sysAdv.batteryPercent
            }
            return nil
        }
    }
    
    //battery percent
    private var rawBatteryPercent:UInt8?
    
    private static var kbAdvPacketTypeObjects = [
        Int(KBAdvType.EddyTLM):KBAdvPacketEddyTLM.self,
        Int(KBAdvType.EddyUID): KBAdvPacketEddyUID.self,
        Int(KBAdvType.EddyURL): KBAdvPacketEddyURL.self,
        Int(KBAdvType.IBeacon): KBAdvPacketIBeacon.self,
        Int(KBAdvType.Sensor): KBAdvPacketSensor.self,
        Int(KBAdvType.System): KBAdvPacketSystem.self,
        Int(KBAdvType.AOA):KBAdvPacketAOA.self
        ]
    
    internal override init()
    {
        
    }
    
    internal static func createAdvPacketByType(_ type:Int)->KBAdvPacketBase?
    {
        if let instance = kbAdvPacketTypeObjects[type]{
            return instance.init()
        }
        else
        {
            return nil
        }
    }
    
    internal func getAdvPacket(_ advType:Int)->KBAdvPacketBase?
    {
        for (_,advPacket) in mAdvPackets{
            if advPacket.getAdvType() == advType{
                return advPacket
            }
        }
        return nil
    }
    
    internal func removeAdvPacket()
    {
        self.mAdvPackets.removeAll()
    }

    internal func parseAdvPacket(_ advData: [String:Any], rssi: Int8)->Bool
    {
        var bParseDataRslt : Bool = false;
        var deviceName: String?
        var pAdvData: Data?
        
        //device name
        deviceName = advData["kCBAdvDataLocalName"] as? String
        

        //is connectable
        guard let advConnable = advData["kCBAdvDataIsConnectable"] as? NSNumber else{
            return false;
        }
        
        var advType = KBAdvType.AdvNull
        var advDataIndex = 0
        
        //get manufacture
        if let kkmManufactureData = advData["kCBAdvDataManufacturerData"] as? Data,
           kkmManufactureData.count > 3
        {
            if kkmManufactureData[0] == 0x53, kkmManufactureData[1] == 0x0A {
                if (kkmManufactureData[2] == 0x21
                            && kkmManufactureData.count >= KBAdvPacketSensor.MIN_SENSOR_ADV_LEN)
                {
                    advType = KBAdvType.Sensor;
                }
                else if (kkmManufactureData[2] == 0x22
                            && kkmManufactureData.count >= KBAdvPacketSystem.MIN_ADV_PACKET_LEN)
                {
                    advType = KBAdvType.System;
                }else if  kkmManufactureData[2] == 0x04 {
                    advType = KBAdvType.AOA
                }
            }else if kkmManufactureData[0] == 0x0D, kkmManufactureData[1] == 0x00  {
                if  kkmManufactureData[2] == 0x04 {
                    advType = KBAdvType.AOA
                }
            }
            advDataIndex = 3
            pAdvData = kkmManufactureData
        }
        
        //get google services data
        if let kbServiceData = advData["kCBAdvDataServiceData"] as? Dictionary<CBUUID, NSData>
        {
            //check if include eddystone data
            if let eddyAdvData = kbServiceData[KBUtility.PARCE_UUID_EDDYSTONE] as Data?,
               eddyAdvData.count > 1
            {
                //eddytone url adv
                if (eddyAdvData[0] == 0x10
                        && eddyAdvData.count >= KBAdvPacketEddyURL.MIN_EDDYSTONE_ADV_LEN)
                {
                    advType = KBAdvType.EddyURL;
                }
                //eddystone uid adv
                else if (eddyAdvData[0] == 0x0
                            && eddyAdvData.count >= KBAdvPacketEddyUID.MIN_EDDY_UID_ADV_LEN)
                {
                    advType = KBAdvType.EddyUID;
                }
                //eddystone tlm adv
                else if (eddyAdvData[0] == 0x20
                            && eddyAdvData.count >= KBAdvPacketEddyTLM.MIN_EDDY_TLM_ADV_LEN)
                {
                    advType = KBAdvType.EddyTLM;
                }
                else if (eddyAdvData[0] == 0x21
                            && eddyAdvData.count >= KBAdvPacketSensor.MIN_SENSOR_ADV_LEN)
                {
                    advType = KBAdvType.Sensor;
                }
                else if (eddyAdvData[0] == 0x22
                            && eddyAdvData.count >= KBAdvPacketSystem.MIN_ADV_PACKET_LEN)
                {
                    advType = KBAdvType.System;
                }
                else
                {
                    advType = KBAdvType.AdvNull;
                }
                
                advDataIndex = 1
                pAdvData = eddyAdvData
            }
            
            if let kbResponseData = kbServiceData[KBUtility.PARCE_UUID_KB_EXT_DATA] as Data?
               , kbResponseData.count >= 6
            {
                var nBattPercent = kbResponseData[0];
                if (nBattPercent > 100)
                {
                    nBattPercent = 100;
                }
                rawBatteryPercent = nBattPercent
                
                
                //beacon extend data
                let beaconType = Int(kbResponseData[1])
                if ((beaconType & 0x4) > 0
                        && advType == KBAdvType.AdvNull)
                {
                    //find ibeacon instance
                    advType = KBAdvType.IBeacon;
                    pAdvData = kbResponseData
                    advDataIndex = 1
                }
            }
        }
        
        //check filter
        if let nFilterAdvType = filterAdvType,
           (advType & nFilterAdvType == 0)
        {
            return false;
        }
        
        //parse data
        if let advData = pAdvData,
            advType != KBAdvType.AdvNull
        {
            var advPacket = mAdvPackets[advType]
            if (advPacket == nil)
            {
                advPacket = KBAdvPacketHandler.createAdvPacketByType(advType)
                mAdvPackets[advType] = advPacket
            }

            //check if parse advertisment packet success
            if (advPacket!.parseAdvPacket(advData, index: advDataIndex))
            {
                advPacket!.updateBasicInfo(deviceName,
                                          rssi: rssi,
                                          isConnect: advConnable.boolValue)
                bParseDataRslt = true;
                
            }
        }
        
        return bParseDataRslt;
    }
}
