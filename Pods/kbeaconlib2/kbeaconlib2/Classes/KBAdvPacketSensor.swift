//
//  KBAdvPacketSensor.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAdvPacketSensor : KBAdvPacketBase
{
    static let MIN_SENSOR_ADV_LEN = 2
    
    private static let SENSOR_MASK_VOLTAGE = 1
    public static let SENSOR_MASK_TEMP = 2
    public static let SENSOR_MASK_HUME = 4
    public static let SENSOR_MASK_ACC_AIX = 8
    public static let SENSOR_MASK_CUTOFF = 0x10
    public static let SENSOR_MASK_PIR = 0x20
    public static let SENSOR_MASK_LUX = 0x40
    public static let SENSOR_MASK_VOC = 0x80
    public static let SENSOR_MASK_CO2 = 0x200
    public static let SENSOR_MASK_RECORD_NUM = 0x400

    //acceleration sensor data
    @objc public var accSensor: KBAccSensorValue?

    //temperature about sensor
    @objc public var temperature: Float = KBCfgBase.INVALID_FLOAT

    //humidity about sensor
    @objc public var humidity: Float = KBCfgBase.INVALID_FLOAT

    //battery level, uint is mV
    @objc public var batteryLevel: UInt16 = KBCfgBase.INVALID_UINT16
    
    //adv packet version
    @objc public var cutoff: UInt8 = KBCfgBase.INVALID_UINT8
    
    //PIR indication
    @objc public var pirIndication: UInt8 = KBCfgBase.INVALID_UINT8
    
    //Light level
    @objc public var luxLevel: UInt16 = KBCfgBase.INVALID_UINT16
    
    //voc
    @objc public var vocElapseSec: UInt16 = KBCfgBase.INVALID_UINT16
    @objc public var voc: UInt16 = KBCfgBase.INVALID_UINT16
    @objc public var nox: UInt16 = KBCfgBase.INVALID_UINT16

    //co2
    @objc public var co2ElapseSec: UInt16 = KBCfgBase.INVALID_UINT16
    @objc public var co2: UInt16 = KBCfgBase.INVALID_UINT16
    
    //unread count
    @objc public var newTHRecordNum: UInt16 = KBCfgBase.INVALID_UINT16

    internal required init() {
        
        super.init()
    }
    
    @objc public override func getAdvType()->Int
    {
        return KBAdvType.Sensor;
    }
    
    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index: index);
        
        if (data.count < KBAdvPacketSensor.MIN_SENSOR_ADV_LEN)
        {
            return false;
        }
        var nSrvIndex = index;
        
        //sensor mask High byte
        let bySensorMaskHigh = Int(data[nSrvIndex])
        nSrvIndex += 1
                
        //sensor mask
        let bySensorMask = (bySensorMaskHigh << 8) + Int(data[nSrvIndex]);
        nSrvIndex += 1
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_VOLTAGE) > 0)
        {
            if (nSrvIndex > data.count - 2)
            {
                return false;
            }
            
            batteryLevel = UInt16(Int16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex + 1]);
            nSrvIndex += 2
        }
        
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_TEMP) > 0)
        {
            if (nSrvIndex > data.count - 2)
            {
                return false;
            }
            
            let tempHeigh = data[nSrvIndex];
            nSrvIndex += 1
            let tempLow = data[nSrvIndex];
            nSrvIndex += 1
            temperature = KBUtility.signedBytes2Float(byte1: tempHeigh, byte2: tempLow)
        }
        
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_HUME) > 0)
        {
            if (nSrvIndex > data.count - 2)
            {
                return false;
            }
            
            let humHeigh = data[nSrvIndex]
            nSrvIndex += 1
            let humLow = data[nSrvIndex];
            nSrvIndex += 1
            
            humidity = KBUtility.signedBytes2Float(byte1: humHeigh, byte2: humLow)
            
            if humidity < 0 {

                if temperature != KBCfgBase.INVALID_FLOAT {
                    temperature = Float(100 * (-1 - Int(humidity))) + temperature
                }
                humidity = KBCfgBase.INVALID_FLOAT
            }
        }
        else
        {
            humidity = KBCfgBase.INVALID_FLOAT
        }
        
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_ACC_AIX) > 0)
        {
            if (nSrvIndex > data.count - 6)
            {
                return false;
            }
            
            accSensor = KBAccSensorValue()
            let tempXAis = (UInt16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex+1])
            accSensor!.xAis = Int16(bitPattern: tempXAis)
            nSrvIndex += 2
            
            let tempYAis = (UInt16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex+1])
            accSensor!.yAis = Int16(bitPattern: tempYAis)
            nSrvIndex += 2

            let tempZAis = (UInt16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex+1])
            accSensor!.zAis = Int16(bitPattern: tempZAis)
            nSrvIndex += 2
        }
        else
        {
            accSensor = nil
        }
        
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_CUTOFF) > 0)
        {
            if (nSrvIndex > data.count - 1)
            {
                return false;
            }
            
            cutoff = data[nSrvIndex]
            nSrvIndex += 1
        }
        else
        {
            cutoff = KBCfgBase.INVALID_UINT8
        }
        
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_PIR) > 0)
        {
            if (nSrvIndex > data.count - 1)
            {
                return false;
            }
            
            pirIndication = data[nSrvIndex]
            nSrvIndex += 1
        }
        else
        {
            pirIndication = KBCfgBase.INVALID_UINT8
        }
        
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_LUX) > 0)
        {
            if (nSrvIndex > data.count - 2)
            {
                return false;
            }
            
            luxLevel = (UInt16(data[nSrvIndex]) << 8)
            luxLevel += UInt16(data[nSrvIndex+1])
            nSrvIndex += 2
        }
        else
        {
            luxLevel = KBCfgBase.INVALID_UINT16
        }
        
        //get voc value
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_VOC) > 0) {
            if (nSrvIndex > (data.count - 5)) {
                return false;
            }

            vocElapseSec = UInt16(data[nSrvIndex] & 0xFF) * 10;
            nSrvIndex += 1
            
            voc = (UInt16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex+1])
            nSrvIndex += 2

            nox = (UInt16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex+1])
            nSrvIndex += 2
        }
        else
        {
            vocElapseSec = KBCfgBase.INVALID_UINT16
            voc = KBCfgBase.INVALID_UINT16
            nox = KBCfgBase.INVALID_UINT16
            
        }

        //get co2 value
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_CO2) > 0) {
            if (nSrvIndex > (data.count - 3)) {
                return false;
            }

            co2ElapseSec = UInt16(data[nSrvIndex] & 0xFF) * 10;
            nSrvIndex += 1
            
            co2 = (UInt16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex+1])
            nSrvIndex += 2
        }
        else
        {
            co2ElapseSec = KBCfgBase.INVALID_UINT16
            co2 = KBCfgBase.INVALID_UINT16
        }
        
        //record number
        if ((bySensorMask & KBAdvPacketSensor.SENSOR_MASK_RECORD_NUM) > 0) {
            if (nSrvIndex > (data.count - 3)) {
                return false;
            }

            let countMask = UInt16(data[nSrvIndex] & 0xFF);
            nSrvIndex += 1
            
            if ((countMask & 0x1) > 0)
            {
                newTHRecordNum = (UInt16(data[nSrvIndex]) << 8) + UInt16(data[nSrvIndex+1])
            }
            else
            {
                newTHRecordNum = KBCfgBase.INVALID_UINT16
            }
            nSrvIndex += 2
        }
        else
        {
            newTHRecordNum = KBCfgBase.INVALID_UINT16
        }
        
        return true;
    }
}
