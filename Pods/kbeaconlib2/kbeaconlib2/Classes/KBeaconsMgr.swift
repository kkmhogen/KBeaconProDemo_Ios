//
//  KbeaconsMgr.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/15.
//

import Foundation
import CoreBluetooth

let MAX_TIMER_OUT_INTERVAL = 0.3;

//scan filter type
@objc public enum BLECentralMgrState:Int
{
    case PowerOn = 0
    case PowerOff = 1
    case Unauthorized = 2
    case Unknown = 3
}

//scan filter type
@objc public enum KBScanFilter:Int
{
    case Rssi = 0
    case ServicesID = 1
}

//found beacon delegation
@objc public protocol KBeaconMgrDelegate: NSObjectProtocol
{
    @objc func onBeaconDiscovered(beacons:[KBeacon]) //found new beacon device

    @objc func onCentralBleStateChange(newState:BLECentralMgrState) //central bel state change
}

@objc public class KBeaconsMgr : NSObject, CBCentralManagerDelegate
{
    //scan result delegate
    @objc public weak var delegate : KBeaconMgrDelegate?
    
    //min rssi filter
    @objc public var scanMinRssiFilter : Int
    
    //advType filter
    @objc public var scanAdvTypeFilter : KBAdvType?

    //ble central manager
    @objc public var cbBeaconMgr: CBCentralManager  //esl device manager
    
    //share instance
    @objc public static let sharedBeaconManager = KBeaconsMgr()

    //recognize beacons
    @objc public var beacons:Dictionary<String, KBeacon>
    
    //name filter
    private var scanNameFilter : String?
    private var scanNameIgnoreCase : Bool = true
    private var scanNameMatchWord : Bool = true
    
    private var  mPeriodTimer : Timer?
    
    private var mScanFilterNameCaseIgnore = true;
    
    //all beacons, include kkm beacons and other unknown beacons
    private var mCbAllBeacons:Dictionary<String, KBeacon>
    
    //the beacon that need notify to ui
    private var mCBNtfBeacons:Dictionary<String, KBeacon>

    
    //init instance
    private override init(){
        cbBeaconMgr = CBCentralManager()
        beacons = [String : KBeacon]()
        mCBNtfBeacons = [String : KBeacon]()
        mCbAllBeacons = [String : KBeacon]()
        scanMinRssiFilter = -100
    }

    //clear all beacon
    @objc public func clearBeacons()
    {
        for (_,value) in beacons{
            value.disconnect()
        }
        
        beacons.removeAll()
        
        //clear all scaned ble device
        mCbAllBeacons.removeAll()
                
        //clear notify list
        mCBNtfBeacons.removeAll()
    }
    
    
    //scanning beacon
    @objc @discardableResult public func startScanning()->Bool
    {
        //check if ble function enable
        if (self.centralBLEState == BLECentralMgrState.Unauthorized
                || self.centralBLEState == BLECentralMgrState.PowerOff
                || self.centralBLEState == BLECentralMgrState.Unknown)
        {
            return false
        }
        
        //stop privous scan
        cbBeaconMgr.stopScan()
        cbBeaconMgr.delegate = self
        
        //scan option
        let scanOption = [CBCentralManagerScanOptionAllowDuplicatesKey:NSNumber(true)]
        
        //set scan filter
        let filterSrvList = [KBUtility.PARCE_UUID_KB_EXT_DATA, KBUtility.PARCE_UUID_EDDYSTONE]
        cbBeaconMgr.scanForPeripherals(withServices: filterSrvList, options: scanOption)
        NSLog("start central ble device scanning");
        
        return true;
    }
    
    //scanning beacon
    @objc @discardableResult public func startScanningAllDevice()->Bool
    {
        //check if ble function enable
        if (self.centralBLEState == BLECentralMgrState.Unauthorized
                || self.centralBLEState == BLECentralMgrState.PowerOff
                || self.centralBLEState == BLECentralMgrState.Unknown)
        {
            return false
        }
        
        //stop privous scan
        cbBeaconMgr.stopScan()
        cbBeaconMgr.delegate = self
        
        //scan option
        let scanOption = [CBCentralManagerScanOptionAllowDuplicatesKey:NSNumber(true)]
        
        //set scan filter
        cbBeaconMgr.scanForPeripherals(withServices: nil, options: scanOption)
        NSLog("start central ble device scanning");
        
        return true;
    }
    
    //check if is scanning
    @objc public var isScanning:Bool{
        get{
            return cbBeaconMgr.isScanning
        }
    }

    @objc public func stopScanning()->Void
    {
        NSLog("stop central ble device scanning")
        
        cbBeaconMgr.stopScan()
    }

    //scan name filter
    @objc public func setScanNameFilter(filterName:String, ignoreCase:Bool=true, matchWord:Bool=false)
    {
        scanNameFilter = filterName
        scanNameIgnoreCase = ignoreCase
        scanNameMatchWord = matchWord
    }
    
    //set adv decode password
    @objc @discardableResult public func saveBeaconPassword(_ uuid:String, password pwd:String)->Bool
    {
        if (pwd.count >= 8 && pwd.count <= 16)
        {
            let mPrefCfg = KBPreferance.sharedPreferance
            mPrefCfg.savePassword(uuid, password: pwd)
            return true
        }
        
        return false
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        var nRssi:Int8
        
        //rssi
        if RSSI.intValue < -100 || RSSI.intValue > 20{
            nRssi = -100
        }else{
            nRssi = Int8(RSSI.intValue)
        }
 
        //filter
        if nRssi < scanMinRssiFilter
        {
            return;
        }
        
        //name filter
        if let cfgNameFilter = scanNameFilter, cfgNameFilter.count > 1
        {
            if let strAdvName = advertisementData["kCBAdvDataLocalName"] as? String
            {
                var advName = strAdvName
                var filterName = cfgNameFilter
                if scanNameIgnoreCase
                {
                    advName = strAdvName.lowercased()
                    filterName = cfgNameFilter.lowercased()
                }
                
                if !scanNameMatchWord
                {
                    if !advName.contains(filterName)
                    {
                        return
                    }
                }
                else
                {
                    if advName.compare(filterName) != .orderedSame
                    {
                        return
                    }
                }
            }
            else
            {
                return;
            }
        }
        
        let uuidString = peripheral.identifier.uuidString
        if advertisementData.count > 0
        {
            var pUnknownBeacon = self.mCbAllBeacons[uuidString]
            if pUnknownBeacon == nil
            {
                pUnknownBeacon = KBeacon()
                mCbAllBeacons[uuidString] = pUnknownBeacon
            }
            
            if (pUnknownBeacon!.parseAdvPacket(advData: advertisementData, rssi:nRssi, uuid:peripheral.identifier.uuidString))
            {
                if beacons[uuidString] == nil
                {
                    beacons[uuidString] = pUnknownBeacon
                }
                //peripheral will be release after some time
                pUnknownBeacon!.attach2Device(peripheral: peripheral, beaconMgr: self)
                //add to beacon notify list
                mCBNtfBeacons[uuidString] = pUnknownBeacon
                
                if mPeriodTimer == nil || !mPeriodTimer!.isValid
                {
                    mPeriodTimer = Timer.scheduledTimer(timeInterval: MAX_TIMER_OUT_INTERVAL,
                                         target: self,
                                         selector: #selector(delayReportAdvTimer(_:)),
                                         userInfo: nil,
                                         repeats: false)
                }
            }
        }
    }
    
    @objc internal func delayReportAdvTimer(_ timer:Timer)->Void
    {
        if (self.mCBNtfBeacons.count > 0)
        {
            var ntfBeacons = [KBeacon]()
            for (_, beacon) in self.mCBNtfBeacons {
                ntfBeacons.append(beacon)
            }
            
            //call back
            self.delegate?.onBeaconDiscovered(beacons: ntfBeacons)
            
            //remove notify
            self.mCBNtfBeacons.removeAll()
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        NSLog("central manager disconnection to device:%s", peripheral.identifier.uuidString);
        if let pBeacon = self.beacons[peripheral.identifier.uuidString]
        {
            pBeacon.handleCentralBLEEvent(CBPeripheralState.disconnected)
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        NSLog("central manager connect to gatt:\(peripheral.identifier.uuidString) success");
        
        if let pBeacon = self.beacons[peripheral.identifier.uuidString]
        {
            pBeacon.handleCentralBLEEvent(peripheral.state)
        }
        else
        {
            cbBeaconMgr.cancelPeripheralConnection(peripheral)
        }
    }
    
    @objc public var centralBLEState: BLECentralMgrState
    {
        get
        {
            if (self.cbBeaconMgr.state == CBManagerState.poweredOn)
            {
                return BLECentralMgrState.PowerOn;
            }
            else if (self.cbBeaconMgr.state == CBManagerState.poweredOff
                        || self.cbBeaconMgr.state == CBManagerState.resetting)
            {
                return BLECentralMgrState.PowerOff;
            }
            else if (self.cbBeaconMgr.state == CBManagerState.unauthorized)
            {
                return BLECentralMgrState.Unauthorized;
            }
            else
            {
                return BLECentralMgrState.Unknown;
            }
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        NSLog("Status of CoreBluetooth central manager changed\(central.state)")
        guard let callBack = self.delegate else
        {
            return
        }
        
        switch central.state
        {
        case CBManagerState.poweredOn:
            callBack.onCentralBleStateChange(newState: BLECentralMgrState.PowerOn)
                
        case CBManagerState.poweredOff, CBManagerState.resetting:
            callBack.onCentralBleStateChange(newState: BLECentralMgrState.PowerOff)
                
        case CBManagerState.unauthorized:
            callBack.onCentralBleStateChange(newState: BLECentralMgrState.Unauthorized)
        
        default:
            callBack.onCentralBleStateChange(newState: BLECentralMgrState.Unknown)
        }
    }
}
