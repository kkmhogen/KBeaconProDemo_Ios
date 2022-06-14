//
//  KBTimeRange.swift
//  KBeaconPro
//
//  Created by Shuhui Hu on 2022/6/5.
//

import Foundation

@objc public class KBTimeRange : NSObject
{
    @objc public var localStartHour  : UInt8;
    @objc public var localStartMinute : UInt8;
    @objc public var localEndHour : UInt8;
    @objc public var localEndMinute : UInt8;

    @objc public override required init()
    {
        self.localStartHour = 0
        self.localStartMinute = 0
        self.localEndHour = 0
        self.localEndMinute = 0
        
        super.init()
    }
    
    @objc public init(_ startHour:UInt8, startMinute:UInt8, endHour: UInt8, endMinute: UInt8) {
        self.localStartHour = startHour
        self.localStartMinute = startMinute
        self.localEndHour = endHour
        self.localEndMinute = endMinute
        
        super.init()
    }

    @objc public convenience init(_ utcSecond: UInt32)
    {
        self.init()
        
        self.fromUTCInteger(utcSecond);
    }
    
    @objc public func fromUTCHours(_ startHour:UInt8, startMinute:UInt8, endHour: UInt8, endMinute: UInt8)
    {
        if let localStart = UTCTime.getLocalTimeFromUTC(hour: Int(startHour), minute: Int(startMinute), second: 0)
        {
            self.localStartHour = UInt8(localStart.hour);
            self.localStartMinute = UInt8(localStart.minute);
        }
        
        if let localEnd = UTCTime.getLocalTimeFromUTC(hour: Int(endHour), minute: Int(endMinute), second: 0)
        {
            self.localEndHour = UInt8(localEnd.hour);
            self.localEndMinute = UInt8(localEnd.minute);
        }
    }

    @objc public func fromUTCInteger(_ utcSecond: UInt32)
    {
        let startHour = (UInt8)((utcSecond >> 24) & 0xFF);
        let startMinute = (UInt8)((utcSecond >> 16) & 0xFF);
        let endHour = (UInt8)((utcSecond >> 8) & 0xFF);
        let endMinute = (UInt8)(utcSecond & 0xFF);

        if (startHour == 0 && startMinute == 0 && endHour == 0 && endMinute == 0) {
            self.localStartHour = 0;
            self.localStartMinute = 0;
            self.localEndHour = 0;
            self.localEndMinute = 0;
        } else {
            if let localStart = UTCTime.getLocalTimeFromUTC(hour: Int(startHour), minute: Int(startMinute), second: 0)
            {
                self.localStartHour = UInt8(localStart.hour);
                self.localStartMinute = UInt8(localStart.minute);
            }
            
            if let localEnd = UTCTime.getLocalTimeFromUTC(hour: Int(endHour), minute: Int(endMinute), second: 0)
            {
                self.localEndHour = UInt8(localEnd.hour);
                self.localEndMinute = UInt8(localEnd.minute);
            }
        }
    }

    @objc public func toUTCInteger()->UInt32
    {
        if (!self.isTimeRangeValid())
        {
            return 0;
        }

        if (isTimeRangeDisable())
        {
            return 0;
        }

        var utcSecond : UInt32 = 0
        if let utcStart = UTCTime.getUTCFromLocalTime(hour: Int(localStartHour),
                                                       minute: Int(localStartMinute),
                                                       second: 0)
        {
            utcSecond = UInt32(utcStart.hour)
            utcSecond = (utcSecond << 8)
            utcSecond += UInt32(utcStart.minute)
            utcSecond = (utcSecond << 8);
        }

        if let utcStop = UTCTime.getUTCFromLocalTime(hour: Int(localEndHour), minute: Int(localEndMinute),
                                                      second: 0)
        {
            utcSecond += UInt32(utcStop.hour)
            utcSecond = (utcSecond << 8)
            utcSecond += UInt32(utcStop.minute)
        }

        return utcSecond;
    }

    @objc public func isTimeRangeValid()->Bool
    {
        if (localStartHour > 24 || localStartMinute > 59 || localEndHour > 24 || localEndMinute > 59)
        {
            return false;
        }

        return true;
    }

    @objc public func isTimeRangeDisable()->Bool
    {
        if (localStartHour == 0 && localStartMinute == 0 && localEndHour == 0 && localEndMinute == 0)
        {
            return true;
        }
        return false;
    }

    @objc public func setTimeRangeDisable()
    {
        localStartHour = 0
        localStartMinute = 0
        localEndHour = 0
        localEndMinute = 0
    }

    @objc public func toString()->String
    {
        return String(format: "%02d:%02d ~ %02d:%02d", localStartHour,
                localStartMinute,
                localEndHour,
                localEndMinute);
    }
}
