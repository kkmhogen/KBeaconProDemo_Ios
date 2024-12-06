//
//  CfgSensorDataHistoryController.swift
//  KBeaconProDemo
//
//  Created by hogen on 2021/6/23.
//

import Foundation
import UIKit
import MJRefresh
import kbeaconlib2

public class HTSensorTableViewCell : UITableViewCell
{
    @IBOutlet weak var labelUTC: UILabel!
    
    @IBOutlet weak var labelTemperature: UILabel!
    
    @IBOutlet weak var labelHumidity: UILabel!
}

class CfgHTHistoryController : UIViewController,UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var mTableView: UITableView!
    
    public var beacon : KBeacon?
        
    private var mTimerLoading : Timer?
    
    private var mLoadByHeadRefresh: Bool = false
    
    private var mHasReadDataInfo : Bool = false
    
    private var mReadNextRecordPos: UInt32 = 0
    
    private var mRecordMgr : CfgHTRecordFileMgr?
    
    //The timeout period for reading sensor data needs to be adjusted according to the number of records in the read area.
    //We recommend that you have a timeout of 10 seconds for every 100 records.
    //If 600 records are read at a time, the recommended timeout period is 60 seconds.
    static let HISTORY_LOAD_TIMEOUT_SEC = 40.0

    static let INVALID_DATA_RECORD_POS  = UInt32(0xFFFFFFFF)
    
    static let MIN_UTC_TIME_SECONDS = UInt32(946080000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        mRecordMgr = CfgHTRecordFileMgr(beacon!.mac!)

        self.mTableView.delegate = self;
        self.mTableView.dataSource = self;
                
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.separatorInset = UIEdgeInsets.zero;
        mTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        self.setupUpRefreshCtrl()
        
        self.mTableView.mj_header?.beginRefreshing()
    }
    
    func setupUpRefreshCtrl()
    {
        self.mTableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self,
                                                          refreshingAction: #selector(reloadHistoryRecord))
        self.mTableView.mj_header!.isAutomaticallyChangeAlpha = true
    }
    
    @objc func reloadHistoryRecord()
    {
        if (!self.mHasReadDataInfo)
        {
            startReadFirstPage()
        }
        else
        {
            startReadNextRecordPage()
        }
    }
    
    func startReadFirstPage()
    {
        //set status to loading
        self.beacon!.readSensorDataInfo(KBSensorType.HTHumidity, callback: { (result, infoRsp, exception) in
            if (!result)
            {
                self.mTimerLoading?.invalidate()
                self.mTableView.mj_header!.endRefreshing()
                self.showMsgDlog(title: "failed", message: getString("LOAD_HISTORY_DATA_FAILED"))
                return
            }

            self.mHasReadDataInfo = true
            if let htInfoPara = infoRsp
            {
                if (htInfoPara.unreadRecordNumber == 0)
                {
                    self.showNoMoreDataMessage(0)
                }
                else
                {
                    self.startReadNextRecordPage()
                }
            }
        })
        
        self.mTimerLoading?.invalidate()
        self.mTimerLoading = Timer.scheduledTimer(
            withTimeInterval: CfgHTHistoryController.HISTORY_LOAD_TIMEOUT_SEC,
            repeats: false,
            block: { (timer) in
            self.showMsgDlog(title: "failed", message: getString("LOAD_HISTORY_DATA_TIMEOUT"))
            self.mTableView.mj_header!.endRefreshing()
        })
    }
    
    //for override
    func parseReadKBRecordResponse(_ rspList : [NSObject] )->[CfgHTHistoryRecord]
    {
        var cfgList : [CfgHTHistoryRecord] = []
        
        for cutRecord in rspList
        {
            if let dataRsp = cutRecord as? KBRecordHumidity
            {
                let htRecord = CfgHTHistoryRecord()
                htRecord.record = dataRsp
                cfgList.append(htRecord)
            }
        }
        
        return cfgList
    }

    func startReadNextRecordPage()
    {
        self.beacon!.readSensorRecord(KBSensorType.HTHumidity,
                                      number: KBRecordDataRsp.INVALID_DATA_RECORD_POS,
                                      option: KBSensorReadOption.NewRecord,
                                      max: 400,
                                      callback: { (result, recordRsp, exception) in
                        if (!result)
                        {
                            self.mTimerLoading?.invalidate()
                            self.showMsgDlog(title: "failed", message: getString("LOAD_HISTORY_DATA_FAILED"))
                            return
                        }

                        if let dataRsp = recordRsp
                        {
                            //add data
                            let htRecordList = self.parseReadKBRecordResponse(dataRsp.readDataRspList)
                            self.mRecordMgr!.appendRecords(htRecordList)

                            if (dataRsp.readDataNextPos == KBRecordDataRsp.INVALID_DATA_RECORD_POS)
                            {
                                self.showNoMoreDataMessage(dataRsp.readDataRspList.count)
                            }
                            else
                            {
                                self.showLoadDataComplete(dataRsp.readDataRspList.count)
                            }
                        }
                      })
    }
    
    func showNoMoreDataMessage(_ readNum: Int)
    {
        self.mTableView.mj_header?.endRefreshing()
        mTimerLoading?.invalidate()
        self.mTableView.reloadData()

        let strMsg = String(format: getString("load_data_complete_no_more_data"), readNum)
        self.showMsgDlog(title: "success", message: strMsg)

        self.mRecordMgr?.saveRecordsToFile()
    }

    func showLoadDataComplete(_ nReadedMsgNum: Int)
     {
        self.mTableView.mj_header?.endRefreshing()
        
        let strMsg = String(format: getString("load_data_complete"), nReadedMsgNum)
        self.showMsgDlog(title: "success", message: strMsg)
        mRecordMgr?.saveRecordsToFile()
        
        mTimerLoading?.invalidate()
        self.mTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mRecordMgr!.size
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier:"seqHTRecordCell") as? HTSensorTableViewCell,
           let object = self.mRecordMgr!.get(index: indexPath.row)
        {
            let strUTCTime = self.mRecordMgr!.localTimeFromUTCSeconds(object.record.utcTime)
            cell.labelUTC.text = strUTCTime
            cell.labelTemperature.text =  String(format:"%@: %.2f%@",
                                                 arguments: [getString("BEACON_TEMP"),
                                                             object.record.temperature,
                                getString("BEACON_TEMP_UINT")])
            
            cell.labelHumidity.text =  String(format:"%@: %.2f% %",
                                              arguments: [getString("BEACON_HUM"),
                                                          object.record.humidity])
            return cell
        }else{
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func showMsgDlog(title:String, message:String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let OKTitle = NSLocalizedString("DLG_OK", comment:"");
        let OkAction = UIAlertAction(title: OKTitle, style: UIAlertAction.Style.destructive, handler: nil)
        alertController.addAction(OkAction)
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
  
    
    @IBAction func onClear(_ sender: Any) {
    
        let alertController = UIAlertController.init(title: getString("nb_clear_history_warning"),
                                                     message: getString("nb_clear_history_description"),
                                                     preferredStyle: .alert)
            
        //cancel action
        let cancelAction = UIAlertAction(title: getString("DLG_CANCEL"), style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
        //ok action
        let okAction = UIAlertAction(title: getString("DLG_OK"), style: .default) { (action) in
            self.beacon!.clearSensorRecord(KBSensorType.HTHumidity,
                                          callback: { (result, obj, except) in
                if result
                {
                    self.mRecordMgr?.clearHistoryRecord()
                    self.mTableView.reloadData()
                    self.showMsgDlog(title: getString("success"), message: getString("upload_data_success"))
                }
                else
                {
                    let strFail = "\(getString("upload_config_data_failed")),code:\(except?.errorCode ?? 0)"
                    self.showMsgDlog(title: "failed", message:strFail)
                }
            })
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func onExport(_ sender: Any) {
        if let strHistory = mRecordMgr?.exportRecordsToString()
        {
            if let emailContent = strHistory.addingPercentEncoding(withAllowedCharacters: (NSMutableCharacterSet.urlQueryAllowed)),
               let emailURL = URL(string: emailContent)
            {
                UIApplication.shared.open(emailURL)
            }
        }
    }
}
