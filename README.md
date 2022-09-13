#KBeacon IOS SDK Instruction DOC（English）

----
## 1. Introduction
With this SDK, you can scan and configure the KBeacon device. The SDK include follow main class:
* KBeaconsMgr: Global definition, responsible for scanning KBeacon devices advertisement packet, and monitoring the Bluetooth status of the system;

* KBeacon: An instance of a KBeacon device, KBeaconsMgr creates an instance of KBeacon while it found a physical device. Each KBeacon instance has three properties: KBAdvPacketHandler, KBAuthHandler, KBCfgHandler.

* KBAdvPacketHandler: parsing advertisement packet. This attribute is valid during the scan phase.

* KBAuthHandler: Responsible for the authentication operation with the KBeacon device after the connection is established.

* KBCfgHandler：Responsible for configuring parameters related to KBeacon devices
* DFU Library: Responsible for KBeacon firmware update.
![avatar](https://github.com/kkmhogen/KBeaconProDemo_Android/blob/main/kbeacon_class_arc.png?raw=true)

**Scanning Stage**

in this stage, KBeaconsMgr will scan and parse the advertisement packet about KBeacon devices, and it will create "KBeacon" instance for every founded devices, developers can get all advertisements data by its allAdvPackets or getAdvPacketByType function.

**Connection Stage**

After a KBeacon connected, developer can make some changes of the device by modifyConfig.


## 2. IOS demo
To make your development easier, we have an IOS demos in GitHub. They are:  
* KBeaconProDemo_Ios: The app can scan KBeacon devices and configure iBeacon related parameters.


## 3. Import SDK to project
### 3.1 Prepare
Development environment:  
min IOS Version 11.0

### 3.2 Import SDK
kbeaconlib2 is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'kbeaconlib2','1.0.8'
```
This library is also open source, please refer to this link.  
[kbeaconlib](https://github.com/kkmhogen/kbeaconlib2)  

2. Add the Bluetooth permissions declare in your project plist file (Target->Info). As follows:  
* Privacy - Bluetooth Always Usage Description
* Privacy - Bluetooth Peripheral Usage Description


## 4. How to use SDK
### 4.1 Scanning device
1. Initialize KBeaconMgr instance in Activity, also your application should implementation the KBeaconMgr's KBeaconMgrDelegate.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    mBeaconsMgr = KBeaconsMgr.sharedBeaconManager
    mBeaconsMgr!.delegate = self
    ...
}
```

2. Implementation KBeaconMgrDelegate   

```swift
func onBeaconDiscovered(beacons:[KBeacon])
{
    for beacon in beacons
    {
        //found device
        ...
    }

    beaconsTableView.reloadData()
}

func onCentralBleStateChange(newState:BLECentralMgrState)
{
    if (newState == BLECentralMgrState.PowerOn)
    {
        //the app can start scan in this case
        NSLog("central ble state power on")
    }
}
```

3. Start scanning  
After app startup, the BLE state was set to unknown, so the app should wait a few milliseconds before start scanning.

```swift
  let scanResult = mBeaconsMgr!.startScanning()
  if (scanResult)
  {
      NSLog("start scan success");
      self.mScanButton.title = NSLocalizedString("ACTION_STOP_SCAN", comment:"")
  }
  else
  {
      NSLog("start scan failed");
  }
```

4. Implementation KBeaconMgr delegate to get scanning result.  
The SDK will cache the last packet of each advertisement type that it scans, and it may cache up to 6 packet (iBeacon, URL, TLM, UID, KSensor, System). the application can call removeAdvPacket() in onBeaconDiscovered to delete the cached packet.
```swift
//example for print all scanned packet
func onBeaconDiscovered(beacons:[KBeacon])
{
    for beacon in beacons
    {
        printScanPacket(beacon)
    }
}

func printScanPacket(_ advBeacon: KBeacon)
{
    //check if has packet
    guard let allAdvPackets = advBeacon.allAdvPackets else{
        return
    }

    print("--------scan device advertisment packet---------")


    for advPacket in allAdvPackets
    {
        switch advPacket.getAdvType()
        {
        case KBAdvType.IBeacon:
            //get majorID and minorID from advertisement packet
            //notify: this is not standard iBeacon protocol, we get minor ID from KKM private
            //scan response message
            if let iBeaconAdv = advPacket as? KBAdvPacketIBeacon
            {
                print("-----iBeacon----")
                print("major:\(iBeaconAdv.majorID)")
                print("minor:\(iBeaconAdv.minorID)")
            }
        case KBAdvType.EddyURL:
            if let urlAdv = advPacket as? KBAdvPacketEddyURL
            {
                print("-----URL----")
                print("url:\(urlAdv.url)")
            }

        case KBAdvType.EddyUID:
            if let uidAdv = advPacket as? KBAdvPacketEddyUID
            {
                print("-----UID----")
                print("nid:\(uidAdv.nid ?? "")")
                print("nid:\(uidAdv.sid ?? "")")
            }

        case KBAdvType.EddyTLM:
            if let tlmAdv = advPacket as? KBAdvPacketEddyTLM
            {
                print("-----TLM----")
                print("secondCount:\(tlmAdv.secCount/10)")
                print("batt:\(tlmAdv.batteryLevel)")
                print("temp:\(tlmAdv.temperature)")
                print("temp:\(tlmAdv.temperature)")
            }

        case KBAdvType.Sensor:
            if let sensorAdv = advPacket as? KBAdvPacketSensor
            {
                print("-----Sensor----")
                print("batt:\(sensorAdv.batteryLevel)")

                if (sensorAdv.temperature != KBCfgBase.INVALID_FLOAT)
                {
                    print("temp:\(sensorAdv.temperature)")
                }
                if (sensorAdv.humidity != KBCfgBase.INVALID_FLOAT)
                {
                    print("humidity:\(sensorAdv.humidity)")
                }

                //acc sensor
                if let axisValue = sensorAdv.accSensor
                {
                    print("  xAis:\(axisValue.xAis)")
                    print("  yAis:\(axisValue.yAis)")
                    print("  zAis:\(axisValue.zAis)")
                }
            }

        case KBAdvType.System:
            if let systemAdv = advPacket as? KBAdvPacketSystem
            {
                print("-----System----")
                print("mac:\(systemAdv.macAddress!)")
                print("batt:\(systemAdv.batteryPercent)")
                print("modelNo:\(systemAdv.model)")
                print("ver:\(systemAdv.firmwareVersion)")
            }
        default:
            print("unknown packet")
        }
    }

    //remove buffered packet
    advBeacon.removeAdvPacket()
}
```

4. Clean scanning result and stop scanning  
After start scanning, The KBeaconMgr will buffer all found KBeacon device. If the app want to remove all buffered KBeacon device, the app can:  

```swift
mBeaconsMgr!.clearBeacons()
```

If the app wants to stop scanning:
```swift
mBeaconsMgr!.stopScanning()
```

### 4.2 Connect to device
 1. If the app wants to change the device parameters, then it need connect to the device.
 ```swift
 //connect to device with default parameters
self.beacon!.connect(beaconPwd, timeout: 15.0, delegate: self)
//or
//connect to device with specified parameters
//When the app is connected to the KBeacon device, the app can specify which the configuration parameters to be read,
//The parameter that can be read include: common parameters, advertisement parameters, trigger parameters, and sensor parameters
let connPara = KBConnPara()
connPara.syncUtcTime = true  //sync the phone's time to device
connPara.readCommPara = true   //only read basic parameters (KBCfgCommon)
connPara.readTriggerPara = false //not read trigger parameters
connPara.readSlotPara = false    //not read advertisement parameters
connPara.readSensorPara = false
self.beacon!.connectEnhanced(beaconPwd, timeout: 15.0, connPara: connPara, delegate: self)
```
* Password: device password, the default password is 0000000000000000
* timeout: max connection time, unit is second.

2. the app should implementation the KBeacon's delegate for get connection status:
 ```swift
func onConnStateChange(_ beacon:KBeacon, state:KBConnState, evt:KBConnEvtReason)
{
    if (state == KBConnState.Connecting)
    {
        self.txtBeaconStatus.text = "Connecting to device";
    }
    else if (state == KBConnState.Connected)
    {
        self.txtBeaconStatus.text = "Device connected";

        self.updateDeviceToView()
    }
    else if (state == KBConnState.Disconnected)
    {
        self.txtBeaconStatus.text = "Device disconnected";
        if (evt == KBConnEvtReason.ConnAuthFail)
        {
            NSLog("auth failed");
            self.showPasswordInputDlg(self.beacon!)
        }
    }

    ...
}
 ```

3. Disconnect from the device.
 ```swift
self.beacon!.disconnect()
 ```

### 4.3 Configure parameters
#### 4.3.1 Advertisement type
KBeacon devices can support broadcasting multiple type advertisement packets in parallel.  
For example, advertisement type was set to “iBeacon + TLM + System”, then the device will send advertisement packet like follow.   

|Slot No.|0|1|2|3|4|
|----|----|----|----|----|----|
|`Adv type`|iBeacon|TLM |System|None|None|
|`Adv Mode`|Legacy|Coded PHY|2M PHY|Legacy|Legacy|
|`Adv Interval(ms)`|1022.5|8000.0|8000.0|NA|NA|
|`Tx power(dBm)`|0|4|-12|NA|NA|



**Notify:**  
  For the advertisement period, Apple has some suggestions that make the device more easily discovered by IOS phones. (The suggest value was: 152.5 ms; 211.25 ms; 318.75 ms; 417.5 ms; 546.25 ms; 760 ms; 852.5 ms; 1022.5 ms; 1285 ms). For more information, please refer to Section 3.5 in "Bluetooth Accessory Design Guidelines for Apple Products". The document link: https://developer.apple.com/accessories/Accessory-Design-Guidelines.pdf.


#### 4.3.2 Get device parameters
After the app connect to KBeacon success. The KBeacon will automatically read current parameters from physical device. so the app can update UI and show the parameters to user after connection setup.  
 ```swift
 func onConnStateChange(_ beacon:KBeacon, state:KBConnState, evt:KBConnEvtReason)
 {
     ...
     if (state == KBConnState.Connected)
     {
       self.updateActionButton()
     }
     ...
 }

//update device's configuration to UI
func updateDeviceToView()
{
    //if the device had read common parameters and advertisement parameters during connection,
    //then the app can print the parameters
    if let pCommonCfg = self.beacon!.getCommonCfg()
    {
        print("support max adv slot:\(pCommonCfg.getMaxSlot())")
        print("support max trigger:\(pCommonCfg.getMaxTrigger())")
        print("support iBeacon adv:\(pCommonCfg.isSupportIBeacon())")
        print("support eddy URL adv:\(pCommonCfg.isSupportEddyURL())")
        print("support eddy TLM adv:\(pCommonCfg.isSupportEddyTLM())")
        print("support eddy UID adv :\(pCommonCfg.isSupportEddyUID())")
        print("support KSensor adv:\(pCommonCfg.isSupportKBSensor())")
        print("support System adv:\(pCommonCfg.isSupportKBSystem())")
        print("support button:\(pCommonCfg.isSupportButton())")
        print("support beep:\(pCommonCfg.isSupportBeep())")
        print("support accleration:\(pCommonCfg.isSupportAccSensor())")
        print("support humidify:\(pCommonCfg.isSupportHumiditySensor())")
        print("support max Tx power:\(pCommonCfg.getMaxTxPower())")
        print("support min Tx power:\(pCommonCfg.getMinTxPower())")

        //adv type list
        if let advSlotList = self.beacon!.getSlotCfgList(){
            var advTypeDescs = ""
            for advSlot in advSlotList{
                let advDesc = KBAdvType.getAdvTypeString(advSlot.getAdvType())
                let slotIndex = advSlot.getSlotIndex()
                advTypeDescs = "\(advTypeDescs) | slot:\(slotIndex):\(advDesc)"
            }
            self.labelBeaconType.text = advTypeDescs
        }

        self.txtName.text = pCommonCfg.getName()
        self.labelModel.text = pCommonCfg.getModel()
        self.labelVersion.text = pCommonCfg.getVersion()
        self.mLabelHardwareVersion.text = pCommonCfg.getHardwareVersion()

        //check if has iBeacon advertisement para
        if let iBeaconList = self.beacon!.getSlotCfgByAdvType(KBAdvType.IBeacon),
           let firstIBeaconAdv = iBeaconList[0] as? KBCfgAdvIBeacon
        {
            self.txtTxPower.text = "\(firstIBeaconAdv.getTxPower())"
            self.txtAdvPeriod.text = "\(firstIBeaconAdv.getAdvPeriod())"
            self.txtBeaconUUID.text = "\(firstIBeaconAdv.getUuid() ?? "")"
            self.txtBeaconMajor.text = "\(firstIBeaconAdv.getMajorID())"
            self.txtBeaconMinor.text = "\(firstIBeaconAdv.getMinorID())"
        }
        else
        {
            print("does not found iBeacon configruation in device")
        }
    }
    else
    {
        print("get common parameters failed, maybe the app does not requesting read common paramaters")
    }
}
 ```

#### 4.3.3 Update advertisement parameters

After app connects to device success, the app can update parameters of device.

##### 4.3.3.1 Update common parameters
The app can modify the basic parameters of KBeacon through the KBCfgCommon class. The KBCfgCommon has follow parameters:
* name: device name, the device name must <= 18 character
* alwaysPowerOn: if alwaysPowerOn was setting to true, the beacon will not allowed turn off by long press button.
* refPower1Meters: the rx power at 1 meters
* password: device password, the password length must >= 8 character and <= 16 character.  
 **Warning:**   
 Be sure to remember the new password, you won’t be able to connect to the device if you forget the new password.

Example: Update common parameters
```swift
func updateCommPara()
{
    let commCfg = KBCfgCommon()

    //check if parameters was changed
    if (txtName.tag == DeviceViewController.TXT_DATA_MODIFIED),
       let newName = txtName.text,
       newName.count > 0
    {
        commCfg.setName(newName)
    }
    else
    {
        print("no need configruation")
        return
    }

    //set device to always power on
    //the autoAdvAfterPowerOn is enable, the device will not allowed power off by long press button
    commCfg.setAlwaysPowerOn(true)

    self.beacon!.modifyConfig(obj: commCfg, callback: { (result, exception) in
        if (result)
        {
            print("config common para success")
        }
        else
        {
            print("config common para failed");
        }
    })
}
```

##### 4.3.3.2 Update iBeacon parameters
For all broadcast messages, such as iBeacon or Eddystone protocols, they include the following public parameters：
* slotIndex: the advertisement instance No.
* txPower: the tx power of the advertisement packet.
* advType: advertisement type, can be setting to iBeacon, KSesnor, Eddy TLM/UID/ etc.,
* advPeriod: this slot advertisement period, the value can be set to 100~20000ms
* advMode : advertisement mode.
* advTriggerOnly : When it is true, it means that this slot is not broadcast by default, it is only start broadcast when the Trigger event occurs.
* advConnectable: is this slot advertisement can be connectable.  
 **Warning:**   
If all slot was setting to un-connectable, the app cannot connect to it again unless: 1. The KBeacon button was pressed while button trigger are not enable. or 2. The device was power on again and the device will be connectable in first 30 seconds after power on.  


 **iBeacon parameters:**  
The app can enable iBeacon broadcast through the KBCfgIBeacon class. The KBCfgIBeacon has follow parameters:  
* uuid:  iBeacon UUID
* majorID: iBeacon major ID
* minorID: iBeacon minor ID

example: set the slot0 to broadcasting iBeacon packet
```swift
//example: update KBeacon to iBeacon
func updateIBeaconPara()
{
    if (self.beacon!.state != KBConnState.Connected)
    {
        print("beacon not connected")
        return;
    }


    let iBeaconCfg = KBCfgAdvIBeacon()
    iBeaconCfg.setSlotIndex(0)   //must be paramaters

    //tx power
    if let strTxPower = txtTxPower.text,
       let nTxPower = Int(strTxPower)
    {
        iBeaconCfg.setTxPower(nTxPower)
    }
    else
    {
        self.showDialogMsg("error", message:"tx power is invalid")
        return
    }

    //set adv period
    if let strAdvPeriod = txtAdvPeriod.text,
       let fAdvPeriod = Float(strAdvPeriod),
       (fAdvPeriod <= KBCfgAdvIBeacon.MAX_ADV_PERIOD && fAdvPeriod >= KBCfgAdvIBeacon.MIN_ADV_PERIOD )
    {
        iBeaconCfg.setAdvPeriod(fAdvPeriod)
    }
    else
    {
        self.showDialogMsg("error", message:"adv period is invalid")
        return
    }

    //modify ibeacon uuid
    if let uuid = txtBeaconUUID.text,
       uuid.isUUIDString()
    {
        iBeaconCfg.setUuid(uuid)
    }
    else
    {
        self.showDialogMsg("error", message:"uuid format is invalid")
        return
    }

    //modify ibeacon major id
    if let strMajorID = txtBeaconMajor.text,
       let nMajor = UInt(strMajorID)
    {
        iBeaconCfg.setMajorID(nMajor)
    }
    else
    {
        self.showDialogMsg("error", message:"major id format is invalid")
        return
    }

    //modify ibeacon major id
    if let strMinorID = txtBeaconMinor.text,
       let nMinor = UInt(strMinorID)
    {
        iBeaconCfg.setMinorID(nMinor)
    }
    else
    {
        self.showDialogMsg("error", message:"major id format is invalid")
        return
    }

    //set always advertisement (not trigger only)
    iBeaconCfg.setAdvTriggerOnly(false)
    iBeaconCfg.setAdvConnectable(true)         //allowed connectable

    self.beacon!.modifyConfig(obj: iBeaconCfg, callback: { (result, exception) in
        if (result)
        {
            self.showDialogMsg("success", message: "config success")
        }
        else if (exception != nil)
        {
            if (exception!.errorCode == KBErrorCode.CfgBusy)
            {
                NSLog("Config busy, please make sure other configruation complete")
            }
            else if (exception!.errorCode == KBErrorCode.CfgTimeout)
            {
                NSLog("Config timeout")
            }

            self.showDialogMsg("Failed", message:"config other error:\(exception!.errorCode)")
        }
    })
}

```

example: set the slot0/slot1 to hybrid iBeacon/EddyTLM.  
sometimes we need KBeacon broadcasting both iBeacon and TLM packet (battery level, Temperature, power on times, etc., )
```swift
func updateKBeaconToIBeaconTLM_unconnectable()
{
    if (self.beacon!.state != KBConnState.Connected)
    {
        NSLog("beacon not connected")
        return
    }

    //iBeacon parameters
    let iBeaconAdv = KBCfgAdvIBeacon()
    iBeaconAdv.setSlotIndex(0)
    iBeaconAdv.setTxPower(KBAdvTxPower.RADIO_Neg12dBm)   //only used for nearby application
    iBeaconAdv.setAdvConnectable(false)    //not allowed connect
    iBeaconAdv.setAdvPeriod(1000.0)
    iBeaconAdv.setUuid("E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
    iBeaconAdv.setMajorID(6454)
    iBeaconAdv.setMinorID(1458)

    //TLM parameters
    let eddyTLMAdv = KBCfgAdvEddyTLM()
    eddyTLMAdv.setSlotIndex(1)
    eddyTLMAdv.setTxPower(KBAdvTxPower.RADIO_0dBm)
    eddyTLMAdv.setAdvConnectable(false)
    eddyTLMAdv.setAdvPeriod(8000.0)

    //start configruation
    self.beacon!.modifyConfig(array:[iBeaconAdv, eddyTLMAdv], callback: { (result, exception) in
        if (result)
        {
            print("config iBeacon&TLM para success")
        }
        else
        {
            print("config iBeacon&TLM para failed");
        }
    })
}
```

##### 4.3.3.3 Update Eddystone parameters
The app can modify the eddystone parameters of KBeacon through the KBCfgEddyURL and KBCfgEddyUID class.  
The KBCfgEddyURL has follow parameters:
* url: eddystone URL address

The KBCfgEddyUID has follow parameters:
* nid: namespace id about UID. It is 10 bytes length hex string value.
* sid: instance id about UID. It is 6 bytes length hex string value.

```swift
//example: update KBeacon to Eddy URL
func updateKBeaconToEddyURL()
{
    if (self.beacon!.state != KBConnState.Connected)
    {
        NSLog("beacon not connected")
        return
    }

    //iBeacon parameters
    let eddyURLAdv = KBCfgAdvEddyURL()
    eddyURLAdv.setSlotIndex(0)
    eddyURLAdv.setAdvPeriod(1000.0)
    eddyURLAdv.setTxPower(KBAdvTxPower.RADIO_Neg20dBm)   //only for nearby (3~4 meters)
    eddyURLAdv.setAdvConnectable(true)
    eddyURLAdv.setUrl("https://www.google.com/")

    //turn off slot 1 advertisement
    let slot1NullAdv = KBCfgAdvNull()
    slot1NullAdv.setSlotIndex(1)

    //start configruation
    let configArray = [eddyURLAdv, slot1NullAdv]
    self.beacon!.modifyConfig(array:configArray, callback: { (result, exception) in
        if (result)
        {
            print("config iBeacon&TLM para success")
        }
        else
        {
            print("config iBeacon&TLM para failed");
        }
    })
}
```

##### 4.3.3.4 Check if parameters are changed
Sometimes, in order to reduce the time for configuration, The app can only sending the modified parameters.

Example: checking if the parameters was changed, then send new parameters to device.
```swift
func updateModifyParaToDevice()
{
    if (!self.beacon!.isConnected())
    {
        return
    }

    //First we get the current configuration of SLOT0, and then we only need to send the parameters that modified.
    if let oldIBeaconPara = self.beacon!.getSlotCfg(0) as? KBCfgAdvIBeacon
    {
        var bModification = false
        let iBeaconCfg = KBCfgAdvIBeacon();
        iBeaconCfg.setSlotIndex(0);  //must be parameters

        if (!oldIBeaconPara.isAdvConnectable()){
            iBeaconCfg.setAdvConnectable(true)
            bModification = true
        }

        if (oldIBeaconPara.isAdvTriggerOnly()){
            iBeaconCfg.setAdvTriggerOnly(false)
            bModification = true
        }

        if (oldIBeaconPara.getAdvPeriod() != 1280.0){
            iBeaconCfg.setAdvPeriod(1280.0)
            bModification = true
        }

        if (oldIBeaconPara.getTxPower() != KBAdvTxPower.RADIO_Neg4dBm){
            iBeaconCfg.setTxPower(KBAdvTxPower.RADIO_Neg4dBm)
            bModification = true
        }

        if (oldIBeaconPara.getUuid()!.compare("E2C56DB5-DFFB-48D2-B060-D0F5A71096E0") != .orderedSame){
            iBeaconCfg.setUuid("E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
            bModification = true
        }

        if (oldIBeaconPara.getMajorID() != 645){
            iBeaconCfg.setMinorID(645)
            bModification = true
        }

        if (oldIBeaconPara.getMinorID() != 741){
            iBeaconCfg.setMinorID(741)
            bModification = true
        }

        //send parameters to device
        if (bModification)
        {
            self.beacon!.modifyConfig(obj:iBeaconCfg, callback: { (result, exception) in
                if (result)
                {
                    print("config iBeacon&TLM para success")
                }
                else
                {
                    print("config iBeacon&TLM para failed");
                }
            })
        }
        else
        {
            print("no need config")
        }
    }
    else
    {
        //...
    }
}
```

#### 4.3.4 Update trigger parameters
 For some KBeacon device that has some motion sensor, temperature&humidity sensor, push button, etc., The application can config the KBeacon to monitor some trigger event. For example, button was pressed, the temperature is too high, or device was motion. The KBeacon can do some action when the trigger condition was met.

 |Trigger No.|0|1|2|3|4|
 |----|----|----|----|----|----|
 |`Type`|Btn single click|Btn double click |Motion|None|None|
 |`Action`|advertisement|advertisement|advertisement|NA|NA|
 |`Adv slot`|0|0|1|NA|NA|
 |`Para`|NA|NA|4|NA|NA|
 |`Adv duration`|10|10|30|NA|NA|
 |`Adv interval`|400.0|1000.0|500.0|NA|NA|
 |`Adv TX power`|4|-4|0|NA|NA|

 The trigger advertisement has follow parameters:
 * Trigger No: Trigger instance number, the device supports up to 5 Triggers by default, the No is 0 ~ 4.
 * Trigger type: Trigger event type
 * Trigger action: Action when trigger event happened. For example: start broadcast, make a sound, or send a notification to the connected App.
 * Trigger Adv slot: When the Trigger event happened, which advertisement Slot  starts to broadcasting
 * Trigger parameters: For motion trigger, the parameter is acceleration sensitivity. For temperature above trigger, you can set to the temperature threshold.
 *	Trigger Adv duration: The advertisement duration when trigger event happened. Unit is second.  
 *	Trigger Adv TX power: The advertisement TX power when trigger event happened. Unit is dBm.
 *	Trigger Adv interval: The advertisement interval when trigger event happened. Unit is ms.


 Example 1: Trigger only advertisment  
  &nbsp;&nbsp;The device usually does not broadcast by default, and we want to trigger the broadcast when the button is pressed.  
  &nbsp;&nbsp; 1. Setting slot 0 to iBeacon advertisement(adv period = 211.25ms, trigger only adv = true).  
  &nbsp;&nbsp; 2. Add a single button trigger(Trigger No = 0, Trigger type = Btn single click, Action = advertisement, Adv slot = 0, Adv duration = 20).  
	&nbsp;&nbsp;  
	![avatar](https://github.com/kkmhogen/KBeaconProDemo_Android/blob/main/only_adv_when_trigger.png?raw=true)

 Example 2:  Trigger advertisment
	&nbsp;For some scenario, we need to continuously monitor the KBeacon to ensure that the device was alive. The device usually broadcasting iBeacon1(UUID=xxx1) , and we want to trigger the broadcast iBeacon2(uuid=xxx2) when the button is pressed.   
  &nbsp;&nbsp; 1. Setting slot 0 to iBeacon advertisement(uuid=xxx1, adv period = 1280ms, trigger only adv = false).    
  &nbsp;&nbsp; 2. Setting slot 1 to iBeacon advertisement(uuid=xxx2, adv period = 211.25ms, trigger only adv = true).    
	&nbsp;We set an larger advertisement interval during alive advertisement and a short advertisement interval when trigger event happened, so we can achieve a balance between power consumption and triggers advertisement be easily detected.  
  &nbsp;&nbsp; 3. Add a single button trigger(Trigger No = 0, Trigger type = Btn single click, Action = advertisement, Adv slot = 1, Adv duration = 20).  
	 &nbsp;&nbsp;
 	![avatar](https://github.com/kkmhogen/KBeaconProDemo_Android/blob/main/always_adv_with_trigger.png?raw=true)




#### 4.3.4.1 Push button trigger
The push button trigger feature is used in some hospitals, nursing homes and other scenarios. When the user encounters some emergency event(SOS button), they can click the button and the KBeacon device will start broadcast or the KBeacon device send the click event to connected Android/IOS app.
The app can configure single click, double-click, triple-click, long-press the button trigger, oor a combination.

**Notify:**  
* By KBeacon's default setting, long press button used to power on and off. Clicking button used to force the KBeacon enter connectable broadcast advertisement. So when you enable the long-press button trigger, the long-press power off function will be disabled. When you turn on the single/double/triple click trigger, the function of clicking to enter connectable broadcast state will also be disabled. After you disable button trigger, the default function about long press or click button will take effect again.  
When you set multiple triggers to the same slot broadcast, you can turn on the Trigger content change mode. When different triggers are triggered, the content of UUID will change by UUID + trigger type.    
* iBeacon UUID for single click trigger = iBeacon UUID + 0x3
* iBeacon UUID for single double trigger = iBeacon UUID + 0x4
* iBeacon UUID for single triple trigger = iBeacon UUID + 0x5
* iBeacon UUID for single long press trigger = iBeacon UUID + 0x6

1. Enable or button trigger event to advertisement.  

```swift
//enable button press trigger event to slot0 advertisement
func enableBtnTriggerEvtToSlot1Advertisement()
{
    //check if device can support button trigger capibility
    if let commCfg = self.beacon!.getCommonCfg(),
       !(commCfg.isSupportTrigger(KBTriggerType.BtnSingleClick))
    {
        self.showDialogMsg("Fail", message: "device does not support button trigger")
        return
    }

    //slot 0 default advertisement (alive advertisement)
    let slot0DefaultAdv = KBCfgAdvIBeacon()
    slot0DefaultAdv.setSlotIndex(0)
    slot0DefaultAdv.setAdvPeriod(2000.0)
    slot0DefaultAdv.setTxPower(KBAdvTxPower.RADIO_0dBm)
    slot0DefaultAdv.setAdvConnectable(true)
    slot0DefaultAdv.setAdvTriggerOnly(false)   //always advertisement
    slot0DefaultAdv.setUuid("E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")
    slot0DefaultAdv.setMajorID(1)
    slot0DefaultAdv.setMinorID(4)

    //trigger index is 0
    let btnTriggerPara = KBCfgTrigger(0, triggerType: KBTriggerType.BtnSingleClick)
    //set trigger action to app
    btnTriggerPara.setTriggerAction(KBTriggerAction.Advertisement)
    btnTriggerPara.setTriggerAdvSlot(0)
    btnTriggerPara.setTriggerAdvTime(10)   //advertisement 10 seconds
    btnTriggerPara.setTriggerAdvChangeMode(KBTriggerAdvChgMode.KBTriggerAdvChangeModeUUID)

    //option trigger para, if the following parameters are omited
    //the trigger broadcasting interval is 2000ms and the TX power is 0dBm
    btnTriggerPara.setTriggerAdvPeriod(200.0)
    btnTriggerPara.setTriggerAdvTxPower(KBAdvTxPower.RADIO_Neg4dBm)


    let configArray = [btnTriggerPara, slot0DefaultAdv]
    self.beacon!.modifyConfig(array:configArray) { (result, exception) in
        if (result)
        {
            self.showDialogMsg("success", message: "Config button trigger success")
        }
        else
        {
            self.showDialogMsg("Error", message: "Config button trigger failed")
        }
    }
}
```


2. Enable device send button trigger event to connected Andoird/IOS application  
In some scenarios, our app will always be connected to the KBeacon device. We need the app can receive a press notification event when the button is pressed.  

//implementation KBNotifyDataDelegate
```swift
class DeviceViewController : KBNotifyDataDelegate
{

}
```

//enable button press trigger event to application
```swift
func enableBtnTriggerEvtToApp()
{
    //check if device can support button trigger capibility
    if let commCfg = self.beacon!.getCommonCfg(),
       !(commCfg.isSupportTrigger(KBTriggerType.BtnSingleClick))
    {
        self.showDialogMsg("Fail", message: "device does not support button trigger")
        return
    }

    //trigger index is 0
    let btnTriggerPara = KBCfgTrigger(0, triggerType: KBTriggerType.BtnSingleClick)
    //set trigger action to app
    btnTriggerPara.setTriggerAction(KBTriggerAction.ReportToApp)

    self.beacon!.modifyConfig(obj: btnTriggerPara) { (result, exception) in
        if (result)
        {
            print("config trigger success")
        }
        else
        {
            print("config trigger failed");
        }
    }
}

//handle trigger event notify
func onNotifyDataReceived(_ beacon:KBeacon, evt:Int, data:Data)
{
    NSLog("recieve event:\(evt), content:\(data.count)")
}

```


3. The app can disable the button trigger by  

```swift
//disable button trigger
@IBAction func onDisableButtonTrigger(_ sender: Any)
{
    if (self.beacon!.state != KBConnState.Connected){
        print("device does not connected")
        return
    }

    //turn off trigger instance 0
    let btnTriggerPara = KBCfgTrigger(0, triggerType: KBTriggerType.TriggerNull)
    btnTriggerPara.setTriggerAction(0)
    self.beacon!.modifyConfig(obj: btnTriggerPara) { (result, exception) in
        if (result)
        {
            print("Turn off btn trigger success")
        }
        else
        {
            print("Turn off btn trigger failed");
        }
    }
}
```

#### 4.3.4.2 Motion trigger
The KBeacon can start broadcasting when it detects motion. Also the app can setting the sensitivity of motion detection.  
**Notify:**  
* When the KBeacon enable the motion trigger, the Acc feature(X, Y, and Z axis detected function) in the KSensor broadcast will be disabled.


Enabling motion trigger is similar to push button trigger, which will not be described in detail here.

1. Enable motion trigger feature.  
 	![avatar](https://github.com/kkmhogen/KBeaconProDemo_Android/blob/main/motion_trigger_example.jpg?raw=true)

```swift
// the iBeacon broadcast duration is 10 seconds.
@IBAction func onEnableMotionTrigger(_ sender: Any)
{
    //check if device can support motion trigger capibility
    guard self.beacon!.isConnected(),
        let commCfg = self.beacon!.getCommonCfg(),
        commCfg.isSupportTrigger(KBTriggerType.AccMotion) else
    {
        print("not allowed to modify motion parameters")
        return
    }

    //trigger index is 0
    let accTriggerPara = KBCfgTriggerMotion()
    //set trigger action to app
    accTriggerPara.setTriggerAction(KBTriggerAction.Advertisement)
    accTriggerPara.setTriggerAdvSlot(0)
    accTriggerPara.setTriggerAdvChangeMode(KBTriggerAdvChgMode.KBTriggerAdvChangeModeUUID)
    accTriggerPara.setTriggerAdvTime(60)   //advertisement 5 seconds
    accTriggerPara.setTriggerAdvPeriod(200.0)
    accTriggerPara.setTriggerAdvTxPower(KBAdvTxPower.RADIO_Neg4dBm)

    //add acc motion para
    accTriggerPara.setTriggerPara(5)    //motion sensitivity, unit is 16mg
    accTriggerPara.setAccODR(KBCfgTriggerMotion.ACC_ODR_25_HZ)
    accTriggerPara.setWakeupDuration(5)

    //we assumption the slot1 already config to iBeacon parameters
    //otherwise you need to config the slot1 parameters
    //please reference the enableBtnTriggerEvtToSlot1Advertisement for configruation slot1
    //...

    //enable motion trigger
    self.beacon!.modifyConfig(obj:accTriggerPara) { (result, exception) in
        if (result)
        {
            print("Enable motion trigger success")
        }
        else
        {
            print("Enable motion trigger failed");
        }
    }
}
```

#### 4.3.4.3 Temperature&Humidity trigger
The app can configure KBeacon to start broadcasting after detecting an abnormality humidity&temperature. For example, the temperature exceeds a specified threshold, or the temperature is below a certain threshold. Currently supports the following Trigger  
* HTTempAbove
* HTTempBelow
* HTHumidityAbove
* HTHumidityBelow

1. Start advertisement when temperature above trigger happened.  

```swift
@IBAction func onTHTrigger2Adv(_ sender: Any)
{
    guard self.beacon!.isConnected(),
        let commCfg = self.beacon!.getCommonCfg(),
       commCfg.isSupportTrigger(KBTriggerType.HTTempAbove) else
    {
        print("not allowed to modify TH parameters")
        return
    }

    //trigger parameters
    let triggerAdv = KBCfgTrigger(0, triggerType: KBTriggerType.HTTempAbove)
    triggerAdv.setTriggerAction(KBTriggerAction.Advertisement)
    triggerAdv.setTriggerAdvSlot(1)  //please makesure the slot 1 was config
    triggerAdv.setTriggerAdvTime(10)
    triggerAdv.setTriggerPara(30)    //trigger when temperature > 30 Celsius degree

    //config slot 1 parameters
    let slot1TriggerAdv = KBCfgAdvIBeacon()
    slot1TriggerAdv.setSlotIndex(1)
    slot1TriggerAdv.setAdvPeriod(152.5)
    slot1TriggerAdv.setTxPower(KBAdvTxPower.RADIO_0dBm)
    slot1TriggerAdv.setAdvConnectable(false)
    slot1TriggerAdv.setAdvTriggerOnly(true)   //only advertisement when trigger happened
    slot1TriggerAdv.setUuid("E2C56DB5-DFFB-48D2-B060-D0F5A71096E3")
    slot1TriggerAdv.setMajorID(0)
    slot1TriggerAdv.setMinorID(2)

    //set trigger
    let configArray = [triggerAdv, slot1TriggerAdv]
    self.beacon!.modifyConfig(array:configArray) { (result, exception) in
        if (result)
        {
            self.showDialogMsg("success", message: "Enable temp above trigger success")
        }
        else
        {
            self.showDialogMsg("error", message: "Enable temp above trigger failed")
        }
    }
}
```
2. Report event to app when temperature above trigger event happened.  
```swift
//After enable realtime data to app, then the device will periodically send the temperature and humidity data to app whether it was changed or not.
@IBAction func onTHTriggerEvt2App(_ sender: Any)
{
    guard self.beacon!.isConnected(),
        let commCfg = self.beacon!.getCommonCfg(),
       commCfg.isSupportHumiditySensor() else
    {
        print("not allowed to read history log")
        return
    }

    let triggerApp = KBCfgTrigger(0, triggerType: KBTriggerType.HTTempAbove)
    triggerApp.setTriggerAction(KBTriggerAction.ReportToApp)
    triggerApp.setTriggerPara(50)  //trigger an event to app when temperature > 50 Celsius
    self.beacon!.modifyConfig(obj:triggerApp) { (result, exception) in
        if (result)
        {
            //subscribe HT notification
            self.beacon!.subscribeSensorDataNotify(KBTriggerType.HTRealTimeReport, notifyDelegate: self) { (result, exception) in
                if (result){
                    print("subscribe trigger notification success")
                }else{
                    print("subscribe trigger notification failed")
                }
            }
        }
        else
        {
            print("enable trigger failed")
        }
    }
}
```

3. Report temperature&humidity to app periodically
```swift
//After enable periodically trigger, then the device will periodically send the temperature and humidity data to app whether it was changed or not.
func enableTHPeriodicallyTriggerRpt2App(_ sender: Any)
{
    guard self.beacon!.isConnected(),
        let commCfg = self.beacon!.getCommonCfg(),
        commCfg.isSupportTrigger(KBTriggerType.HTHumidityPeriodically) else
    {
        print("not allowed to set trigger")
        return
    }

    let triggerApp = KBCfgTrigger(0, triggerType: KBTriggerType.HTHumidityPeriodically)
    triggerApp.setTriggerAction(KBTriggerAction.ReportToApp)
    triggerApp.setTriggerPara(60)  //tx measure result every 60 seconds
    self.beacon!.modifyConfig(obj:triggerApp) { (result, exception) in
        if (result)
        {
            //subscribe HT notification
            self.beacon!.subscribeSensorDataNotify(KBTriggerType.HTHumidityPeriodically, notifyDelegate: self) { (result, exception) in
                if (result){
                    print("subscribe trigger notification success")
                }else{
                    print("subscribe trigger notification failed")
                }
            }
        }
        else
        {
            print("enable trigger failed")
        }
    }
}
 ```

#### 4.3.4.3 Cutoff trigger
The Cutoff trigger is suitable for tamper-evident beacon such as W3, W7. Or Door beacon such as the S1.  
When the cut-off was detected, the beacon will send the specfic advertisement to the cloud/backend and trigger the alert, the administrator will response and help.  
*Wristband Beacon  
![avatar](https://github.com/kkmhogen/KBeaconProDemo_Android/blob/main/wristbandCutoffTrigger.png?raw=true)  
*CutoffWatchband  
![avatar](https://github.com/kkmhogen/KBeaconProDemo_Android/blob/main/doorCutoffTrigger.png?raw=true)  
* CutoffWatchband
```swift
func onEnableCutoffTrigger()
{
    guard self.beacon!.isConnected(),
        let commCfg = self.beacon!.getCommonCfg(),
        commCfg.isSupportTrigger(KBTriggerType.CutoffWatchband) else
    {
        print("device does not support cut off trigger")
        return
    }

    //enable cutoff trigger
    let cutoffTrigger = KBCfgTrigger(0, triggerType: KBTriggerType.Cutoff)
    cutoffTrigger.setTriggerAction(KBTriggerAction.Advertisement)
    cutoffTrigger.setTriggerAdvSlot(0)  //please makesure the slot 0 was setting
    cutoffTrigger.setTriggerAdvTime(10)
    cutoffTrigger.setTriggerAdvChangeMode(KBTriggerAdvChgMode.KBTriggerAdvChangeModeUUID)

    self.beacon!.modifyConfig(obj: cutoffTrigger) { (result, exception) in
        if (result)
        {
            print("Enable cutoff trigger success")
        }
        else
        {
            print("Enable cutoff trigger failed")
        }
    }
}
```

 #### 4.3.4.5 PIR trigger
 ```swift
func onEnablePIRTrigger()
{
   guard self.beacon!.isConnected(),
       let commCfg = self.beacon!.getCommonCfg(),
         commCfg.isSupportTrigger(KBTriggerType.PIRBodyInfraredDetected) else
   {
       print("device does not support cut off trigger")
       return
   }

   //Save the PIR event to memory flash and report it to the APP at the same time
   let pirTrigger = KBCfgTrigger(0, triggerType: KBTriggerType.PIRBodyInfraredDetected)
   pirTrigger.setTriggerAction(KBTriggerAction.Record | KBTriggerAction.ReportToApp)

   //If the human infrared is repeatedly detected within 30 seconds, it will no longer be record/reported.
   pirTrigger.setTriggerPara(30);

   self.beacon!.modifyConfig(obj: pirTrigger) { (result, exception) in
       if (result)
       {
           print("Enable cutoff trigger success")
       }
       else
       {
           print("Enable cutoff trigger failed")
       }
   }
}    
 ```

#### 4.3.5 sensor parameters
If the device has sensors, such as temperature and humidity sensors, we may need to setting the sensor parameters, such as the measurement interval.
For some sensors, we may not want it to work all the time, such as the Door sensor, we may only want it to work at night. The advantage of this is, the power consumption can be reduced, and the unnecessary trigger can also be reduced.

#### 4.3.5.1 Config disable period paramaters
The sensors that support configuring a disable period include: Door sensor, PIR sensor.
```swift
//set disable period parameters
func setPIRDisablePeriod()
{
   guard self.beacon!.isConnected(),
       let commCfg = self.beacon!.getCommonCfg(),
         commCfg.isSupportTrigger(KBTriggerType.PIRBodyInfraredDetected) else
   {
       print("device does not support cut off trigger")
       return
   }

   let sensorPara = KBCfgSensorBase()
   sensorPara.setSensorType(KBSensorType.PIR)

   //set disable period from 8:00AM to 20:00 PM
   let disablePeriod = KBTimeRange()
   disablePeriod.localStartHour = 8
   disablePeriod.localStartMinute = 0
   disablePeriod.localEndHour = 20
   disablePeriod.localEndMinute = 0
   sensorPara.setDisablePeriod0(disablePeriod)

   self.beacon!.modifyConfig(obj: sensorPara) { (result, exception) in
       if (result)
       {
           print("Enable disable period success")
       }
       else
       {
           print("Enable disable period failed")
       }
   }
}
```

#### 4.3.5.2 Config temperature and humidity measure parameters and log parameters
For temperature and humidity sensors, we can set the measurement interval. In addition, we can use the device as a Logger, and we can set the log conditions.
```swift
func setTHSensorMeasureParameters()
{
    if (!self.beacon!.isConnected())
    {
        print("Device is not connected")
        return
    }

    //check device capability
    if let oldCommonCfg = self.beacon!.getCommonCfg(),
       oldCommonCfg.isSupportHumiditySensor()
    {
        print("Device does not supported ht sensor")
        return
    }

    //set trigger adv slot information
    let sensorHTPara = KBCfgSensorHT()
    //enable humidity sensor
    sensorHTPara.setLogEnable(true)

    //unit is second, set measure temperature and humidity interval
    sensorHTPara.setSensorHtMeasureInterval(2)

    //unit is 0.1%, if abs(current humidity - last saved humidity) > 3, then save new record
    sensorHTPara.setHumidityChangeThreshold(30)

    //unit is 0.1 Celsius, if abs(current temperature - last saved temperature) > 0.5, then save new record
    sensorHTPara.setTemperatureChangeThreshold(5)

    //enable sensor advertisement
    self.beacon!.modifyConfig(obj: sensorHTPara) { (result, exception) in
        if (result)
        {
            print("update ht parameters success")
        }
        else
        {
            print("update ht parameters failed")
        }
    }
}
```


#### 4.3.5.3 Read sensor history records
For some beacon devices, it can logging the trigger events to memory flash. Such as Door open and close events, PIR detection events, temperature and humidity recording. For these devices, we can read these saved histories record through the APP or Gateway.

1. Read history summary information.  
With this command, we can read the total number of records and the number of unread records in the device. Next, we can read the specified record. Or read the records that have not been read.  

```swift
//read temperature and humidity history record info
func readHTSensorDataInfo()
{
    let readHtRecordInfo = KBHumidityDataMsg()
    readHtRecordInfo.readSensorDataInfo(self.beacon!, callback: { (result, obj, exception) in
        if (!result)
        {
            //read ht record info failed
            print("read ht record info failed")
            return
        }

        if let infRsp = obj as? ReadSensorInfoRsp
        {
            if (infRsp.unreadRecordNumber == 0)
            {
                print("no unread data in device")
            }
            else
            {
                print("there is \(infRsp.unreadRecordNumber) ht record in device")
            }
        }
    })
}

//read cutoff history info example
func readCutSensorDataInfo()
{
    let readCutoffRecordInfo = KBCutoffDataMsg()
    readCutoffRecordInfo.readSensorDataInfo(self.beacon!, callback: { (result, obj, exception) in
        if (!result)
        {
            print("read record info failed")
            return
        }

        if let infRsp = obj as? ReadSensorInfoRsp
        {
            if (infRsp.unreadRecordNumber == 0)
            {
                print("no unread data in device")
            }
            else
            {
                print("there is \(infRsp.unreadRecordNumber) cut off record in device")
            }
        }
    })
}
```

2.  Read sensor history records  
  The SDK provides the following three ways to read records.
  * KBSensorReadOption.NewRecord:  read history records and move next. After app reading records, the KBeacon device will move the pointer to the next unreaded record. If the app send read request again, the KBeacon device sends next unread records and move the pointer to next.

  * KBSensorReadOption.NormalOrder: Read records without pointer moving. The app can read records from old to recently. To read records in this way, the app must  specify the record no to be read.

  * KBSensorReadOption.ReverseOrder: Read records without pointer moving. The app can read records from recently to old. To read records in this way, the app must  specify the record no to be read.

   Example1: The app read the temperature and humidity records. Each time the records was read, the pointer will move to next.
```swift
self.mSensorDataMsg!.readSensorRecord(self.beacon!,
                                          number: CfgSensorDataHistoryController.INVALID_DATA_RECORD_POS,
                  option: KBSensorReadOption.NewRecord,
                  max: 30,
                  callback: { (result, obj, exception) in
      if (!result)
      {
          self.mTimerLoading?.invalidate()
          self.showMsgDlog(title: "failed", message: getString("LOAD_HISTORY_DATA_FAILED"))
          return
      }

      if let dataRsp = obj as? ReadHTSensorDataRsp
      {
          //add data
          self.mRecordMgr!.appendRecords(dataRsp.readDataRspList)
          ...
      }
  })
```  

  Example2: The app read the temperature and humidity records without moving pointer.
  The device has 100 records sorted by time, the app want to reading 10 records and start from the No 99. The Kbeacon will send records #99 ~ #90 to app by reverse order.     
  If the app does not known the last record no, then the value can set to INVALID_DATA_RECORD_POS.
```swift
self.mSensorDataMsg!.readSensorRecord(self.beacon!,
                                          number: CfgSensorDataHistoryController.INVALID_DATA_RECORD_POS,
                  option: KBSensorReadOption.ReverseOrder,
                  max: 10,
                  callback: { (result, obj, exception) in
      if (!result)
      {
          self.mTimerLoading?.invalidate()
          self.showMsgDlog(title: "failed", message: getString("LOAD_HISTORY_DATA_FAILED"))
          return
      }

      if let dataRsp = obj as? ReadHTSensorDataRsp
      {
          //add data
          self.mRecordMgr!.appendRecords(dataRsp.readDataRspList)
          ...
      }
  })
```  

 Example3: The app read the temperature and humidity records without moving pointer.
 The device has 100 records sorted by time, the app want to reading 20 records and start from No 10. The Kbeacon will send records #10 ~ #29 to app.  
```swift
self.mSensorDataMsg!.readSensorRecord(self.beacon!,
                                          number:10,
                  option: KBSensorReadOption.NormalOrder,
                  max: 20,
                  callback: { (result, obj, exception) in
      if (!result)
      {
          self.mTimerLoading?.invalidate()
          self.showMsgDlog(title: "failed", message: getString("LOAD_HISTORY_DATA_FAILED"))
          return
      }

      if let dataRsp = obj as? ReadHTSensorDataRsp
      {
          //add data
          self.mRecordMgr!.appendRecords(dataRsp.readDataRspList)
          ...
      }
  })
```

#### 4.3.6 Send command to device
After app connect to device success, the app can send command to device.  
All command message between app and KBeacon are JSON format. Our SDK provide Hash Map to encapsulate these JSON message.
#### 4.3.6.1 Ring device
 For some KBeacon device that has buzzer function. The app can ring device. For ring command, it has 5 parameters:
 * msg: msg type is 'ring'
 * ringTime: unit is ms. The KBeacon will start flash/alert for 'ringTime' millisecond  when receive this command.
 * ringType: 0x1:beep alert only; 0x2 led flash ; 0x4 moto, 0x0 turn off ring;
 * ledOn: optional parameters, unit is ms. The LED will flash at interval (ledOn + ledOff).  This parameters is valid when ringType set to 0x0 or 0x1.
 * ledOff: optional parameters, unit is ms. the LED will flash at interval (ledOn + ledOff).  This parameters is valid when ringType set to 0x0 or 0x1.  

  ```swift
@IBAction func onRingDevice(_ sender: Any)
{
     guard self.beacon!.isConnected() else
     {
         print("devie not allowed beep")
         return
     }

     var paraDicts = [String:Any]()
     paraDicts["msg"] = "ring"

     //ring times, uint is ms
     paraDicts["ringTime"] = 10000

     //ring type 0x1: beep, 0x2: led flash
     paraDicts["ringType"] = 0x2

     //led flash on time. valid when ringType set to 0x0 or 0x2
     paraDicts["ledOn"] = 200

     //led flash off time. valid when ringType set to 0x0 or 0x2
     paraDicts["ledOff"] = 1800

     self.beacon?.sendCommand(paraDicts, callback: { (result, except) in
         if (result)
         {
             NSLog("send ring command to device success");
         }
         else
         {
             NSLog("send ring command to device failed");
         }
     })
}
```
#### 4.3.6.2 Reset configuration to default
 The app can use follow command to reset all configurations to default.
 * msg: message type is 'reset'

```swift
//set parameter to default
@IBAction func onResetParametersToDefault(_ sender: Any)
{
    guard self.beacon!.isConnected() else
    {
        print("devie not connected")
        return
    }


    var paraDicts = [String:Any]()
    paraDicts["msg"] = "admin"
    paraDicts["stype"] = "reset"
    self.beacon!.sendCommand(paraDicts, callback: { (result, except) in
        if (result)
        {
            NSLog("send reset command to device success");
        }
        else
        {
            NSLog("send reset command to device failed");
        }
    })
}
```

#### 4.3.7 Error cause in configurations/command
 App may get errors during the configuration. The KBException has follow values.
 * KBErrorCode.CfgReadNull: Device return null parameters
 * KBErrorCode.CfgBusy: device is busy, please make sure last configuration complete
 * KBErrorCode.CfgFailed: device return failed.
 * KBErrorCode.CfgTimeout: configuration timeout
 * KBErrorCode.CfgInputInvalid: input parameters data not in valid range
 * KBErrorCode.CfgStateError: device is not in connected state
 * KBErrorCode.CfgNotSupport: device does not support the parameters

 ```swift
{
    ...another code

    //start configuration
    self.beacon!.modifyConfig(obj: iBeaconCfg, callback: { (result, exception) in
        if (result)
        {
            self.showDialogMsg("success", message: "config success")
        }
        else if (exception != nil)
        {
            if (exception!.errorCode == KBErrorCode.CfgBusy)
            {
                NSLog("Config busy, please make sure other configruation complete")
            }
            else if (exception!.errorCode == KBErrorCode.CfgTimeout)
            {
                NSLog("Config timeout")
            }

            self.showDialogMsg("Failed", message:"config other error:\(exception!.errorCode)")
        }
    })
}
 ```

 ## 5. DFU
 Through the DFU function, you can upgrade the firmware of the device. Our DFU function is based on Nordic's DFU library. In order to make it easier for you to integrate the DFU function, We add the DFU function into ibeacondemo demo project for your reference. The Demo about DFU includes the following class:
 * KBDFUViewController: DFU UI activity and procedure about how to download latest firmware.
 * KBFirmwareDownload: Responsible for download the JSON or firmware from KKM clouds.
 * DFUService: This DFU service that implementation Nordic's DFU library.
 ![avatar](https://github.com/kkmhogen/KBeaconDemo_Ios/blob/master/kbeacon_dfu__ios_arc.png)

 ### 5.1 Add DFU function to the application.
 Edit Podfile:
 The DFU Demo need download the firmware from KKM clouds by AFNNetworking library.  Also the DFU demo using nordic DFU library for update.
  ```
  platform :ios, '11.0'
  use_frameworks!
  target 'KBeaconProDemo' do
     pod 'iOSDFULibrary'
     pod 'MJRefresh'
     pod 'kbeaconlib2'
  end
  ```

 3. Start DFU  
 ```swift
 @IBAction func onDFUClick(_ sender: Any)
 {
     if self.beacon!.isConnected(),
         let commCfg = self.beacon?.getCommonCfg(),
         commCfg.isSupportSecurityDFU()
     {
         self.performSegue(withIdentifier: "seqCfgDFU", sender: self)
     }
 }

 ```
 If you want to known more details about getting the Device's latest firmware from KKM cloud, or deploied the latest firmware on you cloud. Please contact KKM sales(sales@kkmcn.com) and she/he will send you a detail document.

  Also for more detail nordic DFU library, please refer to
https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library

## 6. Change log
* 2022.6.1 v1.31 Add PIR sensor
* 2021.6.20 v1.30 Support slot adv
* 2021.1.30 v1.24 Support alarm trigger action
* 2020.11.1 v1.23 Support humidity sensor
* 2020.6.1 v1.22 Add DFU library
* 2020.3.1 v1.21 change the advertisement period from integer to float.
* 2020.1.11 v1.2 add trigger function.
* 2019.10.11 v1.1 add KSesnor function.
* 2019.4.1 v1.0 first version.
