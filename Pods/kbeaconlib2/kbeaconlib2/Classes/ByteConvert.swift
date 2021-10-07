//
//  ByteConvert.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/26.
//

import Foundation

@objc public class ByteConvert : NSObject
{
    @objc public static func shortToBytes(value:UInt16) ->[UInt8]
    {
        var b: [UInt8] = [UInt8](arrayLiteral: 2)
        
        b[1] = UInt8( value       & 0xff);
        b[0] = UInt8((value >> 8) & 0xff);
        return b;
    }

    @objc public static func bytesToShort(value: Data, offset:Int)->UInt16
    {
        var nData = UInt16(value[offset] & 0xFF);
        nData = nData << 8;
        nData += UInt16(value[offset + 1] & 0xFF);
        
        return nData
    }
    
    @objc public static func bytesTo4Long(value: Data, offset:Int)->UInt32
    {
        var nData = UInt32(value[offset] & 0xFF);
        nData = nData << 8;
        nData += UInt32(value[offset + 1] & 0xFF);
        nData = nData << 8;
        nData += UInt32(value[offset + 2] & 0xFF);
        nData = nData << 8;
        nData += UInt32(value[offset + 3] & 0xFF);

        return nData;
    }
}

