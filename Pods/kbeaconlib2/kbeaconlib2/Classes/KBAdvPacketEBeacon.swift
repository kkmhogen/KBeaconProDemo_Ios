//
//  KBAdvPacketEBeacon.swift
//  KBeaconPro
//
//  Created by hogen hu on 2024/8/29.
//

import UIKit
import CryptoSwift

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
        
        //UUID length 16
        let encrypedUUID = data[nStartIndex..<nStartIndex+16]
        nStartIndex += 16
        let utcData = data[nStartIndex..<nStartIndex+4]
        
        //utc second
        utcSecCount = (UInt32(data[nStartIndex]) << 24) +
            (UInt32(data[nStartIndex+1]) << 16) +
            (UInt32(data[nStartIndex+2]) << 8) +
            UInt32(data[nStartIndex+3])
        nStartIndex += 4
        
        //measure power
        measurePower = Int8(bitPattern: data[nStartIndex])
        
        if let pUuid = peripheralUUID {
            let mPrefCfg = KBPreferance.sharedPreferance
            guard let mac = mPrefCfg.getMacFromUUID(uuid: pUuid) else {
                return false
            }
        
            let password = mPrefCfg.getPassword(pUuid)
            
            var md5KeyData = Data()
         
            var dataPassword =  Data()
            let pwdBytes = password.data(using: .utf8)!
            dataPassword.append(contentsOf: pwdBytes)
            if dataPassword.count < 16 {
                let zeroBytes =  [UInt8](repeating: 0, count: 16 - dataPassword.count)
                dataPassword.append(contentsOf: zeroBytes)
            }
        
            let macHex = mac.replacingOccurrences(of: ":", with: "")
            let dataMac = macHex.hexadecimal

            md5KeyData.append(dataPassword)
            
            md5KeyData.append(dataMac!)
            
            md5KeyData.append(utcData)
            
            //md5 cal
            //Get AEC ECB key by:   MD5(Password + MAC Address + UTC second)
           let  aesKey = MD5().calculate(for: md5KeyData.bytes)
            // decode AES ECB
            do {
                let decrypted = try AES(key: aesKey, blockMode:  ECB(),padding: .noPadding).decrypt(encrypedUUID.bytes)
                uuid = Data(decrypted).toHexString().hexStringToUUID()
                
                return true
            } catch AES.Error.dataPaddingRequired {
                // block size exceeded
            } catch {
                // some error
            }
            
        }
        
        return false
    }
}
