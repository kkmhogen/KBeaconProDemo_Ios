//
//  KBUtility.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/15.
//

import Foundation
import UIKit
import CommonCrypto
import CoreBluetooth

public extension Data {
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
    
    func jsonData2StringWithoutSpaceReturn()->String
    {
        let str = String(data:self, encoding:.utf8)!
        

        return str.replacingOccurrences(of: "\\/", with: "/")
//            .replacingOccurrences(of: " ", with: "")
//            .replacingOccurrences(of: "\n", with: "")
    }
    
    func dataToHexString() -> String {
        if self.count > 0{
            return  "0x"+hexadecimal
        }
        return ""
    }
    
    var bytes: Array<UInt8> {
      Array(self)
    }

    func toHexString() -> String {
      self.bytes.toHexString()
    }
}

extension Array where Element == UInt8 {
  public func toHexString() -> String {
    `lazy`.reduce(into: "") {
      var s = String($1, radix: 16)
      if s.count == 1 {
        s = "0" + s
      }
      $0 += s
    }
  }
}

public extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    func isHexString()->Bool
    {
         let pattern = "([0-9A-Fa-f]{2})+"
         let pattern2 = "^0X|^0x([0-9A-Fa-f]{2})+"
         
         let predicate =  NSPredicate(format: "SELF MATCHES %@", pattern)
         if (!predicate.evaluate(with: self))
         {
            let predicate2 =  NSPredicate(format: "SELF MATCHES %@", pattern2)
            return predicate2.evaluate(with: self)
         }
        
        return false
     }
    
    func isUUIDString()->Bool{
        let pattern = "^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}";
        let predicate =  NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: self);
    }
    
    func toDictionary() -> [String : Any] {
        var result = [String : Any]()
        guard !self.isEmpty else { return result }
        
        guard let dataSelf = self.data(using: .utf8) else {
            return result
        }
        
        if let dic = try? JSONSerialization.jsonObject(with: dataSelf,
                           options: .mutableContainers) ,
           let para = dic as? [String : Any]{
            result = para
        }
        return result
    }
    
    func hexStringToUUID()->String{
        let str = uppercased();
        if (str.count != 32)
        {
            return ""
        }
        
        let startIndex = str.startIndex
        
        let endIndex1 = str.index(startIndex, offsetBy: 7)
        let strUserUUID1 = str[startIndex...endIndex1]
        
        let endIndex2 = str.index(endIndex1, offsetBy: 4)
        let strUserUUID2 = str[str.index(endIndex1, offsetBy: 1)...endIndex2]
        
        let endIndex3 = str.index(endIndex2, offsetBy: 4)
        let strUserUUID3 = str[str.index(endIndex2, offsetBy: 1)...endIndex3]
        
        let endIndex4 = str.index(endIndex3, offsetBy: 4)
        let strUserUUID4 = str[str.index(endIndex3, offsetBy: 1)...endIndex4]

        let endIndex5 = str.index(endIndex4, offsetBy: 12)
        let strUserUUID5 = str[str.index(endIndex4, offsetBy: 1)...endIndex5]

        return "\(strUserUUID1)-\(strUserUUID2)-\(strUserUUID3)-\(strUserUUID4)-\(strUserUUID5)"
    }
    
    subscript (i:Int)->String{
            let startIndex = self.index(self.startIndex, offsetBy: i)
            let endIndex = self.index(startIndex, offsetBy: 1)
            return String(self[startIndex..<endIndex])
        }
    
    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }
    
    // from head to i
    func substring(to:Int) -> String{
        return self[0..<to]
    }
    
    // from i to tail
    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
}

@objc class KBUtility : NSObject
{
    //UUID stone
    @objc public static let PARCE_UUID_EDDYSTONE = CBUUID.init(string: "0000FEAA-0000-1000-8000-00805f9b34fb")
    @objc public static let PARCE_UUID_KB_EXT_DATA = CBUUID.init(string: "00002080-0000-1000-8000-00805f9b34fb")

    //beacon system info
    @objc public static let KB_SYSTEM_SERVICE_UUID = CBUUID.init(string: "0000180a-0000-1000-8000-00805f9b34fb")
    @objc public static let KB_MAC_CHAR_UUID = CBUUID.init(string: "00002a23-0000-1000-8000-00805f9b34fb")
    @objc public static let KB_MODEL_CHAR_UUID = CBUUID.init(string: "00002a24-0000-1000-8000-00805f9b34fb")
    @objc public static let KB_VER_CHAR_UUID = CBUUID.init(string: "00002a26-0000-1000-8000-00805f9b34fb")

    //beacon system info
    @objc public static let KB_CFG_SERVICES_UUID = CBUUID.init(string: "0000FEA0-0000-1000-8000-00805f9b34fb")
    @objc public static let KB_WRITE_CHAR_UUID = CBUUID.init(string: "0000FEA1-0000-1000-8000-00805f9b34fb")
    @objc public static let KB_NTF_CHAR_UUID = CBUUID.init(string: "0000FEA2-0000-1000-8000-00805f9b34fb")
    @objc public static let KB_IND_CHAR_UUID = CBUUID.init(string: "0000FEA3-0000-1000-8000-00805f9b34fb")
    
    @objc static func findService(peripherial: CBPeripheral?, sUUID: CBUUID?) -> CBService? {
        for i in 0..<(peripherial?.services?.count ?? 0) {
            let s = peripherial?.services?[i]
            if s?.uuid == sUUID {
                return s
            }
        }
        return nil
    }

    @objc static func findCharacteristic(cUUID: CBUUID?, service: CBService?) -> CBCharacteristic? {
        for i in 0..<(service?.characteristics?.count ?? 0) {
            let c = service?.characteristics?[i]
            if c?.uuid == cUUID {
                return c
            }
        }
        return nil //Characteristic not found on this service
    }
    
    @objc static func signedBytes2Float(byte1:UInt8, byte2:UInt8)->Float
    {
        
        var combine = (Int(byte1) << 8) + Int(byte2);
        if (combine >= 0x8000)
        {
          combine = combine - 0x10000;
        }
        
        return Float(Double(combine) / 256.0)
    }
}
