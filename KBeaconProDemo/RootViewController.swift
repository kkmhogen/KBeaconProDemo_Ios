//
//  ViewController.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/15.
//

import UIKit
import kbeaconlib2

class RootViewController: UIViewController ,UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, KBeaconMgrDelegate{
    
    let HEX_PATH_NAME = "KBeaconFirmware"
    let DEFAULT_DOWNLOAD_WEB_ADDRESS  = "https://api.ieasygroup.com:8092/KBeaconFirmware/"
    
    @IBOutlet weak var mScanButton: UIBarButtonItem!
    
    @IBOutlet weak var mFilterActionButton: UIButton!
    
    @IBOutlet weak var mFilterSummaryEdit: UITextField!
    
    @IBOutlet weak var mFilterNameEdit: UITextField!
    
    @IBOutlet weak var mFilterSummaryView: UIView!
    
    @IBOutlet weak var mFilterView: UIView!
    
    @IBOutlet weak var mFilterRemoveName: UIButton!
    
    @IBOutlet weak var mFilterRemoveSummary: UIButton!
    
    @IBOutlet weak var beaconsTableView: UITableView!
    
    @IBOutlet weak var mRssiFilterSlide: UISlider!
    
    @IBOutlet weak var mRssiFilterLabel: UILabel!
    
    var mBeaconsDictory = [String:KBeacon]()
    
    var mBeaconsMgr: KBeaconsMgr?
    
    private var mSelectedBeacon : KBeacon?
    
    var mBeaconsArray = [KBeacon]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //refresh menu
        let rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: "Pull to refresh")
        rc.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        self.beaconsTableView.refreshControl = rc
        
        mBeaconsMgr = KBeaconsMgr.sharedBeaconManager
        mBeaconsMgr!.delegate = self
                
        //init for start scan
        self.mScanButton.title = NSLocalizedString("ACTION_START_SCAN", comment:"");
        
        self.mFilterView!.isHidden = true
        self.mFilterActionButton!.isSelected = false
        
        self.mFilterSummaryEdit!.delegate = self;
        self.mFilterNameEdit!.delegate = self;
        
        self.mFilterNameEdit.addTarget(self, action: #selector(textNameFieldEditChanged(_:)), for: .editingChanged)
        
        self.mFilterRemoveName.isHidden = true
        self.mFilterRemoveSummary.isHidden = true
        
        beaconsTableView.delegate = self
        beaconsTableView.dataSource = self
        beaconsTableView.separatorInset = UIEdgeInsets.zero;
        beaconsTableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    
    @objc func refreshTableView()
    {
        if (self.beaconsTableView.refreshControl!.isRefreshing)
        {
            self.beaconsTableView.refreshControl!.attributedTitle =
                NSAttributedString(string: NSLocalizedString("ACTION_REFRESHING", comment:""))
            
            self.perform(#selector(clearBeaconDevice), with: nil, afterDelay: 1.0)
        }
    }
    
    
    func toggleEditFilterView()
    {
        if (self.mFilterActionButton.isSelected)
        {
            self.mFilterView.isHidden = true;
            mFilterNameEdit.resignFirstResponder()
            
            self.mBeaconsArray.removeAll()
            self.mBeaconsDictory.removeAll()
            
            self.beaconsTableView.reloadData()
            
            self.updateFilterSummary()
        }
        else
        {
            self.mFilterNameEdit.becomeFirstResponder()
            
            self.mFilterView.isHidden = false
            self.view.bringSubviewToFront(self.mFilterView)
        }
        
        self.mFilterActionButton.isSelected = !self.mFilterActionButton.isSelected;
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
    {
        if (textField == self.mFilterSummaryEdit)
        {
            self.toggleEditFilterView()
            return false
        }
        else
        {
            return true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        self.toggleEditFilterView()
        return true
    }

    func updateFilterSummary()
    {
        var strTextFilter = self.mFilterNameEdit.text
        
        if (self.mRssiFilterSlide.value != self.mRssiFilterSlide.minimumValue)
        {
            if (self.mFilterNameEdit.text!.count > 1)
            {
                strTextFilter = "\(strTextFilter!);"
            }
            
            let nRssiValue = Int(self.mRssiFilterSlide.value)
            strTextFilter = "\(strTextFilter!)\(nRssiValue)dBm"
        }
        
        self.mFilterSummaryEdit!.text = strTextFilter!
        if (self.mFilterSummaryEdit.text!.count > 1)
        {
            self.mFilterRemoveName.isHidden = false
        }
        else
        {
            self.mFilterRemoveName.isHidden = true
        }
    }

    @objc func textNameFieldEditChanged(_ textField:UITextField)
    {
        mBeaconsMgr?.setScanNameFilter(filterName: self.mFilterNameEdit!.text!, ignoreCase: true)
        if (self.mFilterNameEdit!.text!.count > 1)
        {
            self.mFilterRemoveName.isHidden = false;
        }
        else
        {
            self.mFilterRemoveName!.isHidden = true;
        }
    }

    @IBAction func onEditFilter(_ sender: Any) {
        toggleEditFilterView()
    }

    @IBAction func onRssiFilterValueChange(_ sender: Any) {
        mBeaconsMgr!.scanMinRssiFilter = Int(self.mRssiFilterSlide.value)
        self.mRssiFilterLabel!.text = "\(Int(self.mRssiFilterSlide.value))"
    }


    @IBAction func onRemoveAllFilter(_ sender: Any) {
        self.mFilterNameEdit.text = ""
        self.mRssiFilterSlide.value = self.mRssiFilterSlide.minimumValue;
        
        self.updateFilterSummary()
        
        mBeaconsMgr?.setScanNameFilter(filterName: "", ignoreCase: true)
        mBeaconsMgr?.scanMinRssiFilter = -100
    }

    @IBAction func onRemoveNameFilter(_ sender: Any) {
        self.mFilterNameEdit.text = "";
        mBeaconsMgr?.setScanNameFilter(filterName: "", ignoreCase: true)
    }


    @IBAction func onScanStart(_ sender: Any) {
        if (self.mScanButton.title == NSLocalizedString("ACTION_START_SCAN", comment:""))
        {
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
        }
        else
        {
            mBeaconsMgr!.stopScanning()
            self.mScanButton!.title = NSLocalizedString("ACTION_START_SCAN", comment:"")
        }
    }


    func onBeaconDiscovered(beacons:[KBeacon])
    {
        for beacon in beacons
        {
            if mBeaconsDictory[beacon.uuidString!] == nil
            {
                mBeaconsArray.append(beacon)
            }
            mBeaconsDictory[beacon.uuidString!] = beacon

        }
        
        beaconsTableView.reloadData()
    }
    
    func printScanPacket(_ advBeacon: KBeacon)
    {
        //check if has packet
        guard let allAdvPackets = advBeacon.allAdvPackets else{
            return
        }
        
        print("--------scan device advertisment packet---------")
        print("name:\(advBeacon.name ?? "NA")")
        print("mac:\(advBeacon.mac ?? "NA")")

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
                    
                    //check if has battery level
                    if (sensorAdv.batteryLevel != KBCfgBase.INVALID_UINT16)
                    {
                        print("batt:\(sensorAdv.batteryLevel)")
                    }
                    
                    //check if has temperature
                    if (sensorAdv.temperature != KBCfgBase.INVALID_FLOAT)
                    {
                        print("temp:\(sensorAdv.temperature)")
                    }
                    
                    //check if has humidity
                    if (sensorAdv.humidity != KBCfgBase.INVALID_FLOAT)
                    {
                        print("humidity:\(sensorAdv.humidity)")
                    }
                    
                    //check if has acc sensor
                    if let axisValue = sensorAdv.accSensor
                    {
                        print("  xAis:\(axisValue.xAis)")
                        print("  yAis:\(axisValue.yAis)")
                        print("  zAis:\(axisValue.zAis)")
                    }
                    
                    //check if has pir indication
                    if (KBCfgBase.INVALID_UINT8 != sensorAdv.pirIndication)
                    {
                        print("PIR indication:\(sensorAdv.pirIndication)")
                    }
        
                    //check if has light level
                    if (KBCfgBase.INVALID_UINT16 != sensorAdv.luxLevel)
                    {
                        print("Light level:\(sensorAdv.luxLevel)")
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
            case KBAdvType.EBeacon:
                if let encryptAdv = advPacket as? KBAdvPacketEBeacon
                {
                    print("-----EBeacon----")
                    print("Decrypt UUID:\(String(describing: encryptAdv.uuid))")
                    print("ADV UTC:\(encryptAdv.utcSecCount)")
                    print("Reference power:\(encryptAdv.measurePower)")
                }
            default:
                print("unknown packet")
            }
        }
        
        //remove buffered packet
        advBeacon.removeAdvPacket()
    }

    func onCentralBleStateChange(newState:BLECentralMgrState)
    {
        if (newState == BLECentralMgrState.PowerOn)
        {
            //the app can start scan in this case
            NSLog("central ble state power on")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //auto matic start scan
        if (self.mScanButton!.title == NSLocalizedString("ACTION_STOP_SCAN", comment:""))
        {
            mBeaconsMgr!.startScanning()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.mScanButton!.title == NSLocalizedString("ACTION_STOP_SCAN", comment:""))
        {
            mBeaconsMgr!.stopScanning()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mBeaconsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "BeaconViewCellIdentify";
        let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) as? KBeaconViewCell
        
        let pBeacons = mBeaconsArray[indexPath.row]
        
        //device can be connectable ?
        let strConnect = pBeacons.isConnected() ? "yes" : "no"
        cell?.connectableLabel.text = "Conn:\(strConnect)"
        
        //mac
        if let mac = pBeacons.mac
        {
            cell?.macLabel.text = "mac:\(mac)"
        }
        
        //battery percent
        if KBCfgBase.INVALID_UINT8 != pBeacons.batteryPercent
       {
           cell?.voltageLabel.text = "Batt:\(pBeacons.batteryPercent)"
       }
        
        //device name
        if let name = pBeacons.name
        {
            cell?.deviceNameLabel.text = name
        }else{
            cell?.deviceNameLabel.text = "N/A";
        }
        
        //rssi
        cell?.rssiLabel.text = "rssi:\(pBeacons.rssi)"
        
        if let pFirstIBeacon = pBeacons.getAvPacketByType(KBAdvType.IBeacon) as? KBAdvPacketIBeacon
        {
            //because IOS app can not get UUID from advertisement, so we try to get uuid from configruation database, the UUID only avaiable when device connected
            if let uuid = pFirstIBeacon.uuid
            {
                cell?.uuidLabel.text = "major:\(uuid)"
            }
            
            //get majorID from advertisement packet
            //notify: this is not standard iBeacon protocol, we get major ID from KKM private
            //scan response message
            cell?.majorLabel.text = "major:\(pFirstIBeacon.majorID)"
            
            //get majorID from advertisement packet
            //notify: this is not standard iBeacon protocol, we get minor ID from KKM private
            //scan response message
            if KBCfgBase.INVALID_INT != pFirstIBeacon.minorID
            {
                cell?.minorLabel.text = "minor:\(pFirstIBeacon.minorID)"
            }
        }
        
        if let pFirstSensor = pBeacons.getAvPacketByType(KBAdvType.Sensor) as? KBAdvPacketSensor
        {
            cell?.sensorView.isHidden = false
            if let acc = pFirstSensor.accSensor
            {
                cell?.accAxisLabel.text = "Acc: x:\(acc.xAis),y:\(acc.yAis),z:\(acc.zAis)"
            }

            var strTemperature = "NA";
            var strHumidity = "NA";
            if KBCfgBase.INVALID_FLOAT != pFirstSensor.humidity
            {
                strHumidity = String(format:"%0.2f", pFirstSensor.humidity);
            }
            if KBCfgBase.INVALID_FLOAT != pFirstSensor.temperature
            {
                strTemperature = String(format:"%0.2f", pFirstSensor.temperature)
            }
               
            cell?.humidityLabel.text = "temp:\(strTemperature),hum:\(strHumidity)"
        }
        else
        {
            cell?.sensorView.isHidden = true
        }
        
        cell?.beacon = pBeacons
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < mBeaconsArray.count
        {
            mSelectedBeacon = mBeaconsArray[indexPath.row]
            self.performSegue(withIdentifier: "seqDeviceDetail", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "seqDeviceDetail")
        {
            if let deviceController = segue.destination as? DeviceViewController
            {
                deviceController.beacon = mSelectedBeacon
            }
        }
    }

    func showMsgDlog(title:String, message:String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let OKTitle = NSLocalizedString("DLG_OK", comment:"");
        let OkAction = UIAlertAction(title: OKTitle, style: UIAlertAction.Style.destructive, handler: nil)
        alertController.addAction(OkAction)
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    @objc func clearBeaconDevice()
    {
        self.beaconsTableView.refreshControl!.endRefreshing()
        
        self.beaconsTableView.refreshControl!.attributedTitle = NSAttributedString(string: NSLocalizedString("PUSH_TO_RELEASE", comment:""))
        mBeaconsMgr!.clearBeacons()

        mBeaconsDictory.removeAll()
        mBeaconsArray.removeAll()

        self.beaconsTableView.reloadData()
    }
}

