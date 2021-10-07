//
//  TLMElapseTime.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBTLMElapseTime : NSObject
{
    @objc public var days: UInt
    @objc public var hours: UInt
    @objc public var minutes: UInt
    @objc public var seconds: UInt
    
    @objc public init(_ day:UInt, hour:UInt, minute:UInt, second:UInt)
    {
        self.days = day
        self.hours = hour
        self.minutes = minute
        self.seconds = second
    }
}
