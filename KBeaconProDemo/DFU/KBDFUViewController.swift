//
//  CfgDFUController.swift
//  KBeaconPro
//
//  Created by hogen on 2021/6/17.
//

import Foundation
import UIKit
import iOSDFULibrary
import kbeaconlib2

class KBDFUViewController : UIViewController, ConnStateDelegate,DFUServiceDelegate,DFUProgressDelegate
{
    @IBOutlet weak var labelDFUStatus: UILabel!
    
    @IBOutlet weak var progressDFU: UIProgressView!
    
    @IBOutlet weak var labelDFUVersion: UILabel!
    
    @IBOutlet weak var labelDFUNotes: UILabel!

    public var beacon : KBeacon?
    
    var firmwareDownload : KBFirmwareDownload?
    
    var dfuSrvController : DFUServiceController?
    
    var latestFirmwareFileName : String = ""
    
    var mInDfuState : Bool = false
    
    var mFoudNewVersion : Bool = false
    
    weak var mPrivousDelegation : ConnStateDelegate?
    
    var indicatorView : IndicatorViewController?
    
    override func viewDidLoad()
    {
        guard self.beacon != nil else{
            print("please set beacon before start DFU")
            self.navigationController?.popViewController(animated: true)
            return
        }

        self.firmwareDownload = KBFirmwareDownload()
        
        labelDFUStatus.text = getString("DEVICE_CHECK_UPDATE")
        
        //download firmware info
        //download firmware info
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            self.downloadFirmwareInfo()
        }
    }
    
    func onConnStateChange(_ beacon:KBeacon, state:KBConnState, evt:KBConnEvtReason)
    {
    }
    
    func dfuComplete(_ result:Bool, description : String)
    {
        self.indicatorView?.stopAnimating()
        var title : String
        if result {
            title = getString("DFU_TITLE_SUCCESS")
        }else{
            title = getString("DFU_TITLE_FAIL")
        }
        
        let alertController = UIAlertController(title: title,
                                                message: description,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: getString("DLG_OK"),
                                                style: .default,
                                                handler: { (action) in
                                                    if self.beacon?.state == KBConnState.Connected
                                                    {
                                                        self.navigationController?.popViewController(animated: true)
                                                    }
                                                    else
                                                    {
                                                        if let controllers = self.navigationController?.viewControllers
                                                        {
                                                            self.navigationController?.popToViewController(controllers[0], animated: true)
                                                        }
                                                    }
                                                }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func dfuStateDidChange(to state: DFUState)
    {
        switch (state)
        {
        case DFUState.connecting:
            NSLog("DFU connecting");
            self.labelDFUStatus.text = getString("UPDATE_CONNECTING")
            
        case DFUState.enablingDfuMode:
            NSLog("DFU mode");
            
        case DFUState.uploading:
            NSLog("DFU uploading");
            self.labelDFUStatus.text = getString("UPDATE_UPLOADING")
            
        case DFUState.disconnecting:
            NSLog("DFU disconnecting");
            
        case DFUState.completed:
            NSLog("DFU complete");
            self.mInDfuState = false

            labelDFUStatus.text = getString("UPDATE_COMPLETE")
            dfuComplete(true, description: getString("UPDATE_COMPLETE"))
            
        case DFUState.aborted:
            NSLog("DFU complete");
            labelDFUStatus.text = getString("UPDATE_ABORTED")
            self.mInDfuState = false
            dfuComplete(false, description: getString("UPDATE_ABORTED"))
            
        default:
            print("unknown dfu state")
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String)
    {
        self.indicatorView?.stopAnimating()

        showDialogMsg(getString("DFU_TITLE_FAIL"), message: message)

        self.labelDFUStatus.text = getString("UPDATE_ABORTED")
        
        self.mInDfuState = false
        
        dfuComplete(false, description: getString("UPDATE_ABORTED"))
    }
    
    @objc func dfuProgressDidChange(for part: Int,
                                    outOf totalParts: Int,
                                    to progress: Int,
                                    currentSpeedBytesPerSecond: Double,
                                    avgSpeedBytesPerSecond: Double)
    {
        self.progressDFU.progress = Float(progress) / 100
        print("DFU progress:\(progress)")
    }
    
    func updateFirmware()
    {
        self.labelDFUStatus.text = getString("UPDATE_DOWNLOADING")
        print("DFU start download file \(self.latestFirmwareFileName)")
        self.firmwareDownload?.downLoadFirmwreData(self.latestFirmwareFileName, removeExist: false, callback: { (result, path, error) in
            if (result )
            {
                self.mInDfuState = true
                if let selectedFirmware = try? DFUFirmware.init(urlToZipFile: URL(fileURLWithPath: path!))
                {
                    let queue = DispatchQueue.main
                    let initiator = DFUServiceInitiator.init(queue: queue, delegateQueue: queue, progressQueue: queue, loggerQueue: queue)
                    _ = initiator.with(firmware: selectedFirmware)
                    initiator.delegate = self; // -to be informed about current state and errors
                    initiator.progressDelegate = self; // - to show progress bar
                    self.dfuSrvController = initiator.start(target: self.beacon!.cbPeripheral!)
                }
             }
             else
             {
                self.labelDFUStatus.text = getString("UPDATE_NETWORK_FAIL")
                self.dfuComplete(false, description: error?.localizedDescription ?? "")
             }
        })
    }
    
    func showDialogMsg(_ title:String, message:String)
    {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: UIAlertController.Style.alert)
        
        let OKTitle = getString("DLG_OK");
        let OkAction = UIAlertAction(title: OKTitle, style: UIAlertAction.Style.destructive, handler: nil)
        alertController.addAction(OkAction)
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: Any) {
        if (self.mInDfuState)
        {
            return;
        }
        
        if (self.mFoudNewVersion)
        {
            makesureUpdateSelection()
        }
        else
        {
            self.showDialogMsg(getString("DFU_TITLE_SUCCESS"), message: getString("UPDATE_NOT_FOUND_NEW_VERSION"))
        }
    }
    
    func makesureUpdateSelection()
    {
        let alertController = UIAlertController(title: getString("DFU_TITLE_SUCCESS"),
                                                message: getString("DFU_VERSION_MAKE_SURE"),
                                                preferredStyle: .alert)
        let OkAction = UIAlertAction(title: getString("DLG_OK"),
                                     style: .destructive,
                                     handler: { (action) in
                                        self.progressDFU.progress = 0;
                                        self.mInDfuState = true
                                        
                                        //update
                                        self.mPrivousDelegation = self.beacon!.delegate
                                        self.beacon!.delegate = self;
                                        
                                        //indication
                                        self.indicatorView = IndicatorViewController(title:getString("UPDATE_STARTED"),
                                                                                     center: self.view.center)
                                        self.indicatorView!.startAnimating(self.view)
                                        
                                        //update firmware
                                        self.updateFirmware()
                                     })
        alertController.addAction(OkAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func downloadFirmwareInfo()
    {
        guard let cfgCommon = self.beacon!.getCommonCfg(),
              let model = cfgCommon.getModel(),
              let hdVersion = cfgCommon.getHardwareVersion(),
              let firmwareVersion = cfgCommon.getVersion() else
        {
            NSLog("device does not have hardware version")
            return
        }
        let currVerString = firmwareVersion.substring(from: 1)
        
        //show progress
        self.indicatorView = IndicatorViewController(title: getString("DEVICE_CHECK_UPDATE"),
                                                     center: self.view.center)
        self.indicatorView!.startAnimating(self.view)
        
        firmwareDownload?.downloadFirmwareInfo(model, callback: { (result, info, error) in
            
            self.indicatorView?.stopAnimating()
            
            if (result)
            {
                guard let downInfo = info else
                {
                    self.dfuComplete(false, description: getString("DFU_CLOUDS_SERVER_ERROR"))
                    return
                }
                
                guard let firmwareVerList = downInfo[hdVersion] as? [Any] else
                {
                    self.dfuComplete(false, description: getString("DFU_CLOUDS_FILE_NOT_EXIST"))
                    return
                }
                
                
                var versionNotes : String = ""
                for index in 0..<firmwareVerList.count
                {
                    guard let objVersion = firmwareVerList[index] as? [String:Any],
                        let remoteVersion = objVersion["appVersion"] as? String else
                    {
                        self.dfuComplete(false, description: getString("DFU_CLOUDS_SERVER_ERROR"))
                        return
                    }
                    
                    let remoteVerString = remoteVersion.substring(from: 1)
                    
                    //compare the version
                    if let remoteVerDigital = Float(remoteVerString),
                       let currVerDigital = Float(currVerString),
                       currVerDigital < remoteVerDigital
                    {
                        NSLog("Found new firmware version:\(remoteVerDigital)")
                        
                        guard let appFileName = objVersion["appFileName"] as? String else
                        {
                            self.dfuComplete(false, description: getString("DFU_CLOUDS_SERVER_ERROR"))
                            return;
                        }
                        
                        if let releaseNotes = objVersion["note"] as? String
                        {
                            versionNotes = "\(versionNotes)\n\(releaseNotes)"
                        }

                        //check if it is the last
                        if (index == (firmwareVerList.count - 1))
                        {
                            self.latestFirmwareFileName = appFileName;
                            self.labelDFUVersion.text = remoteVersion
                            self.labelDFUNotes.text = versionNotes
                            self.labelDFUStatus.text = getString("DEVICE_FOUND_VERSION")
                            self.mFoudNewVersion = true
                            
                            self.showDialogMsg(getString("DFU_TITLE_SUCCESS"), message: "A new version\(remoteVersion) found.")
                            return
                        }
                    }
                }
                
                self.dfuComplete(false, description: getString("DEVICE_LATEST_VERSION"))
            }
            else
            {
                self.labelDFUStatus.text = getString("UPDATE_NETWORK_FAIL")
                let subError = error?.localizedDescription ?? ""
                let errorDesc = "\(getString("UPDATE_NETWORK_FAIL")) \(subError)"
                self.dfuComplete(false, description: errorDesc)
            }
        })
    }
}
