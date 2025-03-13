//
//  KBAdvPacketBase.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/22.
//

import Foundation
import CommonCrypto

@objc public class KBAdvPacketBase : NSObject
{
    @objc public var name: String?
    
    @objc public var rssi : Int8 = -100
        
    @objc public var connectable: Bool = true
    
    @objc public var lastReceiveTime : TimeInterval
    
    @objc public var peripheralUUID: String?
    
    @objc var mac:String?
    
    @objc var password:String?
    
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
    
    internal func decryptMD5Data(_ index:Int, data:Data, length:Int)->(data:Data,utc:UInt32)?
    {
        var utcSecCount:UInt32
        
        if ((data.count - index >= (4 + length)) || (length % 16 == 0))
        {
            //UUID length 16
            var nStartIndex = index
            let encrypedSensorData = data[nStartIndex..<nStartIndex+length]
            nStartIndex += length
            let utcData = data[nStartIndex..<nStartIndex+4]
            
            //utc second
            utcSecCount = (UInt32(data[nStartIndex]) << 24) +
            (UInt32(data[nStartIndex+1]) << 16) +
            (UInt32(data[nStartIndex+2]) << 8) +
            UInt32(data[nStartIndex+3])
            nStartIndex += 4
            
            if let encPwd = password, let encMac = mac
            {
                var md5KeyData = Data()
                var dataPassword =  Data()
                let pwdBytes = encPwd.data(using: .utf8)!
                dataPassword.append(contentsOf: pwdBytes)
                if dataPassword.count < 16 {
                    let zeroBytes =  [UInt8](repeating: 0, count: 16 - dataPassword.count)
                    dataPassword.append(contentsOf: zeroBytes)
                }
                
                let macHex = encMac.replacingOccurrences(of: ":", with: "")
                let dataMac = macHex.hexadecimal
                
                md5KeyData.append(dataPassword)
                md5KeyData.append(dataMac!)
                md5KeyData.append(utcData)
                
                //md5 cal
                //Get AEC ECB key by:   MD5(Password + MAC Address + UTC second)
                var aesKey = [UInt8](repeating: 0, count: 16)
                
                //md5 calc
                md5KeyData.withUnsafeBytes({ (dataBytes)  in
                    let keyBuffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                    CC_MD5(keyBuffer, CC_LONG(md5KeyData.count), &aesKey)
                })
                
                //decrypt data
                var decryptData = Data(count: encrypedSensorData.count)
                let keyLength              = size_t(kCCKeySizeAES128)
                let operation: CCOperation = UInt32(kCCDecrypt)
                let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
                let options:   CCOptions   = UInt32(kCCOptionECBMode)
                var numBytesEncrypted :size_t = 0
                var cryptStatus :CCCryptorStatus = 0
                
                //decrypt data
                encrypedSensorData.withUnsafeBytes({ (dataBytes)  in
                    let encryptBuffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
                    
                    decryptData.withUnsafeMutableBytes({ (dataBytes)  in
                        let decryptBuffer: UnsafeMutableRawPointer = dataBytes.baseAddress!
                        cryptStatus = CCCrypt(operation,
                                              algoritm,
                                              options,
                                              aesKey,
                                              keyLength,
                                              nil,
                                              encryptBuffer,
                                              encrypedSensorData.count,
                                              decryptBuffer,
                                              encrypedSensorData.count,
                                              &numBytesEncrypted)
                    })
                })
                
                if UInt32(cryptStatus) == UInt32(kCCSuccess)
                {
                    return (decryptData, utcSecCount)
                }
                
                /*
                do {
                    let decrypted = try AES(key: aesKey, blockMode:  ECB(),padding: .noPadding).decrypt(encrypedSensorData.bytes)
                    
                    var hexString = ""
                    for byte in decrypted {
                        hexString += String(format:"%02x", UInt8(byte))
                    }
                    NSLog(hexString);
                    
                    return (Data(decrypted), utcSecCount)
                } catch AES.Error.dataPaddingRequired {
                    // block size exceeded
                } catch {
                    // some error
                }
                */
            }
        }
        
        return nil
    }
}
