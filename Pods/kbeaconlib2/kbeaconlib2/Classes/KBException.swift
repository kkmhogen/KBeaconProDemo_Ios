//
//  KBException.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBErrorCode : NSObject
{
    @objc static public let CfgBusy = 0x1
    @objc static public let CfgFailed = 0x2
    @objc static public let CfgTimeout = 0x3
    @objc static public let CfgInputInvalid = 0x4
    @objc static public let CfgReadNull = 0x5
    @objc static public let CfgStateError = 0x6
    @objc static public let CfgNotSupport = 0x8
         
    @objc static public let ParseSensorInfoResponseFailed = 0x501
    @objc static public let ParseSensorDataResponseFailed = 0x502
}


@objc public class KBException : NSObject
{
    @objc public var errorCode : Int
    @objc public var subErrorCode : Int
    @objc public var errorDescription: String

    @objc init(_ cause:Int, desc: String)
    {
        self.errorDescription = desc
        self.errorCode = cause
        self.subErrorCode = 0;
    }

    @objc init(_ cause:Int, subCause:Int, desc:String) {
        self.errorCode = cause
        self.subErrorCode = subCause;
        self.errorDescription = desc;
    }
}
