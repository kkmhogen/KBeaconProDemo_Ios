//
//  KBException.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBErrorCode : NSObject
{
    //last action does not complete
    @objc static public let CfgBusy = 0x1
    
    //the device return fail
    @objc static public let CfgFailed = 0x2
    
    //send configruation to device timeout
    @objc static public let CfgTimeout = 0x3
    
    //input parameters invalid
    @objc static public let CfgInputInvalid = 0x4
    
    //read data is null
    @objc static public let CfgReadNull = 0x5
    
    //device state error, maybe device was disconnected
    @objc static public let CfgStateError = 0x6
    
    //device does not support the notification
    @objc static public let CfgNotSupport = 0x8
     
    @objc static public let ParseSensorInfoResponseFailed = 0x501
    @objc static public let ParseSensorDataResponseFailed = 0x502

    @objc static public let CfgSubErrorAuthNotSupport = 0x102

    //the input parameters was invalid
    @objc static public let CfgSubErrorInputParaInvalid = 0x103

    //the device does not support this feature
    @objc static public let CfgSubErrorFeatureUnSupport = 0x104

    //parse json message failed
    @objc static public let CfgSubErrorParseJsonFail = 0x105

    //Some required parameters do not exist
    @objc static public let CfgSubErrorParaNotExist = 0x106

    //Command execute failed
    @objc static public let CfgSubErrorCmdExeFailed = 0x107

    //the advertisement slot triggered by Trigger does not exist
    @objc static public let CfgSubErrorSlotParaNotExist = 0x108

    //the advertisement slot was used by trigger, and not allowed remove,
    //please remove the trigger first
    @objc static public let CfgSubErrorSlotUsedByTrigger = 0x109

    //This type advertisement can only be single instance
    @objc static public let CfgSubErrorAdvTypeDuplicate = 0x110

    //the trigger was already enable
    @objc static public let CfgSubErrorTriggerTypeDuplicate = 0x111

    //the request record No does not exist
    @objc static public let CfgSubErrorRecordNotExist = 0x131

    //enable sensor failed
    @objc static public let CfgSubErrorEnableSensorFailed = 0x135
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
