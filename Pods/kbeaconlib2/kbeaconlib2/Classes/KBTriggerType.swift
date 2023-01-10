//
//  KBTriggerType.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/25.
//

import Foundation

@objc public class KBTriggerType : NSObject
{

    @objc public static let TriggerNull = 0

    //motion sensor trigger
    @objc public static let AccMotion = 1

    //push button trigger
    @objc public static let BtnLongPress = 3   //long press
    @objc public static let BtnSingleClick = 4   //single tap
    @objc public static let BtnDoubleClick = 5   //double tap
    @objc public static let BtnTripleClick = 6   //triple tap
    
    //cut off watchband
    @objc public static let Cutoff = 7   //cutoff watch band

    //temp and humidity trigger
    @objc public static let HTTempAbove = 8   //temperature above
    @objc public static let HTTempBelow = 9   //temperature below
    @objc public static let HTHumidityAbove = 10   //humidity above
    @objc public static let HTHumidityBelow = 11   //humidity below
    @objc public static let HTHumidityPeriodically = 12   //periodically report

    //PIR indication
    @objc public static let PIRBodyInfraredDetected = 13
    
    //Light lux level
    @objc public static let LightLUXAbove = 14   //light lux above
    @objc public static let LightLUXBelow = 15   //light lux below
}
