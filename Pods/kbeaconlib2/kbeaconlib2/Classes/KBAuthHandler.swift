//
//  KBAuthHandler.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/27.
//

import Foundation
import CommonCrypto

@objc public enum KBAuthResult:Int
{
    case Failed = 0
    case Success = 1
}

internal protocol KBAuthDelegate : NSObjectProtocol
{
    func authStateChange(_ authRslt:KBAuthResult)

    func writeAuthData(_ data: Data)
}

internal class KBAuthHandler : NSObject
{
    public static let KBAuthFailed = 1;
    public static let KBAuthSuccess = 0;

    private static let MTU_SIZE_HEAD = 0x3;
    private static let BLE4_MTU_SIZE = 23;

    private static let AUTH_PHASE1_APP = 0x1;
    private static let AUTH_PHASE2_DEV = 0x2;
    private static let AUTH_MIN_MTU_ALOGRIM_PH1 = 11;
    private static let AUTH_MIN_MTU_SIMP_ALOGRIM_PH2 = 12;
    private static let AUTH_RETURN_FAIL = 0xF1;

    private static let AUTH_PASSWORD_LEN = 16;
    private static let AUTH_FACTOR_ID_1 = 0xA9;
    private static let AUTH_FACTOR_ID_2 = 0xB1;
  
    internal let DEFAULT_PASSWORD = "0000000000000000"

    internal var connPara : KBConnPara

    internal weak var authDelegate: KBAuthDelegate?
    
    internal var mtuSize : Int
    
    internal var macAddress: String
    
    internal var password : String

    private var mAuthPhase1AppRandom: Int

    internal init(password:String,
                connPara:KBConnPara,
                delegate: KBAuthDelegate) {
        self.mtuSize = KBAuthHandler.BLE4_MTU_SIZE - KBAuthHandler.MTU_SIZE_HEAD;
        self.authDelegate = delegate
        self.password = password
        self.connPara = connPara
        self.macAddress = ""
        self.mAuthPhase1AppRandom = 0
    }

    internal func getMtuSize()->Int
    {
        return mtuSize
    }

    //send md5 requet
    @discardableResult internal func authSendMd5Request(mac:String)->Bool
    {
        macAddress = mac.replacingOccurrences(of: ":", with: "")
        guard let macData = macAddress.hexadecimal,
              macData.count == 6,
              password.count >= 8 && password.count <= 16 else
        {
            NSLog("mac address or password length failed")
            return false
        }
        
        var authRequest = Data();

        //head
        authRequest.append(UInt8(0x13))
        authRequest.append(UInt8(KBAuthHandler.AUTH_PHASE1_APP))

        //random
        mAuthPhase1AppRandom = Int(arc4random())
        authRequest.append(UInt8((mAuthPhase1AppRandom >> 24) & 0xFF))
        authRequest.append(UInt8((mAuthPhase1AppRandom >> 16) & 0xFF))
        authRequest.append(UInt8((mAuthPhase1AppRandom >> 8) & 0xFF))
        authRequest.append(UInt8((mAuthPhase1AppRandom & 0xFF)))

        //add para
        if (connPara.syncUtcTime)
        {
            let utcTime = UTCTime.getUTCTimeSecond()
            authRequest.append(UInt8((utcTime >> 24) & 0xFF))
            authRequest.append(UInt8((utcTime >> 16) & 0xFF))
            authRequest.append(UInt8((utcTime >> 8) & 0xFF))
            authRequest.append(UInt8((utcTime & 0xFF)))
        }
        
        //set data;
        authDelegate?.writeAuthData(authRequest)
        return true;
    }

    internal func authHandleResponse(data:Data, index:Int)
    {
        var dataIndex = index
        let authDataLen = data.count - index
        if (authDataLen < 1)
        {
            print("auth with device \(self.macAddress) receive invalid length response")
            self.authDelegate?.authStateChange(KBAuthResult.Failed)
            return
        }
        
        let authType = data[dataIndex]
        dataIndex += 1
        
        if (authType == KBAuthHandler.AUTH_PHASE1_APP || authType == KBAuthHandler.AUTH_MIN_MTU_ALOGRIM_PH1)
        {
            if (!self.authHandlePhase1Response(data: data,
                                          index: dataIndex,
                                          isShortMTU: (authType == KBAuthHandler.AUTH_MIN_MTU_ALOGRIM_PH1)))
            {
                print("auth with device \(self.macAddress) in phase1 response failed\n")
                self.authDelegate?.authStateChange(KBAuthResult.Failed)
            }
        }
        else if (authType == KBAuthHandler.AUTH_PHASE2_DEV)
        {
            if (authDataLen >= 2)
            {
                self.mtuSize = Int(data[dataIndex]) - KBAuthHandler.MTU_SIZE_HEAD
                dataIndex += 1
            }
            
            NSLog("Device\(self.macAddress) auth success, mtu:\(self.mtuSize)")
            self.authDelegate?.authStateChange(KBAuthResult.Success)
        }
        else if (authType == 0xF1)
        {
            print("auth with device \(self.macAddress) in phase2 response failed\n")
            self.authDelegate?.authStateChange(KBAuthResult.Failed)
        }
    }

    internal func authHandlePhase1Response(data:Data, index:Int, isShortMTU:Bool)->Bool
    {
        var readIndex = index
        let authDataLen = data.count - index
        var auth1AppMd5Data = Data()
        var byAuth1AppMd5Result = [UInt8](repeating: 0, count: 16)
        var auth2DevMd5Data = Data()
        var byAuth2DevMd5Result = [UInt8](repeating: 0, count: 16)
        
        //check input valid
        if (isShortMTU)
        {
            if (authDataLen < 12)
            {
                return false;
            }
        }else{
            if (authDataLen < 20)
            {
                return false;
            }
        }
        if (authDataLen < 4)
        {
            NSLog("data is null")
            return false
        }
        
        //get random
        let dataRandom = data.subdata(in: readIndex..<(readIndex + 4))
        readIndex += 4
        
        let dataPassword = password.data(using: .utf8)
        let dataMac = macAddress.hexadecimal
        
        //verify auth value
        var bleMacAddr = Data()
        bleMacAddr.append(dataMac![5])
        bleMacAddr.append(dataMac![4])
        bleMacAddr.append(dataMac![3])
        bleMacAddr.append(dataMac![2])
        bleMacAddr.append(dataMac![1])
        bleMacAddr.append(dataMac![0])
        auth1AppMd5Data.append(bleMacAddr)
        
        //factor
        auth1AppMd5Data.append(UInt8(KBAuthHandler.AUTH_FACTOR_ID_1))
        auth1AppMd5Data.append(UInt8(KBAuthHandler.AUTH_FACTOR_ID_2))

        //random
        auth1AppMd5Data.append(UInt8((mAuthPhase1AppRandom >> 24) & 0xFF))
        auth1AppMd5Data.append(UInt8((mAuthPhase1AppRandom >> 16) & 0xFF))
        auth1AppMd5Data.append(UInt8((mAuthPhase1AppRandom >> 8) & 0xFF))
        auth1AppMd5Data.append(UInt8((mAuthPhase1AppRandom & 0xFF)))

        //password
        auth1AppMd5Data.append(dataPassword!)

        //md5 calc
        auth1AppMd5Data.withUnsafeBytes({ (dataBytes)  in
            let buffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
            CC_MD5(buffer, CC_LONG(auth1AppMd5Data.count), &byAuth1AppMd5Result)
        })
        
        if (isShortMTU)
        {
            var byShortMd5Result = [UInt8](repeating: 0, count: 8)
            for i in 0 ..< 8
            {
                byShortMd5Result[i] = UInt8((byAuth1AppMd5Result[i] ^ byAuth1AppMd5Result[8+i]) & 0xFF)
            }
            
            for i in 0 ..< 8
            {
                if (byShortMd5Result[i] != data[readIndex + i])
                {
                    return false
                }
            }
            readIndex += 8
        }
        else
        {
            for i in 0 ..< 16
            {
                if (byAuth1AppMd5Result[i] != data[readIndex + i])
                {
                    return false
                }
            }
            readIndex += 16
        }
        
        //get auth2 md5 value
        auth2DevMd5Data.append(bleMacAddr)
        
        //factor
        auth2DevMd5Data.append(UInt8(KBAuthHandler.AUTH_FACTOR_ID_1))
        auth2DevMd5Data.append(UInt8(KBAuthHandler.AUTH_FACTOR_ID_2))
        
        //random
        auth2DevMd5Data.append(dataRandom)
        
        //password
        auth2DevMd5Data.append(dataPassword!)
        
        //result 2
        auth2DevMd5Data.withUnsafeBytes({ (dataBytes)  in
            let buffer: UnsafePointer<UInt8> = dataBytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
            CC_MD5(buffer, CC_LONG(auth2DevMd5Data.count), &byAuth2DevMd5Result)
        })
        
        //send auth2 md5 response
        var authRequest = Data()
        authRequest.append(0x13)
        //NSData *nsWriteData;
        if (isShortMTU)
        {
            authRequest.append(UInt8(KBAuthHandler.AUTH_MIN_MTU_SIMP_ALOGRIM_PH2))
            for i in 0 ..< 8
            {
                let result = UInt8(byAuth2DevMd5Result[i] ^ byAuth2DevMd5Result[i + 8])
                authRequest.append(result)
            }
        }
        else
        {
            authRequest.append(UInt8(KBAuthHandler.AUTH_PHASE2_DEV))
            for i in 0 ..< 16
            {
                authRequest.append(UInt8(byAuth2DevMd5Result[i]))
            }
        }
        
        self.authDelegate?.writeAuthData(authRequest)
        
        return true
    }
}
