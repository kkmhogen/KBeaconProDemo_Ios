//
//  KBCfgAdvAOA.swift
//  KBeaconPro
//
//  Created by hogen hu on 2023/11/17.
//

import Foundation

@objc public class KBCfgAdvAOA : KBCfgAdvBase
{
    @objc public static let JSON_FIELD_AOA_TYPE  = "aoa"
    @objc public static let JSON_FIELD_AOA_AXIS = "axis"
    @objc public static let JSON_FIELD_AOA_SYS_ADV_INTERVAL = "aItvl"
    @objc public static let FIELD_AOA_MAXInterval = 255
    //
    private var type : Int?
    
    private var axisSupport : Bool?
    
    //the beacon will advertisement system info(acc,version)
    // every sysAdvInterval when broadcasting AOA advertisement
    private var sysAdvInterval : Int?

    @objc public required init()
    {
        super.init(advType: KBAdvType.AOA);
    }

    public func getType()->Int?
    {
        return type;
    }
    
    public func setType(_ type: Int)
    {
        self.type = type
    }
    
    public func setAxisSupport(_ axis: Bool)
    {
        self.axisSupport = axis
    }
    
    public func getAxisSupport()->Bool
    {
        return axisSupport == true
    }

    public func setSysAdvInterval(_ aItvl: Int)
    {
        self.sysAdvInterval = aItvl
    }
    
    public func getSysAdvInterval()->Int?
    {
        return sysAdvInterval
    }

    @objc @discardableResult public override func updateConfig(_ para:Dictionary<String, Any>)->Int
    {
        var nUpdatePara = super.updateConfig(para)

        if let tempValue = para[KBCfgAdvAOA.JSON_FIELD_AOA_TYPE] as? Int {
            type = tempValue
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgAdvAOA.JSON_FIELD_AOA_AXIS] as? Int {
            axisSupport = tempValue > 0
            nUpdatePara += 1
        }
        if let tempValue = para[KBCfgAdvAOA.JSON_FIELD_AOA_SYS_ADV_INTERVAL] as? Int {
            sysAdvInterval = tempValue
            nUpdatePara += 1
        }
        return nUpdatePara;
    }

    @objc public override func toDictionary()->Dictionary<String, Any>
    {
        var cfgDicts = super.toDictionary();
        
        if let tempValue = type{
            cfgDicts[KBCfgAdvAOA.JSON_FIELD_AOA_TYPE] = tempValue
        }
        if let tempValue = axisSupport{
            cfgDicts[KBCfgAdvAOA.JSON_FIELD_AOA_AXIS] = (tempValue ? 1 : 0)
        }
        if let tempValue = sysAdvInterval{
            cfgDicts[KBCfgAdvAOA.JSON_FIELD_AOA_SYS_ADV_INTERVAL] = tempValue
        }
        return cfgDicts;
    }
}
