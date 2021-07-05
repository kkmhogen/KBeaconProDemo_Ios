//
//  KBeacon.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/15.
//

import Foundation
import CoreBluetooth


//on reads sensor complete
public typealias onReadSensorComplete = (_ result:Bool, _ rspData:Data?, _ error:KBException?)->Void

public typealias onReadConfigComplete = (_ result:Bool, _ rspData:[String:Any]?, _ error:KBException?)->Void

public typealias onActionComplete = (_ result:Bool, _ error:KBException?)->Void


@objc public protocol ConnStateDelegate : NSObjectProtocol
{
    func onConnStateChange(_ beacon:KBeacon, state:KBConnState, evt:KBConnEvtReason)
}

@objc public protocol NotifyDataDelegate: NSObjectProtocol
{
    func onNotifyDataReceived(_ beacon:KBeacon, evt:Int, data:Data);
}

//connect status
@objc public enum KBConnState:Int
{
    case Disconnected = 0
    case Connecting = 1
    case Disconnecting = 2
    case Connected = 3
}

//connection event
@objc public enum KBConnEvtReason:Int
{
    case ConnNull = 0
    case ConnSuccess = 1
    case ConnTimeout
    case ConnException
    case ConnServiceNotSupport
    case ConnManualDisconnting
    case ConnAuthFail
}

@objc enum ActionType:Int
{
    case ACTION_INIT_READ_CFG = 3
    case ACTION_WRITE_CFG = 1
    case ACTION_WRITE_CMD = 2
    case ACTION_IDLE = 0
    case ACTION_USR_READ_CFG = 4
    case ACTION_READ_SENSOR = 5
    case ACTION_ENABLE_NTF = 6
}

@objc public class KBeacon :NSObject, CBPeripheralDelegate, KBAuthDelegate
{
    //////////////////////////////////////////////////////advertisement parameters
    @objc public weak var delegate: ConnStateDelegate?
        
    @objc public var rssi : Int8 = -100
    
    @objc public var name:String?
    
    @objc public var state: KBConnState
    
    @objc public var cbPeripheral: CBPeripheral?
    
    @objc public var uuidString: String?{
        get{
            return cbPeripheral?.identifier.uuidString
        }
    }
    
    @objc public var allAdvPackets: [KBAdvPacketBase]?{
        get{
            if mAdvPacketMgr.mAdvPackets.count == 0{
                return nil
            }
            
            var allPackets = [KBAdvPacketBase]()
            for (_,advPacket) in mAdvPacketMgr.mAdvPackets
            {
                allPackets.append(advPacket)
            }
            return allPackets
        }
    }
    
    //return KBCfgBase.INVALID_INT8 if device does not have max tx power
    @objc public var maxTxPower:Int8{
        get{
            if let cfgCommon = mCfgMgr.getCfgComm(){
                return cfgCommon.getMaxTxPower()
            }
            return KBCfgBase.INVALID_INT8
        }
    }
    
    //return KBCfgBase.INVALID_INT8 if device does not have min tx power
    @objc public var minTxPower:Int8{
        get{
            if let cfgCommon = mCfgMgr.getCfgComm(){
                return cfgCommon.getMinTxPower()
            }
            return KBCfgBase.INVALID_INT8
        }
    }
    
    //device model, for example: K11_NRF52XX
    @objc public var model:String?{
        get{
            if let cfgCommon = mCfgMgr.getCfgComm(){
                return cfgCommon.getModel()
            }
            
            return nil
        }
    }
    
    //device firmware version
    @objc public var version:String?{
        get{
            if let cfgCommon = mCfgMgr.getCfgComm(){
                return cfgCommon.getVersion()
            }
            
            return nil
        }
    }
    
    //device hardware version
    @objc public var hardwareVersion:String?{
        get{
            if let cfgCommon = mCfgMgr.getCfgComm(){
                return cfgCommon.getHardwareVersion()
            }
            return nil
        }
    }
    
    //default is 0
    @objc public var capibility:Int{
        get{
            if let cfgCommon = mCfgMgr.getCfgComm(){
                return cfgCommon.getBasicCapability()
            }
            return 0
        }
    }
    
    //default is 0
    @objc public var triggerCapibility:Int{
        get{
            if let cfgCommon = mCfgMgr.getCfgComm(){
                return cfgCommon.getTrigCapability()
            }
            return 0
        }
    }
    
    //default is KBCfgBase.INVALID_UINT8
    @objc public var batteryPercent:UInt8{
        get{
            return mAdvPacketMgr.batteryPercent ?? KBCfgBase.INVALID_UINT8
        }
    }
    
    //mac address, can be nil
    @objc public var mac:String? {
        get{
            if let sysAdvPacket = mAdvPacketMgr.getAdvPacket(KBAdvType.System) as? KBAdvPacketSystem
            {
                return sysAdvPacket.macAddress  //adv mac
            }
            else if connectionMac != nil  //connection mac
            {
                return connectionMac
            }
            else     //saved mac
            {
                let defaults = UserDefaults.standard
                let strMacKey = "kb_\(uuidString!)"
                return defaults.object(forKey: strMacKey) as? String
            }
        }
    }
    
    //private local variable
    private weak var mBeaconMgr : KBeaconsMgr?
    
    private var mAdvPacketMgr: KBAdvPacketHandler
    
    //config manager
    private var mCfgMgr:KBCfgHandler
    
    //authentication handler;
    private var mAuthHandler: KBAuthHandler?
    
    //read data subtype
    private var mNextInitReadCfgSubtype:Int
    
    //connecting timer
    private var mConnectingTimer:Timer?
    private var mDisconnectingTimer:Timer?
    private var mActionTimer:Timer?
    
    //download data
    private var mByDownloaDatas:Data?
    private var mByDownDataType:Int?
    
    //action type state
    private var mActionStatus:ActionType
    
    private var mReadCfgCallback: onReadConfigComplete?
    
    private var mWriteCfgCallback: onActionComplete?
    
    private var mWriteCmdCallback: onActionComplete?
    
    private var mReadSensorCallback: onReadSensorComplete?
    
    private var mEnableSubsribeNotifyCallback: onActionComplete?
    
    private var mReceiveData: Data
    
    private var mTobeCfgData: [KBCfgBase]?
    
    private var mNotifyData2ClassMap:[Int:NotifyDataDelegate]
    
    private var mToAddedSubscribeInstance:NotifyDataDelegate?
    
    private var mToAddedTriggerType:Int?
    
    private var mCloseReason:KBConnEvtReason
    
    private var connectionMac : String?
    
    internal static let MAX_CONNING_TIME_SEC = 15.0
    
    internal static let MAX_READ_CFG_TIMEOUT = 15.0
    
    //data type
    private static let DATA_TYPE_AUTH = 0x1
    
    private static let DATA_TYPE_JSON = 0x2
    
    
    //frame tag
    private static let PDU_TAG_START = 0x0
    private static let PDU_TAG_MIDDLE = 0x1
    private static let PDU_TAG_END = 0x2
    private static let PDU_TAG_SINGLE = 0x3
    
    //down hex file
    //upload json data
    private static let CENT_PERP_TX_HEX_DATA = 0
    private static let PERP_CENT_TX_HEX_ACK =  0
    
    //down json data
    static let CENT_PERP_TX_JSON_DATA =  2
    static let PERP_CENT_TX_JSON_ACK = 2
    
    //upload json data
    private static let PERP_CENT_DATA_RPT = 3
    private static let CENT_PERP_DATA_RPT_ACK = 3
    
    //upload hex data
    private static let PERP_CENT_HEX_DATA_RPT = 5
    private static let CENT_PERP_HEX_DATA_RPT_ACK = 5
    
    private static let BEACON_ACK_SUCCESS = 0x0
    private static let BEACON_ACK_EXPECT_NEXT = 0x4
    private static let BEACON_ACK_CAUSE_CMD_RCV = 0x5
    private static let BEACON_ACK_CMD_CMP = 0x6
    
    //max mtu size
    private static let MIN_BLE_MTU_SIZE = 20
    private static let MAX_BLE_MTU_SIZE = 251
    
    private static let MSG_PDU_HEAD_LEN = 0x3
    private static let DATA_ACK_HEAD_LEN = 0x6
    
    //buffer size
    private static let MAX_BUFFER_DATA_SIZE = 1024
    
    internal override init()
    {
        mNotifyData2ClassMap = [Int:NotifyDataDelegate]()
        mActionStatus = ActionType.ACTION_IDLE
        mCloseReason = KBConnEvtReason.ConnException
        state = KBConnState.Disconnected
        mAdvPacketMgr = KBAdvPacketHandler();
        mNextInitReadCfgSubtype = 0
        mReceiveData = Data()
        mCfgMgr = KBCfgHandler()
    }
    
    internal func attach2Device(peripheral:CBPeripheral, beaconMgr:KBeaconsMgr)
    {
        cbPeripheral = peripheral
        peripheral.delegate = self
        mBeaconMgr = beaconMgr
    }
    
    //get the specified advertisement packet
    @objc public func getAvPacketByType(_ advType:Int)->KBAdvPacketBase?
    {
        return mAdvPacketMgr.getAdvPacket(advType)
    }
    
    //remove buffered advertisement packet
    @objc public func removeAdvPacket()
    {
        mAdvPacketMgr.removeAdvPacket()
    }
    
    //connect to device with default parameters
    //When the app is connected to the KBeacon device, the app can specify which the configuration parameters to be read,
    //the app will read common parameters, advertisement parameters, trigger parameters by default
    @objc @discardableResult public func connect(_ password:String, timeout:Double, delegate:ConnStateDelegate?)->Bool
    {
        return connectEnhanced(password, timeout:timeout, connPara:KBConnPara(), delegate: delegate);
    }
    
    //connect to device with specified parameters
    //When the app is connected to the KBeacon device, the app can specify which the configuration parameters to be read,
    //The parameter that can be read include: common parameters, advertisement parameters, trigger parameters, and sensor parameters
    @objc @discardableResult public func connectEnhanced(_ password: String, timeout:Double, connPara: KBConnPara, delegate:ConnStateDelegate?)->Bool
    {
        guard let cbCentral = mBeaconMgr?.cbBeaconMgr,
              let cbPeripherial = cbPeripheral,
              state == KBConnState.Disconnected,
              timeout > 3.0,
              password.count <= 16 && password.count >= 8 else
        {
            NSLog("input paramaters false");
            return false
        }
        self.delegate = delegate
        self.mAuthHandler = KBAuthHandler(password: password, connPara: connPara, delegate: self)
        state = KBConnState.Connecting
        
        //start connect
        cbPeripherial.delegate = self
        cbCentral.connect(cbPeripherial, options: nil)
        
        //start connect timer
        if let connTimer = mConnectingTimer,
           connTimer.isValid
        {
            connTimer.invalidate()
        }
        
        mConnectingTimer = Timer.scheduledTimer(timeInterval: timeout,
                                 target: self,
                                 selector: #selector(connectingTimeout(_:)),
                                 userInfo: nil,
                                 repeats: false)
        
        //cancel privous action
        self.cancelActionTimer()
        mCfgMgr.clearBufferConfig() //remove buffer paramaters
        
        //notify connecting
        if let delegateConn = self.delegate
        {
            delegateConn.onConnStateChange(self, state: self.state, evt:KBConnEvtReason.ConnNull)
        }
        
        return true;
    }
    
    //the app can init disconnect with device
    @objc public func disconnect() {
        self.closeBeacon(reason: KBConnEvtReason.ConnManualDisconnting)
    }
    
    //get common parameters that already read from device, if the SDK does not have common parameters,
    //it wil return null. The app can specify whether to read common parameters when connecting.
    // The common parameters include the capability information of the device, as well as some other public parameters.
    @objc public func getCommonCfg()->KBCfgCommon?
    {
        if let cfgCommon = mCfgMgr.getCfgComm(){
            return cfgCommon
        }
        return nil
    }
    
    //get trigger parameters that read from device
    @objc public func getTriggerCfgList()->[KBCfgTrigger]?
    {
        return mCfgMgr.getTriggerCfgList()
    }
    
    //get trigger configruation by index
    @objc public func getTriggerCfgByIndex(_ triggerIndex:Int)->KBCfgTrigger?
    {
        let triggerList = mCfgMgr.getTriggerCfgList()
        for trigger in triggerList{
            if trigger.getTriggerIndex() == triggerIndex{
                return trigger
            }
        }
        
        return nil
    }
    
    //get trigger configuration by advertisement slot index
    @objc public func getSlotTriggerCfgList(_ advSlot:Int)->[KBCfgTrigger]?
    {
        return mCfgMgr.getSlotTriggerCfgList(advSlot)
    }
    
    //get all slot configuration
    @objc public func getSlotCfgList()->[KBCfgAdvBase]?
    {
        return mCfgMgr.getSlotCfgList()
    }
    
    //get advertisement configuration by advertisement type
    @objc public func getSlotCfgByAdvType(_ advType:Int)->[KBCfgAdvBase]?
    {
        return mCfgMgr.getDeviceSlotsCfgByType(advType)
    }
    
    //get advertisement configuration by slot ID
    @objc public func getSlotCfg(_ slotIndex:Int)->KBCfgAdvBase?
    {
        return mCfgMgr.getDeviceSlotCfg(slotIndex)
    }
    
    //get trigger configuration by trigger type
    @objc public func getTriggerCfg(_ triggerType:Int)->KBCfgTrigger?
    {
        return mCfgMgr.getDeviceTriggerCfg(triggerType)
    }
    
    //get all sensor configuration
    @objc public func getSensorCfgList()->[KBCfgSensorBase]?
    {
        return mCfgMgr.getSensorCfgList()
    }
    
    //get sensor configuration by sensor type
    @objc public func getSensorCfg(_ sensorType:Int)->KBCfgSensorBase?
    {
        return mCfgMgr.getDeviceSensorCfg(sensorType)
    }
    
    //get eddy TLM advertisement configuration
    @objc public func getEddyTLMAdvCfg()->KBCfgAdvEddyTLM?
    {
        if let sensorList = mCfgMgr.getDeviceSlotsCfgByType(KBAdvType.EddyTLM)
        {
            return sensorList[0] as? KBCfgAdvEddyTLM
        }
        return nil
    }
    
    //get system advertisement configuration
    @objc public func getSystemAdvCfg()->KBCfgAdvSystem?
    {
        if let sensorList = mCfgMgr.getDeviceSlotsCfgByType(KBAdvType.System)
        {
            return sensorList[0] as? KBCfgAdvSystem
        }
        return nil
    }
    
    //get KSensor advertisement configuration
    @objc public func getKSensorAdvCfg()->KBCfgAdvKSensor?
    {
        if let sensorList = mCfgMgr.getDeviceSlotsCfgByType(KBAdvType.Sensor)
        {
            return sensorList[0] as? KBCfgAdvKSensor
        }
        return nil
    }
    
    //clear all buffered configruation parameter that read from device
    @objc public func clearBufferConfig()
    {
        self.mCfgMgr.clearBufferConfig()
    }
    
    //check if device was connected
    @objc public func isConnected()->Bool
    {
        return self.state == KBConnState.Connected
    }
    
    @objc public func setConnStateDelegate(delegate: ConnStateDelegate)
    {
        self.delegate = delegate;
    }
    
    //check device support notification report
    @objc public func isSupportSensorDataNotification()->Bool
    {
        let cbService = KBUtility.findService(peripherial: cbPeripheral, sUUID: KBUtility.KB_CFG_SERVICES_UUID)
        if let service = cbService
        {
            return KBUtility.findCharacteristic(cUUID: KBUtility.KB_IND_CHAR_UUID, service: service) != nil
        }
        
        return false
    }
    
    //subscribe trigger event notification
    @objc public func subscribeSensorDataNotify(_ triggerType:Int,
                                          notifyDelegate: NotifyDataDelegate ,
                                          callback: onActionComplete?)
    {
        if (!isSupportSensorDataNotification()) {
            if let ntfCallback = callback {
                ntfCallback(false, KBException(KBErrorCode.CfgBusy, desc:"Device does not support this notification"))
            }
            return;
        }
        
        if mNotifyData2ClassMap.isEmpty
        {
            if (self.mActionStatus != ActionType.ACTION_IDLE)
            {
                if let ntfCallback = callback {
                    ntfCallback(false, KBException(KBErrorCode.CfgBusy, desc:"Device was busy"))
                }
                return;
            }
            
            if (state != KBConnState.Connected)
            {
                if let ntfCallback = callback {
                    ntfCallback(false, KBException(KBErrorCode.CfgStateError, desc:"Device was disconnected"))
                }
                return;
            }
            
            //save callback
            let bResult = startEnableNotification(serviceID: KBUtility.KB_CFG_SERVICES_UUID, charID: KBUtility.KB_IND_CHAR_UUID, enable: true)
            if (bResult)
            {
                self.mEnableSubsribeNotifyCallback = callback
                self.mToAddedSubscribeInstance = notifyDelegate
                self.mToAddedTriggerType = triggerType
                
                startNewAction(action: ActionType.ACTION_ENABLE_NTF, timeout:5.0)
            }
            else
            {
                if let ntfCallback = callback {
                    ntfCallback(false, KBException(KBErrorCode.CfgNotSupport, desc:"Enable BLE notification failed"))
                }
            }
        } else {
            mNotifyData2ClassMap[triggerType] = notifyDelegate
            if let ntfCallback = callback {
                ntfCallback(true, nil)
            }
        }
    }
    
    //check if subscribe the trigger event
    @objc public func isSensorDataSubscribe(triggerType:Int)->Bool
    {
        return mNotifyData2ClassMap[triggerType] != nil
    }
    
    //remove trigger event subscribe notfication
    @objc public func removeSubscribeSensorDataNotify(_ triggerType:Int, callback: onActionComplete?)->Void
    {
        if (!isSupportSensorDataNotification()) {
            if let ntfCallback = callback {
                ntfCallback(false, KBException(KBErrorCode.CfgNotSupport, desc:"Device does not support the notification"))
            }
            return
        }
        
        if (self.mNotifyData2ClassMap.count == 1)
        {
            if (mActionStatus != ActionType.ACTION_IDLE)
            {
                if let ntfCallback = callback {
                    ntfCallback(false, KBException(KBErrorCode.CfgBusy, desc:"Device was busy"))
                }
                return;
            }
            if (state != KBConnState.Connected)
            {
                if let ntfCallback = callback {
                    ntfCallback(false, KBException(KBErrorCode.CfgStateError, desc:"Device was disconnected"))
                }
                return;
            }
            
            //save callback
            mToAddedSubscribeInstance = nil;
            mToAddedTriggerType = 0;
            let bResult = startEnableNotification(serviceID: KBUtility.KB_CFG_SERVICES_UUID, charID: KBUtility.KB_IND_CHAR_UUID, enable: false)
            if (bResult)
            {
                mEnableSubsribeNotifyCallback = callback
                startNewAction(action: ActionType.ACTION_ENABLE_NTF, timeout:3.0)
            }
        } else {
            self.mNotifyData2ClassMap[triggerType] = nil
            if let ntfCallback = callback {
                ntfCallback(true, nil)
            }
        }
    }
    
    //send json command message to device
    @objc public func sendCommand(_ cmdPara:[String:Any], callback:onActionComplete?)
    {
        if (mActionStatus != ActionType.ACTION_IDLE)
        {
            if let actionCallback = callback
            {
                actionCallback(false, KBException(KBErrorCode.CfgBusy, desc: "Device was busy"))
            }
            return;
        }
        
        if (state != KBConnState.Connected)
        {
            if let actionCallback = callback
            {
                actionCallback(false, KBException(KBErrorCode.CfgStateError, desc:"Device was disconnected"))
            }
            return
        }
        
        //save callback
        if let jsonString = KBCfgHandler.cmdParaToJsonString(cmdPara)
        {
            self.mTobeCfgData = nil
            mWriteCmdCallback = callback;
            
            mByDownloaDatas = jsonString.data(using: String.Encoding.utf8)
            mByDownDataType = KBeacon.CENT_PERP_TX_JSON_DATA
            self.startNewAction(action: ActionType.ACTION_WRITE_CMD, timeout: KBeacon.MAX_READ_CFG_TIMEOUT)
            self.sendNextCfgData(seq: 0)
        }
        else
        {
            if let actionCallback = callback
            {
                actionCallback(false, KBException(KBErrorCode.CfgInputInvalid, desc:"Parse the message from device failed"));
            }
        }
    }
    
    //read config by raw json message
    @objc public func readConfig(_ reqMsg: [String:Any], callback:onReadConfigComplete?)
    {
        if (mActionStatus != ActionType.ACTION_IDLE)
        {
            if let readCallback = callback
            {
                readCallback(false, nil, KBException(KBErrorCode.CfgBusy, desc:"Device was busy"));
            }
            return;
        }
        
        if (state != KBConnState.Connected)
        {
            if let readCallback = callback
            {
                readCallback(false, nil, KBException(KBErrorCode.CfgStateError, desc:"Device was disconnected"));
            }
            return
        }
        
        if (configReadBeaconParamaters(reqMsg, actionType: ActionType.ACTION_USR_READ_CFG))
        {
            mReadCfgCallback = callback
        }
        else
        {
            if let readCallback = callback
            {
                readCallback(false, nil, KBException( KBErrorCode.CfgInputInvalid, desc:"Parameter invalid"));
            }
        }
    }
    
    //read common parameters from device,
    //this function will force app to read common parameters again from device
    @objc public func readCommonConfig(_ callback: onReadConfigComplete?)
    {
        var reqPara = [String:Any]()
        reqPara[KBCfgBase.JSON_MSG_TYPE_KEY] = KBCfgBase.JSON_MSG_TYPE_GET_PARA
        reqPara[KBCfgBase.JSON_FIELD_SUBTYPE] = KBCfgType.CommonPara
        
        readConfig(reqPara, callback: callback)
    }
    
    //read specificed slot parameters from device,
    //this function will force app to read slot parameters again from device
    @objc public func readSlotConfig(_ slotIndex:Int, callback: onReadConfigComplete?)
    {
        var reqPara = [String:Any]()
        reqPara[KBCfgBase.JSON_MSG_TYPE_KEY] = KBCfgBase.JSON_MSG_TYPE_GET_PARA
        reqPara[KBCfgBase.JSON_FIELD_SUBTYPE] = KBCfgType.AdvPara
        reqPara[KBCfgAdvBase.JSON_FIELD_SLOT] = slotIndex
        
        readConfig(reqPara, callback: callback)
    }
    
    //read trigger parameters from device
    //this function will force app to read trigger parameters again from device
    @objc public func readTriggerConfig(_ triggerType:Int, callback: onReadConfigComplete?)
    {
        var reqPara = [String:Any]()
        reqPara[KBCfgBase.JSON_MSG_TYPE_KEY] = KBCfgBase.JSON_MSG_TYPE_GET_PARA
        reqPara[KBCfgBase.JSON_FIELD_SUBTYPE] = KBCfgType.TriggerPara
        reqPara[KBCfgTrigger.JSON_FIELD_TRIGGER_TYPE] = triggerType
        
        readConfig(reqPara, callback: callback)
    }
    
    //read sensor parameters from device
    //this function will force app to read sensor parameters again from device
    @objc public func readSensorConfig(_ sensorType: Int, callback: onReadConfigComplete?)
    {
        var reqPara = [String:Any]()
        reqPara[KBCfgBase.JSON_MSG_TYPE_KEY] = KBCfgBase.JSON_MSG_TYPE_GET_PARA
        reqPara[KBCfgBase.JSON_FIELD_SUBTYPE] = KBCfgType.SensorPara
        reqPara[KBCfgSensorBase.JSON_FIELD_SENSOR_TYPE] = sensorType
        
        readConfig(reqPara, callback: callback)
    }
    
    //modify config list
    @objc public func modifyConfig(array cfgArray:[KBCfgBase], callback: onActionComplete?)
    {
        if (mActionStatus != ActionType.ACTION_IDLE)
        {
            if let actionCallback = callback
            {
                actionCallback(false, KBException(KBErrorCode.CfgBusy, desc:"Device was busy"));
            }
            return;
        }
        
        if (state != KBConnState.Connected)
        {
            if let actionCallback = callback
            {
                actionCallback(false, KBException(KBErrorCode.CfgStateError, desc:"Device was disconnected"));
            }
            return
        }
        
        //check if input is valid
        if (!mCfgMgr.checkConfigValid(cfgArray))
        {
            NSLog("verify configuration data invalid")
            if let actionCallback = callback
            {
                actionCallback(false, KBException(KBErrorCode.CfgInputInvalid, desc:"Parameters invalid"));
            }
            return;
        }
        
        //get configruation json
        let strJsonCfgData = KBCfgHandler.objectsToJsonString(cfgArray)
        guard let jsonString = strJsonCfgData, jsonString.count > 0 else
        {
            if let actionCallback = callback
            {
                actionCallback(false, KBException(KBErrorCode.CfgInputInvalid, desc:"Parameters invalid"));
            }
            return
        }
        
        //save data
        mByDownDataType = KBeacon.CENT_PERP_TX_JSON_DATA
        mWriteCfgCallback = callback
        mTobeCfgData = cfgArray
        mByDownloaDatas = jsonString.data(using: String.Encoding.utf8)
        
        //write data
        startNewAction(action: ActionType.ACTION_WRITE_CFG, timeout: KBeacon.MAX_READ_CFG_TIMEOUT)
        sendNextCfgData(seq: 0)
    }
    
    //modify single config
    @objc public func modifyConfig(obj cfgObj:KBCfgBase, callback: onActionComplete?)
    {
        var cfgArray = [KBCfgBase]()
        cfgArray.append(cfgObj)
        modifyConfig(array: cfgArray, callback: callback)
    }
    
    //send sensor message to device
    @objc public func sendSensorMessage(_ reqMsg:Data, callback:onReadSensorComplete?)
    {
        guard reqMsg.count > 0 else{
            NSLog("input paramaters is null")
            return
        }
        
        if (mActionStatus != ActionType.ACTION_IDLE)
        {
            if let request = callback
            {
                request(false, nil, KBException(KBErrorCode.CfgBusy, desc: "Device was busy"));
            }
            return;
        }
        
        if (state != KBConnState.Connected)
        {
            if let request = callback
            {
                request(false, nil, KBException(KBErrorCode.CfgStateError, desc: "Device was disconnected"));
            }
            return;
        }
        
        mReadSensorCallback = callback
        mByDownloaDatas = reqMsg
        mByDownDataType = KBeacon.CENT_PERP_TX_HEX_DATA
        mReceiveData.removeAll()
        self.startNewAction(action: ActionType.ACTION_READ_SENSOR, timeout: KBeacon.MAX_READ_CFG_TIMEOUT)
        self.sendNextCfgData(seq: 0)
    }
    
    @objc public static func createCfgAdvObject(_ advType:Int)->KBCfgAdvBase?
    {
        KBCfgHandler.createCfgAdvObject(advType)
    }

    @objc public static func createCfgTriggerObject(_ triggerType:Int)->KBCfgTrigger?
    {
        return KBCfgHandler.createCfgTriggerObject(triggerType)
    }

    @objc public static func createCfgSensorObject(_ sensorType:Int)->KBCfgSensorBase?
    {
        return KBCfgHandler.createCfgSensorObject(sensorType)
    }
    
    internal func parseAdvPacket(advData:[String:Any], rssi:Int8)->Bool
    {
        if let beaconName = advData["kCBAdvDataLocalName"] as? String{
            self.name = beaconName
        }
        
        if (rssi <= Int8.max && rssi >= Int8.min)
        {
            self.rssi = Int8(rssi)
        }
        
        return mAdvPacketMgr.parseAdvPacket(advData, rssi: rssi)
    }
    
    @discardableResult private func startEnableNotification(serviceID:CBUUID, charID:CBUUID, enable:Bool)->Bool
    {
        let cbServiceID = KBUtility.findService(peripherial: cbPeripheral, sUUID: KBUtility.KB_CFG_SERVICES_UUID)
        if let service = cbServiceID
        {
            let cbCharID = KBUtility.findCharacteristic(cUUID: charID, service: service)
            if let cbChar = cbCharID{
                cbPeripheral?.setNotifyValue(enable, for: cbChar)
                return true
            }
        }
        
        return false
    }
    
    @discardableResult private func startNewAction(action:ActionType, timeout:Double)->Bool
    {
        if (self.mActionStatus != ActionType.ACTION_IDLE)
        {
            NSLog("start new action failed during not idle");
            return false
        }
        
        mActionStatus = action
        if (timeout > 0)
        {
            mActionTimer = Timer.scheduledTimer(timeInterval: timeout,
                                 target: self,
                                 selector: #selector(actionTimeout(_:)),
                                 userInfo: nil,
                                 repeats: false)
        }
        
        return true
    }
    
    //connect device timeout
    @objc private func connectingTimeout(_ timer:Timer)
    {
        NSLog("Connecting to device timeout");
        if (self.state == KBConnState.Connecting){
            self.closeBeacon(reason: KBConnEvtReason.ConnTimeout)
        }
    }
    
    //disconnecting timeout
    @objc private func disconnectingTimeout(_ timer:Timer)
    {
        NSLog("Disconnecting to device timeout");
        if (self.state == KBConnState.Disconnecting)
        {
            self.state = KBConnState.Disconnected;
            if let connDelegate = self.delegate
            {
                connDelegate.onConnStateChange(self, state: self.state, evt: self.mCloseReason)
            }
        }
    }
    
    
    private func cancelActionTimer()
    {
        if let actionTimer = mActionTimer,
           actionTimer.isValid
        {
            actionTimer.invalidate()
        }
        mActionStatus = ActionType.ACTION_IDLE;
    }
    
    //connect device timeout
    @objc private func actionTimeout(_ timer:Timer)
    {
        let error = KBException(KBErrorCode.CfgTimeout, desc: "Read or write operation timeout")
        
        if (mActionStatus == ActionType.ACTION_INIT_READ_CFG)
        {
            mActionStatus = ActionType.ACTION_IDLE;
            closeBeacon(reason: KBConnEvtReason.ConnTimeout)
        }
        else if (mActionStatus == ActionType.ACTION_USR_READ_CFG)
        {
            mActionStatus = ActionType.ACTION_IDLE;
            if let readCallback = mReadCfgCallback
            {
                mReadCfgCallback = nil;
                readCallback(false, nil, error);
            }
        }
        else if (mActionStatus == ActionType.ACTION_WRITE_CFG)
        {
            mActionStatus = ActionType.ACTION_IDLE;
            if let writeCfgCallback = mWriteCfgCallback
            {
                mWriteCfgCallback = nil;
                writeCfgCallback(false, error);
            }
        }
        else if (mActionStatus == ActionType.ACTION_WRITE_CMD)
        {
            mActionStatus = ActionType.ACTION_IDLE;
            if let writeCmdCallback = mWriteCmdCallback
            {
                mWriteCfgCallback = nil;
                writeCmdCallback(false, error);
            }
        }
        else if (mActionStatus == ActionType.ACTION_READ_SENSOR)
        {
            mActionStatus = ActionType.ACTION_IDLE;
            if let readSensorCallback = mReadSensorCallback
            {
                mReadSensorCallback = nil;
                readSensorCallback(false, nil, error);
            }
        }
        else if (mActionStatus == ActionType.ACTION_ENABLE_NTF)
        {
            mActionStatus = ActionType.ACTION_IDLE;
            if let notifyCallback = mEnableSubsribeNotifyCallback
            {
                mEnableSubsribeNotifyCallback = nil;
                notifyCallback(false, error);
            }
        }
    }
    
    private func handleBeaconEnableSubscribeComplete()
    {
        cancelActionTimer()
        
        if let subscribeInstance = mToAddedSubscribeInstance
        {
            self.mNotifyData2ClassMap[mToAddedTriggerType!] = subscribeInstance
            mToAddedSubscribeInstance = nil
            mToAddedTriggerType = 0;
        }
        else
        {
            mNotifyData2ClassMap.removeAll()
        }
        
        //callback
        if let ntfCallback = mEnableSubsribeNotifyCallback {
            mEnableSubsribeNotifyCallback = nil;
            ntfCallback(true, nil)
        }
    }
    
    internal func handleCentralBLEEvent(_ newState: CBPeripheralState)
    {
        if (newState == CBPeripheralState.connected)
        {
            if (self.state == KBConnState.Connecting)
            {
                cbPeripheral!.delegate = self;
                cbPeripheral!.discoverServices(nil)
            }
        }
        else if (newState == CBPeripheralState.disconnected)
        {
            if (self.state == KBConnState.Disconnecting)
            {
                closeBeacon(reason:mCloseReason)
            }
            else if (self.state == KBConnState.Connecting
                        || self.state == KBConnState.Connected)
            {
                closeBeacon(reason: KBConnEvtReason.ConnException)
            }
        }
    }
    
    internal func authStateChange(_ authRslt:KBAuthResult)
    {
        if (authRslt == KBAuthResult.Failed)
        {
            closeBeacon(reason: KBConnEvtReason.ConnAuthFail)
        }
        else if (authRslt == KBAuthResult.Success)
        {
            self.cancelActionTimer()
            print("auth with device\(self.connectionMac!) success\n")
            
            //change to
            if (self.state == KBConnState.Connecting)
            {
                var readCfgTypeNum = 0
                mNextInitReadCfgSubtype = 0
                var firstReadRoundSubType = 0
                
                //common para
                if (mAuthHandler!.connPara.readCommPara){
                    firstReadRoundSubType = (firstReadRoundSubType | KBCfgType.CommonPara)
                    readCfgTypeNum = readCfgTypeNum + 1
                }
                
                //slot adv para
                if (mAuthHandler!.connPara.readSlotPara){
                    firstReadRoundSubType = (firstReadRoundSubType | KBCfgType.AdvPara)
                    readCfgTypeNum = readCfgTypeNum + 1
                }
                
                //trigger para
                if (mAuthHandler!.connPara.readTriggerPara){
                    if (readCfgTypeNum < 2)
                    {
                        firstReadRoundSubType = (firstReadRoundSubType | KBCfgType.TriggerPara)
                    }
                    else
                    {
                        mNextInitReadCfgSubtype = (mNextInitReadCfgSubtype | KBCfgType.TriggerPara)
                    }
                }
                
                //sensor para
                if (mAuthHandler!.connPara.readSensorPara){
                    if (readCfgTypeNum < 2)
                    {
                        firstReadRoundSubType = (firstReadRoundSubType | KBCfgType.SensorPara)
                    }
                    else
                    {
                        mNextInitReadCfgSubtype = (mNextInitReadCfgSubtype | KBCfgType.SensorPara)
                    }
                }
                
                if (firstReadRoundSubType > 0)
                {
                    var readCfgReq = [String:Any]()
                    readCfgReq[KBCfgBase.JSON_MSG_TYPE_KEY] = KBCfgBase.JSON_MSG_TYPE_GET_PARA
                    readCfgReq[KBCfgBase.JSON_FIELD_SUBTYPE] =  firstReadRoundSubType
                    configReadBeaconParamaters(readCfgReq, actionType: ActionType.ACTION_INIT_READ_CFG)
                }
                else
                {
                    //change connection state
                    if self.isSupportSensorDataNotification() && mNotifyData2ClassMap.count > 0
                    {
                        self.startEnableNotification(serviceID: KBUtility.KB_CFG_SERVICES_UUID,
                                                     charID: KBUtility.KB_IND_CHAR_UUID, enable: true)
                    }
                    else
                    {
                        //cancel connection timer
                        if (self.mConnectingTimer?.isValid ?? false)
                        {
                            self.mConnectingTimer?.invalidate()
                        }
                        
                        NSLog("Connect to \(self.connectionMac!) without read para complete");
                        state = KBConnState.Connected
                        
                        self.delegate?.onConnStateChange(self,
                                                         state: state, evt: KBConnEvtReason.ConnSuccess)
                    }
                }
            }
        }
    }
    
    @discardableResult private func configReadBeaconParamaters(_ reqMsg: [String:Any], actionType:ActionType)->Bool
    {
        if let jsonString = KBCfgHandler.cmdParaToJsonString(reqMsg)
        {
            mByDownloaDatas = jsonString.data(using: String.Encoding.utf8)
            mByDownDataType = KBeacon.CENT_PERP_TX_JSON_DATA
            self.mReceiveData.removeAll()
            
            //start action
            startNewAction(action:actionType, timeout: KBeacon.MAX_READ_CFG_TIMEOUT)
            
            return sendNextCfgData(seq: 0)
        }
        
        return false;
    }
    
    
    @discardableResult private func startReadCharatics(_ serviceUUID:CBUUID, charUUID:CBUUID)->Bool
    {
        
        let cbServiceID = KBUtility.findService(peripherial: cbPeripheral, sUUID: serviceUUID)
        if let service = cbServiceID
        {
            let cbCharID = KBUtility.findCharacteristic(cUUID: charUUID, service: service)
            if let cbChar = cbCharID
            {
                cbPeripheral?.readValue(for: cbChar)
                return true
            }
        }
        
        return false
    }
    
    //discover device
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        if (error != nil)
        {
            NSLog("didDiscoverCharacteristicsForService failed, uuid:\(peripheral.identifier.uuidString)");
            
            self.closeBeacon(reason: KBConnEvtReason.ConnException)
            return;
        }
        
        guard let cbServices = peripheral.services else{
            self.closeBeacon(reason: KBConnEvtReason.ConnException)
            return;
        }
        
        //discover characteristic
        for cbService in cbServices
        {
            if (cbService.uuid.isEqual(KBUtility.KB_SYSTEM_SERVICE_UUID))
            {
                peripheral.discoverCharacteristics(nil, for: cbService)
            }
            if (cbService.uuid.isEqual(KBUtility.KB_CFG_SERVICES_UUID))
            {
                peripheral.discoverCharacteristics(nil, for: cbService)
            }
        }
    }
    
    //discover characteristic
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        if (error != nil)
        {
            NSLog("didDiscoverCharacteristicsForService failed, uuid:%s, srvID:%s",
                  peripheral.identifier.uuidString, service.uuid.uuidString);
            
            //send close notify
            self.closeBeacon(reason: KBConnEvtReason.ConnException)
        }
        
        if (service.uuid.isEqual(KBUtility.KB_SYSTEM_SERVICE_UUID))
        {
            //read mac address
            self.startReadCharatics(service.uuid, charUUID: KBUtility.KB_MAC_CHAR_UUID)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
    {
        if (error != nil)
        {
            NSLog("didUpdateNotificationStateForCharacteristic failed, uuid:%s, charID:%s",
                  peripheral.identifier.uuidString,
                  characteristic.uuid.uuidString);
            self.closeBeacon(reason: KBConnEvtReason.ConnException)
            return
        }
        
        //start authentication
        if (characteristic.uuid.isEqual(KBUtility.KB_NTF_CHAR_UUID))
        {
            if (state == KBConnState.Connecting)
            {
                mAuthHandler?.authSendMd5Request(mac:self.connectionMac!)
            }
        }
        else if (characteristic.uuid.isEqual(KBUtility.KB_IND_CHAR_UUID))
        {
            if (state == KBConnState.Connecting)
            {
                //cancel connection timer
                if (self.mConnectingTimer?.isValid ?? false)
                {
                    self.mConnectingTimer?.invalidate()
                }
                
                NSLog("Connect to \(self.connectionMac!) with enable notify complete");
                state = KBConnState.Connected
                self.delegate?.onConnStateChange(self, state: state, evt: KBConnEvtReason.ConnSuccess)
            }
            else
            {
                self.handleBeaconEnableSubscribeComplete()
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        if (error != nil)
        {
            self.closeBeacon(reason: KBConnEvtReason.ConnException)
            return
        }
        guard let data = characteristic.value,
              data.count > 0 else{
            return
        }
        
        //handle notify data
        if (characteristic.uuid.isEqual(KBUtility.KB_MAC_CHAR_UUID))
        {
            //handle read mac address
            self.systemHandleResponse(data:data)
        }
        else if (characteristic.uuid.isEqual(KBUtility.KB_NTF_CHAR_UUID))
        {
            //read data
            let byDataType = UInt8((data[0] >> 4) & 0xF)
            let byFrameType = UInt8(data[0] & 0xF)
            
            if (byDataType == KBeacon.DATA_TYPE_AUTH)
            {
                mAuthHandler?.authHandleResponse(data:data, index: 1)
            }
            else if (byDataType == KBeacon.PERP_CENT_TX_JSON_ACK
                        || byDataType == KBeacon.PERP_CENT_TX_HEX_ACK)
            {
                self.configHandleDownCmdAck(frmType:byFrameType,
                                            dataType: byDataType,
                                            data: data,
                                            index: 1)
            }
            else if (byDataType == KBeacon.PERP_CENT_DATA_RPT
                        || byDataType == KBeacon.PERP_CENT_HEX_DATA_RPT)
            {
                self.configHandleReadDataRpt(frmType:byFrameType,
                                             dataType: byDataType,
                                             data: data,
                                             index: 1)
            }
            
        }
        else if (characteristic.uuid.isEqual(KBUtility.KB_IND_CHAR_UUID))
        {
            //handle notify data
            self.handleBeaconIndData(data:data, index:0)
        }
    }
    
    private func handleBeaconIndData(data:Data, index:Int)
    {
        let dataType = Int(data[index])
        if let sensorInstance = mNotifyData2ClassMap[dataType]
        {
            let range = (index+1)..<data.count
            let data = data.subdata(in: range)
            sensorInstance.onNotifyDataReceived(self, evt:dataType, data:data)
        }
    }
    
    private func configHandleDownCmdAck(frmType:UInt8, dataType:UInt8, data:Data, index:Int)
    {
        var nReadIndex = index
        let dataLen = data.count - index
        if (dataLen < KBeacon.DATA_ACK_HEAD_LEN)
        {
            NSLog("receive a invalid down data ack, len:%d", dataLen)
            return
        }
        let msgBodyLen = dataLen - KBeacon.DATA_ACK_HEAD_LEN
        
        //data sequence
        let nReqDataSeq = (UInt16(data[nReadIndex]) << 8) + UInt16(data[nReadIndex + 1])
        nReadIndex += 2
        
        //skip window
        nReadIndex += 2
        
        //ack sequence
        let AckCause = (UInt16(data[nReadIndex]) << 8) + UInt16(data[nReadIndex + 1])
        nReadIndex += 2
        
        if (AckCause == KBeacon.BEACON_ACK_CAUSE_CMD_RCV)
        {
            NSLog("download command to beacon\(self.connectionMac!) success, wait execute");
            if (dataType == KBeacon.PERP_CENT_TX_JSON_ACK
                || dataType == KBeacon.PERP_CENT_TX_HEX_ACK)
            {
                if (msgBodyLen > 0)
                {
                    mReceiveData = data.subdata(in: nReadIndex..<data.count)
                    
                    //inbound data, send report Ack
                    if (dataType == KBeacon.PERP_CENT_TX_HEX_ACK)
                    {
                        self.configSendDataRptAck(ackSeq: UInt16(mReceiveData.count),
                                                  dataType: UInt8(KBeacon.CENT_PERP_HEX_DATA_RPT_ACK),
                                                  cause: 0)
                    }
                    else
                    {
                        self.configSendDataRptAck(ackSeq: UInt16(mReceiveData.count),
                                                  dataType: UInt8(KBeacon.CENT_PERP_DATA_RPT_ACK),
                                                  cause: 0)
                    }
                }
            }
        }
        else if(AckCause == KBeacon.BEACON_ACK_SUCCESS)
        {
            if (ActionType.ACTION_READ_SENSOR == mActionStatus
                || ActionType.ACTION_INIT_READ_CFG == mActionStatus
                    || ActionType.ACTION_USR_READ_CFG == mActionStatus)
            {
                if (msgBodyLen > 0)
                {
                    mReceiveData = data.subdata(in: nReadIndex..<data.count)
                }
                
                //handle ack data
                if (dataType == KBeacon.PERP_CENT_TX_JSON_ACK)
                {
                    self.handleJsonRptDataComplete()
                }
                else if (dataType == KBeacon.PERP_CENT_TX_HEX_ACK)
                {
                    self.handleHexRptDataComplete()
                }
            }
            else if (ActionType.ACTION_WRITE_CFG == mActionStatus)
            {
                self.cancelActionTimer()
                
                //update config to local
                if (self.mTobeCfgData != nil)
                {
                    mCfgMgr.updateDeviceConfig(mTobeCfgData!)
                    self.mTobeCfgData = nil
                }
                
                //downloa data command complete
                if let writeCallback = mWriteCfgCallback
                {
                    mWriteCfgCallback = nil
                    writeCallback(true, nil)
                }
            }
            else if (ActionType.ACTION_WRITE_CMD == mActionStatus)
            {
                self.cancelActionTimer()
                
                if let writeCallback = mWriteCmdCallback
                {
                    mWriteCmdCallback = nil
                    writeCallback(true, nil)
                }
            }
        }
        else if (AckCause == KBeacon.BEACON_ACK_EXPECT_NEXT)
        {
            if (ActionType.ACTION_IDLE != mActionStatus)
            {
                self.sendNextCfgData(seq: UInt16(nReqDataSeq))
            }
        }
        else if (AckCause == KBeacon.BEACON_ACK_CMD_CMP)
        {
            NSLog("command execute complete");
        }
        else
        {
            let except = KBException(Int(AckCause), desc: "device Ack fail")
            if (ActionType.ACTION_INIT_READ_CFG == mActionStatus)
            {
                self.cancelActionTimer()
                self.closeBeacon(reason: KBConnEvtReason.ConnException)
            }
            else if (ActionType.ACTION_WRITE_CFG == mActionStatus)
            {
                self.cancelActionTimer()
                self.mTobeCfgData = nil
                
                if let writeCallback = mWriteCfgCallback
                {
                    mWriteCfgCallback = nil;
                    writeCallback(false, except)
                }
            }
            else if (ActionType.ACTION_WRITE_CMD == mActionStatus)
            {
                self.cancelActionTimer()
                
                if let writeCallback = mWriteCmdCallback
                {
                    mWriteCmdCallback = nil
                    writeCallback(false, except)
                }
            }
            else if (ActionType.ACTION_USR_READ_CFG == mActionStatus)
            {
                self.cancelActionTimer()
                
                if let readCfgCallback = mReadCfgCallback
                {
                    mReadCfgCallback = nil
                    readCfgCallback(false, nil, except)
                }
            }
            else if (ActionType.ACTION_READ_SENSOR == mActionStatus)
            {
                self.cancelActionTimer()
                
                if let readSendorCallback = mReadSensorCallback
                {
                    mReadSensorCallback = nil;
                    readSendorCallback(false, nil, except)
                }
            }
        }
    }
    
    private func configHandleReadDataRpt(frmType:UInt8, dataType:UInt8, data:Data, index:Int)
    {
        var bRcvDataCmp = false;
        var readIndex = index
        let msgBodyLen = data.count - 2
        if (data.count - index < 2 || msgBodyLen < 1)
        {
            NSLog("invalid report data length")
            return
        }
        
        let nDataSeq = (UInt16(data[readIndex]) << 8) + UInt16(data[readIndex + 1])
        readIndex += 2
        print("device receive sequence data:\(nDataSeq)\n")
        
        //frame start
        if (frmType == KBeacon.PDU_TAG_START)
        {
            //new read configruation
            mReceiveData = data.subdata(in: readIndex..<data.count)
            self.configSendDataRptAck(ackSeq: UInt16(mReceiveData.count),
                                      dataType: dataType,
                                      cause: 0)
        }
        else if (frmType == KBeacon.PDU_TAG_MIDDLE)
        {
            if (nDataSeq != mReceiveData.count)
            {
                print("device recieve an unexpected middle packet, expect seq:\(mReceiveData.count), received seq:\(nDataSeq)")
                configSendDataRptAck(ackSeq: UInt16(mReceiveData.count), dataType: dataType, cause: 0x1)
            }
            else
            {
                let segData = data.subdata(in: readIndex..<data.count)
                mReceiveData.append(segData)
                self.configSendDataRptAck(ackSeq: UInt16(mReceiveData.count),
                                          dataType: dataType,
                                          cause: 0)
            }
        }
        else if (frmType == KBeacon.PDU_TAG_END)
        {
            if (nDataSeq != mReceiveData.count)
            {
                print("device recieve an unexpected end packet, expect seq:\(mReceiveData.count), received seq:\(nDataSeq)")
                configSendDataRptAck(ackSeq: UInt16(mReceiveData.count), dataType: dataType, cause: 0x1)
            }
            else
            {
                let segData = data.subdata(in: readIndex..<data.count)
                mReceiveData.append(segData)
                self.configSendDataRptAck(ackSeq: UInt16(mReceiveData.count),
                                          dataType: dataType,
                                          cause: 0)
                bRcvDataCmp = true
            }
        }
        else if (frmType == KBeacon.PDU_TAG_SINGLE)
        {
            //new read message command
            mReceiveData = data.subdata(in: readIndex..<data.count)
            //[self configSendDataRptAck: mReceiveData.length dataType:dataType  cause: 0];
            bRcvDataCmp = true;
        }
        
        if (bRcvDataCmp)
        {
            if (dataType == KBeacon.PERP_CENT_DATA_RPT)
            {
                self.handleJsonRptDataComplete()
            }
            else if (dataType == KBeacon.PERP_CENT_HEX_DATA_RPT)
            {
                self.handleHexRptDataComplete()
            }
        }
    }
    
    private func handleHexRptDataComplete()
    {
        self.cancelActionTimer()
        if let readCallback = mReadSensorCallback
        {
            mReadSensorCallback = nil
            readCallback(true, mReceiveData, nil)
        }
    }
    
    private func handleJsonRptDataComplete()
    {
        let jsonPara = try? JSONSerialization.jsonObject(with: mReceiveData,
                                                         options:.allowFragments)
        if let dictRcvData = jsonPara as? [String: Any]
        {
            if (mActionStatus == ActionType.ACTION_INIT_READ_CFG)
            {
                //cancel action timer
                self.cancelActionTimer()
                
                //get configruation
                mCfgMgr.updateDeviceCfgFromJsonObject(dictRcvData)
                
                //check if has no read information
                if (mNextInitReadCfgSubtype != 0) {
                    var readCfgReq = [String:Any]()
                    readCfgReq[KBCfgBase.JSON_MSG_TYPE_KEY] = KBCfgBase.JSON_MSG_TYPE_GET_PARA
                    readCfgReq[KBCfgBase.JSON_FIELD_SUBTYPE] = mNextInitReadCfgSubtype
                    mNextInitReadCfgSubtype = 0
                    configReadBeaconParamaters(readCfgReq, actionType: ActionType.ACTION_INIT_READ_CFG)
                }else {
                    //change connection state
                    if self.isSupportSensorDataNotification() && mNotifyData2ClassMap.count > 0
                    {
                        self.startEnableNotification(serviceID: KBUtility.KB_CFG_SERVICES_UUID,
                                                     charID: KBUtility.KB_IND_CHAR_UUID, enable: true)
                    }
                    else
                    {
                        NSLog("Connect to \(self.connectionMac!) without enable notify complete");
                        
                        //cancel connection timer
                        //cancel connection timer
                        if (self.mConnectingTimer?.isValid ?? false)
                        {
                            self.mConnectingTimer?.invalidate()
                        }
                        
                        self.state = KBConnState.Connected
                        self.delegate?.onConnStateChange(self,
                                                         state: state, evt: KBConnEvtReason.ConnSuccess)
                    }
                }
            }
            else if (mActionStatus == ActionType.ACTION_USR_READ_CFG)
            {
                self.cancelActionTimer()
                
                if let readCfgCallback = mReadCfgCallback
                {
                    //get configruation
                    mCfgMgr.updateDeviceCfgFromJsonObject(dictRcvData)
                    
                    mReadCfgCallback = nil;
                    readCfgCallback(true, dictRcvData, nil);
                }
            }
            else
            {
                self.cancelActionTimer()
                NSLog("Unknown message receive");
            }
        }
        else
        {
            NSLog("Parse Json response failed");
            if (mActionStatus == ActionType.ACTION_INIT_READ_CFG)
            {
                self.closeBeacon(reason: KBConnEvtReason.ConnException)
            }
            else if (mActionStatus == ActionType.ACTION_USR_READ_CFG)
            {
                self.cancelActionTimer()
                
                if let readCfgCallback = mReadCfgCallback
                {
                    mReadCfgCallback = nil;
                    readCfgCallback(false, nil, KBException(KBErrorCode.CfgReadNull, desc: "Parse message from device failed"));
                }
            }
        }
    }
    
    private func configSendDataRptAck(ackSeq:UInt16, dataType:UInt8, cause:UInt16)
    {
        var ackDataBuff = Data()
        
        //ack head
        var byAckHead = UInt8(dataType << 4)
        byAckHead += UInt8(KBeacon.PDU_TAG_SINGLE)
        ackDataBuff.append(byAckHead)
        
        //ack seq
        ackDataBuff.append(UInt8(ackSeq >> 8))
        ackDataBuff.append(UInt8(ackSeq & 0xFF))
        
        //windows
        let window = UInt16(1000)
        ackDataBuff.append(UInt8(window >> 8))
        ackDataBuff.append(UInt8(window & 0xFF))
        
        //cause
        ackDataBuff.append(UInt8(cause >> 8))
        ackDataBuff.append(UInt8(cause & 0xFF))
        
        self.startWriteCfgValue(data: ackDataBuff)
    }
    
    
    @discardableResult private func sendNextCfgData(seq nReqDataSeq:UInt16)->Bool
    {
        guard let downDatas = mByDownloaDatas,
              let authHandler = mAuthHandler,
              let downDataType = mByDownDataType,
              downDatas.count > 0 else{
            NSLog("data not inited");
            return false;
        }
        
        
        guard nReqDataSeq < downDatas.count else{
            NSLog("tx config data cmplete");
            return true;
        }
        
        //get mdu tag
        let nMaxTxDataSize = authHandler.mtuSize - KBeacon.MSG_PDU_HEAD_LEN
        var nDataLen = nMaxTxDataSize
        var nPduTag = KBeacon.PDU_TAG_START
        if (downDatas.count <= nMaxTxDataSize)
        {
            nPduTag = KBeacon.PDU_TAG_SINGLE
            nDataLen = downDatas.count
        }
        else if (nReqDataSeq == 0)
        {
            nPduTag = KBeacon.PDU_TAG_START;
            nDataLen = nMaxTxDataSize;
        }
        else if (Int(nReqDataSeq) + nMaxTxDataSize < downDatas.count)
        {
            nPduTag = KBeacon.PDU_TAG_MIDDLE;
            nDataLen = nMaxTxDataSize;
        }
        else if (Int(nReqDataSeq) + nMaxTxDataSize >= downDatas.count)
        {
            nPduTag = KBeacon.PDU_TAG_END;
            nDataLen = downDatas.count - Int(nReqDataSeq);
        }
        
        //down data head
        var txData = Data()
        
        //head
        let byAduTag = UInt8((downDataType << 4) + nPduTag)
        txData.append(byAduTag)
        
        //sequence
        txData.append(UInt8((nReqDataSeq >> 8) & 0xFF))
        txData.append(UInt8(nReqDataSeq & 0xFF))
        
        //fill body data
        let endSeq = Int(nReqDataSeq) + nDataLen
        let range = (Int(nReqDataSeq)..<endSeq)
        let msgBody = downDatas.subdata(in: range)
        txData.append(msgBody)
        
        //write data to device
        return startWriteCfgValue(data: txData)
    }
    
    //write configruation to beacon
    @discardableResult private func startWriteCfgValue(data:Data)->Bool
    {
        let cbServiceID = KBUtility.findService(peripherial: cbPeripheral, sUUID: KBUtility.KB_CFG_SERVICES_UUID)
        if let service = cbServiceID
        {
            let cbCharID = KBUtility.findCharacteristic(cUUID: KBUtility.KB_WRITE_CHAR_UUID, service: service)
            if let cbChar = cbCharID
            {
                cbPeripheral?.writeValue(data, for: cbChar, type: CBCharacteristicWriteType.withoutResponse)
                return true
            }
        }
        
        NSLog("Found write services/characteristic failed")
        return false
    }
    
    internal func writeAuthData(_ data: Data)
    {
        self.startWriteCfgValue(data: data)
    }
    
    internal func closeBeacon(reason:KBConnEvtReason)
    {
        mCloseReason = reason
        
        //clear action timer
        self.cancelActionTimer()
        
        //cancel connecting timer
        if (self.mConnectingTimer?.isValid ?? false)
        {
            self.mConnectingTimer?.invalidate()
        }
        if (self.mDisconnectingTimer?.isValid ?? false)
        {
            self.mDisconnectingTimer?.invalidate()
        }
        
        //cancel connect
        if let peripheral = cbPeripheral,
           peripheral.state == CBPeripheralState.connecting
            || peripheral.state == CBPeripheralState.connected
        {
            NSLog("Disconnecting kbeacon for reason:%d", reason.rawValue);
            
            //start cancel connection
            self.mBeaconMgr?.cbBeaconMgr .cancelPeripheralConnection(peripheral)
            
            //start disconn timer
            self.mDisconnectingTimer = Timer.scheduledTimer(timeInterval: 7.0,
                                             target: self,
                                             selector: #selector(disconnectingTimeout(_:)),
                                             userInfo: nil,
                                             repeats: false)
            
            //notify
            if (state != KBConnState.Disconnecting)
            {
                state = KBConnState.Disconnecting
                self.delegate?.onConnStateChange(self, state: state, evt: mCloseReason)
            }
        }
        else
        {
            if (state != KBConnState.Disconnected)
            {
                NSLog("Disconnected kbeacon for reason:%d", mCloseReason.rawValue);
                state = KBConnState.Disconnected;
                self.delegate?.onConnStateChange(self, state: state, evt: mCloseReason)
            }
        }
    }
    
    private func systemHandleResponse(data:Data)
    {
        guard let peripherial = cbPeripheral,
              (data.count == 6 || data.count == 8) else
        {
            NSLog("mac address length error");
            self.closeBeacon(reason: KBConnEvtReason.ConnServiceNotSupport)
            return;
        }
        
        var byMacValue = [UInt8](data)
        if (byMacValue.count == 8)
        {
            byMacValue[3] = byMacValue[5];
            byMacValue[4] = byMacValue[6];
            byMacValue[5] = byMacValue[7];
        }
        
        self.connectionMac = String(format:"%02X:%02X:%02X:%02X:%02X:%02X",
                          byMacValue[5],
                          byMacValue[4],
                          byMacValue[3],
                          byMacValue[2],
                          byMacValue[1],
                          byMacValue[0])
        
        //save uuid and mac mapping
        let strMacKey = "kb_\(peripherial.identifier.uuidString)"
        UserDefaults.standard.setValue(self.connectionMac, forKey: strMacKey)
        
        //start auth entication
        if (state == KBConnState.Connecting)
        {
            self.startEnableNotification(serviceID: KBUtility.KB_CFG_SERVICES_UUID, charID: KBUtility.KB_NTF_CHAR_UUID, enable: true)
        }
    }
    
 
}
