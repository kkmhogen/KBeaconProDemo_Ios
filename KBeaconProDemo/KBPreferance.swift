//
//  KBPreferance.swift
//  KBeaconProDemo
//
//  Created by hogen on 2021/6/20.
//

import Foundation
import UIKit

func getString(_ title : String)->String
{
    return NSLocalizedString(title, comment: title)
}

public class KBPreferance
{
    private static let MIN_RSSI_FILTER_KEY = "minRssi"
    private static let BEACON_PWD_KEY_PREFX  = "beaconPwd"
    private static let DEFAULT_PASSWORD = "0000000000000000"
    private static let BEACON_UUID_PREFX = "uuid"

    public static var sharedPreferance = KBPreferance()

    private var mUserPref : UserDefaults
    
    private init()
    {
        mUserPref = UserDefaults.standard
    }
    
    public var rssiFilter:Int{
        get{
            return mUserPref.integer(forKey: KBPreferance.MIN_RSSI_FILTER_KEY)
        }
        set{
            mUserPref.setValue(newValue, forKey: KBPreferance.MIN_RSSI_FILTER_KEY)
            mUserPref.synchronize()
        }
    }
    
    func saveBeaconPassword(_ uuid: String, password:String)
    {
        let key = "\(KBPreferance.BEACON_PWD_KEY_PREFX)\(uuid.lowercased())"
        mUserPref.setValue(password, forKey: key)
        mUserPref.synchronize()
    }
    
    func getBeaconPassword(_ uuid: String)->String
    {
        let strPassword = KBPreferance.DEFAULT_PASSWORD
       
        let key = "\(KBPreferance.BEACON_PWD_KEY_PREFX)\(uuid.lowercased())"
        return mUserPref.string(forKey: key) ?? strPassword
    }
    
    func saveBeaconUUID2Mac(uuid:String, mac:String)
    {
        let key = "\(KBPreferance.BEACON_UUID_PREFX)\(uuid.lowercased())"
        mUserPref.setValue(mac, forKey: key)
    }
    
    func getBeaconMacFromUUID(uuid:String)->String?
    {
        let key = "\(KBPreferance.BEACON_UUID_PREFX)\(uuid.lowercased())"

        return mUserPref.string(forKey: key)
    }
}

