//
//  UTCTime.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/26.
//

import Foundation

@objc public class UTCTime: NSObject
{
    @objc public var year: Int

    @objc public var day: Int

    @objc public var hour: Int

    @objc public var minute: Int
    
    @objc public var second: Int
    
    @objc override init()
    {
        year = 0
        day = 0
        hour = 0
        minute = 0
        second = 0
    }

    public static func getUTCTimeSecond()->UInt32
    {
        return UInt32(Date().timeIntervalSince1970)
    }

    public static func getLocalTimeFromUTC(hour:Int, minute:Int, second:Int)->UTCTime?
    {
        let utcTimeStr = String(format: "2000-01-01 %02d:%02d:%02d", hour, minute, second)
        
        let utcFormat = DateFormatter()
        utcFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        utcFormat.timeZone = TimeZone(abbreviation: "UTC")
        guard let utcDate = utcFormat.date(from: utcTimeStr) else{
            return nil
        }
        
        let formatLocal = DateFormatter()
        formatLocal.dateFormat = "HH:mm:ss";
        formatLocal.timeZone = TimeZone.current
        let dateString = formatLocal.string(from: utcDate)
        
        let utcTime = UTCTime()
        let arr = dateString.components(separatedBy: ":")
        if arr.count == 3
        {
            utcTime.hour = Int(arr[0]) ?? 0
            utcTime.minute = Int(arr[1]) ?? 0
            utcTime.second = Int(arr[2]) ?? 0
        }
        
        return utcTime;
    }

    @discardableResult public static func getUTCFromLocalTime(hour : Int, minute:Int, second:Int)->UTCTime?
    {
        let dateFormatLocal = DateFormatter()
        dateFormatLocal.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let strLocalDate = String(format:"2000-01-01 %02d:%02d:%02d",
                               hour,
                               minute,
                               second);
        guard let dateLocal = dateFormatLocal.date(from: strLocalDate) else{
            return nil
        }
        
        let dateFormatUtc = DateFormatter()
        dateFormatUtc.dateFormat = "HH:mm:ss"
        dateFormatUtc.timeZone = TimeZone(abbreviation: "UTC")
        
        let dateString = dateFormatUtc.string(from: dateLocal)
        let utcTime = UTCTime()
        let arr = dateString.components(separatedBy: ":")
        if (arr.count == 3)
        {
            utcTime.hour = Int(arr[0]) ?? 0
            utcTime.minute = Int(arr[1]) ?? 0
            utcTime.second = Int(arr[2]) ?? 0
        }
        
        return utcTime
    }
    
    public static func localTimeFromUTCSeconds(_ utcSecond : UInt32)->String
    {
        let date = Date(timeIntervalSince1970: Double(utcSecond))
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        return dateString
    }
}
