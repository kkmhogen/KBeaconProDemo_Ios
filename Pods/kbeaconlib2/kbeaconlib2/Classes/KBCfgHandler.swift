//
//  KBCfgHandler.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

internal class KBCfgHandler {
    //configuration read from device
    private var kbDeviceAdvCommonPara: KBCfgCommon?
    private var kbDeviceCfgAdvSlotLists: [KBCfgAdvBase]
    private var kbDeviceCfgTriggerLists: [KBCfgTrigger]
    private var kbDeviceCfgSensorLists : [KBCfgSensorBase]

    //object creation factory
    static var kbCfgAdvObjects: Dictionary<Int, KBCfgAdvBase.Type> = [
        KBAdvType.AdvNull: KBCfgAdvNull.self,
        KBAdvType.Sensor: KBCfgAdvKSensor.self,
        KBAdvType.EddyUID: KBCfgAdvEddyUID.self,
        KBAdvType.EddyTLM: KBCfgAdvEddyTLM.self,
        KBAdvType.EddyURL: KBCfgAdvEddyURL.self,
        KBAdvType.IBeacon: KBCfgAdvIBeacon.self,
        KBAdvType.System: KBCfgAdvSystem.self]
    
    static var kbCfgTriggerObjects : Dictionary<Int, KBCfgTrigger.Type> = [
        KBTriggerType.AccMotion: KBCfgTrigger.self,
        KBTriggerType.TriggerNull: KBCfgTrigger.self,
        KBTriggerType.BtnLongPress: KBCfgTrigger.self,
        KBTriggerType.BtnSingleClick: KBCfgTrigger.self,
        KBTriggerType.BtnDoubleClick: KBCfgTrigger.self,
        KBTriggerType.BtnTripleClick: KBCfgTrigger.self,
        KBTriggerType.HTTempAbove: KBCfgTrigger.self,
        KBTriggerType.HTTempBelow: KBCfgTrigger.self,
        KBTriggerType.HTHumidityAbove: KBCfgTrigger.self,
        KBTriggerType.HTHumidityBelow: KBCfgTrigger.self
    ]
    static var kbCfgSensorObjects :Dictionary<Int, KBCfgSensorBase.Type> = [
        KBSensorType.HTHumidity: KBCfgSensorHT.self
    ]
    
    internal init()
    {
        kbDeviceCfgAdvSlotLists = []
        kbDeviceCfgTriggerLists = []
        kbDeviceCfgSensorLists = []
    }

    internal func getDeviceSlotCfg(_ slotIndex: Int)->KBCfgAdvBase?
    {
        for slotPara in kbDeviceCfgAdvSlotLists
        {
            if slotPara.getSlotIndex() == slotIndex
            {
                return slotPara;
            }
        }
        return nil;
    }

    internal func clearBufferConfig()
    {
        kbDeviceAdvCommonPara = nil
        kbDeviceCfgAdvSlotLists.removeAll()
        kbDeviceCfgSensorLists.removeAll()
        kbDeviceCfgTriggerLists.removeAll()
    }

    internal func getCfgComm()->KBCfgCommon?
    {
        return kbDeviceAdvCommonPara
    }

    internal func getSlotCfgList()->[KBCfgAdvBase]{
        return kbDeviceCfgAdvSlotLists
    }

    internal func getSensorCfgList()->[KBCfgSensorBase]
    {
        return kbDeviceCfgSensorLists
    }

    internal func getTriggerCfgList()->[KBCfgTrigger]
    {
        return kbDeviceCfgTriggerLists
    }

    internal func getSlotTriggerCfgList(_ slotIndex:Int)->[KBCfgTrigger]?
    {
        var cfgList:[KBCfgTrigger]?
        for triggerCfg in kbDeviceCfgTriggerLists
        {
            if slotIndex == triggerCfg.getTriggerAdvSlot()
            {
                if (cfgList == nil)
                {
                    cfgList = [KBCfgTrigger]()
                }
                cfgList!.append(triggerCfg)
            }
        }
        return cfgList
    }

    internal func getDeviceSlotsCfgByType(_ advType:Int)->[KBCfgAdvBase]?
    {
        var cfgList:[KBCfgAdvBase]?
        
        for slotCfg in kbDeviceCfgAdvSlotLists
        {
            if slotCfg.getAdvType() == advType
            {
                if (cfgList == nil){
                    cfgList = [KBCfgAdvBase]()
                }
                cfgList!.append(slotCfg)
            }
        }

        return cfgList
    }

    internal func getDeviceTriggerCfg(_ triggerType:Int)->KBCfgTrigger?
    {
        for triggerCfg in kbDeviceCfgTriggerLists
        {
            if triggerCfg.getTriggerType() == triggerType{
                return triggerCfg;
            }
        }
        return nil
    }

    internal func getDeviceSensorCfg(_ sensorType:Int)->KBCfgSensorBase?
    {
        for sensorCfg in kbDeviceCfgSensorLists
        {
            if (sensorCfg.getSensorType() == sensorType)
            {
                return sensorCfg;
            }
        }
        return nil
    }

    internal func getDeviceTriggerCfgPara()->[KBCfgTrigger]
    {
        return kbDeviceCfgTriggerLists
    }


    private func getDeviceAdvSlotObj(_ slotIndex:Int)->KBCfgAdvBase?
    {
        for  obj in kbDeviceCfgAdvSlotLists
        {
            if obj.getSlotIndex() == slotIndex
            {
                return obj
            }
        }

        return nil
    }

    internal static func addTriggerClass(_ triggerType: Int, classType: KBCfgTrigger.Type)
    {
        KBCfgHandler.kbCfgTriggerObjects[triggerType] = classType
    }

    internal static func addAdvClass(_ advType: Int, classType: KBCfgAdvBase.Type)
    {
        KBCfgHandler.kbCfgAdvObjects[advType] = classType
    }

    internal static func addSensorClass(_ sensorType: Int, classType: KBCfgSensorBase.Type)
    {
        KBCfgHandler.kbCfgSensorObjects[sensorType] = classType
    }

    internal static func createCfgAdvObject(_ advType:Int)->KBCfgAdvBase?
    {
        if let inistanceObj = kbCfgAdvObjects[advType]
        {
            return inistanceObj.init()
        }

        return nil
    }

    internal static func createCfgTriggerObject(_ triggerType:Int)->KBCfgTrigger?
    {
        if let inistanceObj = kbCfgTriggerObjects[triggerType]
        {
            let newTrigger = inistanceObj.init()
            newTrigger.setTriggerType(triggerType)
            return newTrigger
        }

        return nil
    }

    internal static func createCfgSensorObject(_ sensorType:Int)->KBCfgSensorBase?
    {
        if let inistanceObj = kbCfgSensorObjects[sensorType]
        {
            let sensorCfg = inistanceObj.init()
            sensorCfg.sensorType = sensorType
            return sensorCfg
        }

        return nil
    }

    internal static func createCfgObjectsFromJsonObject(_ jsonDicts:Dictionary<String, Any>)->[KBCfgBase]
    {
        let cfgHandler = KBCfgHandler();
        cfgHandler.initDeviceCfgFromJsonObject(jsonDicts)

        var cfgList:[KBCfgBase] = []
        
        //common cfg
        if let commPara = cfgHandler.kbDeviceAdvCommonPara{
            cfgList.append(commPara)
        }

        for object in cfgHandler.kbDeviceCfgAdvSlotLists{
            cfgList.append(object)
        }

        for object in cfgHandler.kbDeviceCfgTriggerLists{
            cfgList.append(object)
        }
        
        for object in cfgHandler.kbDeviceCfgSensorLists{
            cfgList.append(object)
        }
        
        return cfgList
    }

    private func getDeviceTriggerObj(_ triggerType:Int)->KBCfgTrigger?
    {
        for obj in kbDeviceCfgTriggerLists
        {
            if (obj.getTriggerType() == triggerType)
            {
                return obj
            }
        }

        return nil
    }

    @discardableResult private func updateDeviceCfgAdvObjFromParas(_ advPara:Dictionary<String, Any>)->KBCfgAdvBase?
    {
        guard let advType = advPara[KBCfgAdvBase.JSON_FIELD_BEACON_TYPE] as? Int else{
            NSLog("updateDeviceCfgAdvObjFromParas update device configuration failed during adv type is null");
            return nil
        }
        
        guard let slotIndex = advPara[KBCfgAdvBase.JSON_FIELD_SLOT] as? Int else{
            NSLog("updateDeviceCfgAdvObjFromParas update device configuration failed during slot index is null");
            return nil
        }

        if let deviceAdvObj = getDeviceAdvSlotObj(slotIndex)
        {
            deviceAdvObj.updateConfig(advPara)
            return deviceAdvObj
        }
        else
        {
            if let deviceAdvObj = KBCfgHandler.createCfgAdvObject(advType)
            {
                deviceAdvObj.updateConfig(advPara)
                kbDeviceCfgAdvSlotLists.append(deviceAdvObj)
                print("add new adv object(slot:\(slotIndex), type:\(advType)) to device config buffer\n");
                return deviceAdvObj
            }
            else
            {
                NSLog("updateDeviceCfgAdvObjFromParas update device create adv para failed, adv type:%d", advType);
            }
        }

        return nil;
    }

    @discardableResult private func updateDeviceCfgTriggerFromParas(_ triggerPara:Dictionary<String, Any> )->KBCfgTrigger?
    {
        guard let triggerType = triggerPara[KBCfgTrigger.JSON_FIELD_TRIGGER_TYPE] as? Int else {
            NSLog("updateDeviceCfgTriggerFromParas update device configuration failed during trigger type is null")
            return nil
        }

        if let deviceTriggerObj = getDeviceTriggerObj(triggerType){
            deviceTriggerObj.updateConfig(triggerPara)
            return deviceTriggerObj
        }
        else
        {
            if let deviceTriggerObj = KBCfgHandler.createCfgTriggerObject(triggerType){
                deviceTriggerObj.updateConfig(triggerPara)
                kbDeviceCfgTriggerLists.append(deviceTriggerObj)
                print("add new trigger object type:\(triggerType) to device config buffer\n")
                return deviceTriggerObj
            }else{
                NSLog("updateDeviceCfgTriggerFromParas update device create trigger object failed, trigger type:%d", triggerType)
            }
        }

        return nil;
    }

    @discardableResult private func updateDeviceCfgSensorFromParas(_ sensorPara: Dictionary<String, Any>  )->KBCfgSensorBase?
    {
        guard let sensorType = sensorPara[KBCfgSensorBase.JSON_FIELD_SENSOR_TYPE] as? Int else {
            NSLog("updateDeviceCfgSensorFromParas update device configuration failed during sensor type is null")
            return nil
        }

        if let deviceSensorObj = getDeviceSensorCfg(sensorType)
        {
            deviceSensorObj.updateConfig(sensorPara)
            return deviceSensorObj
        }else{
            if let deviceSensorObj = KBCfgHandler.createCfgSensorObject(sensorType){
                kbDeviceCfgSensorLists.append(deviceSensorObj);
                deviceSensorObj.updateConfig(sensorPara)
                print("add new sensor object(type:\(sensorType) to device config buffer\n")
                return deviceSensorObj
            }else{
                NSLog("updateDeviceCfgSensorFromParas update device create sensor object failed, trigger type:%d", sensorType)
            }
        }
        
        return nil
    }
    

    internal func updateDeviceCfgFromJsonObject(_ jsonObject: Dictionary<String, Any>)
    {
        udateDeviceCfgFromJsonObject(jsonObject, initCfg: false)
    }
    
    internal func initDeviceCfgFromJsonObject(_ jsonObject: Dictionary<String, Any>)
    {
        udateDeviceCfgFromJsonObject(jsonObject, initCfg: true)
    }
    
    
    //create adv objects from JSON string
    private func udateDeviceCfgFromJsonObject(_ jsonObject: Dictionary<String, Any>, initCfg:Bool)
    {
        //adv common
        if initCfg || kbDeviceAdvCommonPara == nil {
            kbDeviceAdvCommonPara = KBCfgCommon();
        }
        kbDeviceAdvCommonPara?.updateConfig(jsonObject)
        
        if (initCfg){
            kbDeviceCfgAdvSlotLists.removeAll()
            kbDeviceCfgTriggerLists.removeAll()
            kbDeviceCfgSensorLists.removeAll()
        }

        //update adv paras
        if let advParas = jsonObject[KBCfgAdvBase.JSON_FIELD_ADV_OBJ_LIST] as? [[String:Any]] {
            for object in advParas {
                updateDeviceCfgAdvObjFromParas(object)
            }
        }
        
        //update trigger paras
        if let triggerParas = jsonObject[KBCfgTrigger.JSON_FIELD_TRIGGER_OBJ_LIST] as? [[String:Any]] {
            for object in triggerParas {
                updateDeviceCfgTriggerFromParas(object)
            }
        }
        
        //update sensor paras
        if let sensorParas = jsonObject[KBCfgSensorBase.JSON_FIELD_SENSOR_OBJ_LIST] as? [[String:Any]] {
            for object in sensorParas {
                updateDeviceCfgSensorFromParas(object)
            }
        }
    }
    
    internal func checkConfigValid(_ cfgArray:[KBCfgBase])->Bool
    {
        for cfgObj in cfgArray
        {
            if let advObj = cfgObj as? KBCfgAdvBase
            {
                if let commCfg = kbDeviceAdvCommonPara
                {
                    //check tx power
                    if KBCfgBase.INVALID_INT8 != commCfg.getMinTxPower(),
                       KBCfgBase.INVALID_INT8 != commCfg.getMaxTxPower(),
                       advObj.getTxPower() < commCfg.getMinTxPower(),
                       advObj.getTxPower() > commCfg.getMaxTxPower()
                    {
                        NSLog("checkConfigValid the tx power is out of device capability")
                        return false
                    }
  
                    //check the device adv mode
                    let advMode = advObj.getAdvMode()
                    if (!commCfg.isSupportBLE2MBps() && advMode == KBAdvMode.K2Mbps)
                    {
                        NSLog("checkConfigValid the device does not support 2MBPS");
                        return false
                    }
                    
                    if (!commCfg.isSupportBLELongRangeAdv() && advMode == KBAdvMode.LongRange)
                    {
                        NSLog("checkConfigValid the device does not support long range");
                        return false
                    }
                }
            }

            //check the trigger
            if let triggerObj = cfgObj as? KBCfgTrigger
            {
                if (triggerObj.getTriggerAction() & KBTriggerAction.Advertisement) > 0
                {
                    if (triggerObj.getTriggerAdvSlot() == KBCfgBase.INVALID_INT)
                    {
                        NSLog("trigger adv slot is null")
                        return false;
                    }
                }
            }
        }

        return true;
    }

    
    //update configruation
    internal func updateDeviceConfig(_ newCfgArray: [KBCfgBase])
    {
        for obj in newCfgArray
        {
            if obj.toDictionary().count == 0
            {
                NSLog("updateDeviceConfig config data is null")
                continue;
            }

            //check if is common para
            if let commPara = obj as? KBCfgCommon
            {
                if (kbDeviceAdvCommonPara == nil){
                    kbDeviceAdvCommonPara = KBCfgCommon();
                }
                kbDeviceAdvCommonPara?.updateConfig(commPara.toDictionary())
            }

            //check if adv para
            if let advPara = obj as? KBCfgAdvBase
            {
                updateDeviceCfgAdvObjFromParas(advPara.toDictionary())
            }

            //check if trigger para
            if let triggerPara = obj as? KBCfgTrigger
            {
                updateDeviceCfgTriggerFromParas(triggerPara.toDictionary())
            }

            //check if trigger para
            if let sensorPara = obj as? KBCfgSensorBase
            {
                updateDeviceCfgSensorFromParas(sensorPara.toDictionary())
            }
        }
    }

    //translate object to json string for download to beacon
    internal static func objectsToJsonString(_ cfgObjects : [KBCfgBase])->String?
    {
        var jsonMsgObject:[String:Any] = [:]
        var jsonAdvParaArray:[Dictionary<String,Any>] = []
        var jsonTriggerParaArray:[Dictionary<String,Any>] = []
        var jsonSensorParaArray:[Dictionary<String,Any>] = []

        for obj in cfgObjects
        {
            let updatePara = obj.toDictionary()
            if updatePara.isEmpty{
                NSLog("config data is null");
                continue;
            }

            //add common object
            if obj is KBCfgCommon {
                jsonMsgObject = updatePara
            }
            else if (obj is KBCfgAdvBase)
            {
                //add adv cfg object
                jsonAdvParaArray.append(updatePara)
            }
            else if (obj is KBCfgTrigger) {
                //add trigger cfg object
                jsonTriggerParaArray.append(updatePara)
            }
            else if (obj is KBCfgSensorBase) {
                //add trigger cfg object
                jsonSensorParaArray.append(updatePara);
            }
        }

        if (jsonAdvParaArray.count > 0) {
            jsonMsgObject[KBCfgAdvBase.JSON_FIELD_ADV_OBJ_LIST] = jsonAdvParaArray
        }
        if (jsonTriggerParaArray.count > 0) {
            jsonMsgObject[KBCfgTrigger.JSON_FIELD_TRIGGER_OBJ_LIST] = jsonTriggerParaArray
        }
        if (jsonSensorParaArray.count > 0) {
            jsonMsgObject[KBCfgSensorBase.JSON_FIELD_SENSOR_OBJ_LIST] = jsonSensorParaArray
        }
        jsonMsgObject["msg"] = "cfg"

        let jsonData = try? JSONSerialization.data(withJSONObject: jsonMsgObject, options: [])
        return jsonData?.jsonData2StringWithoutSpaceReturn()
    }

    //parse command para to string
    internal static func cmdParaToJsonString(_ paraDicts:Dictionary<String,Any>)->String?
    {
        let jsonData = try? JSONSerialization.data(withJSONObject: paraDicts, options: [])
        return jsonData?.jsonData2StringWithoutSpaceReturn()
    }
}
