//
//  KBPreferance.swift
//  KBeaconProDemo
//
//  Created by hogen on 2021/6/10.
//

import Foundation
import UIKit

class KBPreferance
{
    private static let BEACON_PWD_KEY_PREFX  = "beaconPwd"
    private static let DEFAULT_PASSWORD = "0000000000000000"
    private static let BEACON_UUID_PREFX = "kb_"

    public static var sharedPreferance = KBPreferance()

    private var mUserPref : UserDefaults
    
    private init()
    {
        mUserPref = UserDefaults.standard
    }
    
    func savePassword(_ uuid: String, password:String)
    {
        let key = "\(KBPreferance.BEACON_PWD_KEY_PREFX)\(uuid.lowercased())"
        mUserPref.setValue(password, forKey: key)
        mUserPref.synchronize()
    }
    
    func getPassword(_ uuid: String)->String
    {
        let strPassword = KBPreferance.DEFAULT_PASSWORD
       
        let key = "\(KBPreferance.BEACON_PWD_KEY_PREFX)\(uuid.lowercased())"
        return mUserPref.string(forKey: key) ?? strPassword
    }
    
    func saveUUID2Mac(uuid:String, mac:String)
    {
        let key = "\(KBPreferance.BEACON_UUID_PREFX)\(uuid)"
        mUserPref.setValue(mac, forKey: key)
    }
    
    func getMacFromUUID(uuid:String)->String?
    {
        let key = "\(KBPreferance.BEACON_UUID_PREFX)\(uuid)"

        return mUserPref.string(forKey: key)
    }
}
