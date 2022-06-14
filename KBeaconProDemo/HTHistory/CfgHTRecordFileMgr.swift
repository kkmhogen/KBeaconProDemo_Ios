//
//  CfgHTRecordFileMgr.swift
//  KBeaconProDemo
//
//  Created by hogen on 2021/6/23.
//

import Foundation
import kbeaconlib2

class CfgHTRecordFileMgr : NSObject
{
    public var mSensorRecordList = [CfgHTHistoryRecord]()
    
    let RECORD_FILE_NAME_PREFEX = "_ht_sensor_record.txt"
    let RECORD_FILE_NAME = "_ht_sensor_record.txt"
    
    //private
    private var mRecordFileName : String
    
    private var mDeviceMac : String
    
    private var mIsFileChange : Bool = false
    
    public var size : Int{
        get{
            return self.mSensorRecordList.count
        }
    }
    
    init(_ mac:String)
    {
        let strMacAddress = mac.replacingOccurrences(of: ":", with: "")
        mRecordFileName = "\(strMacAddress)\(RECORD_FILE_NAME_PREFEX)";
        mDeviceMac = strMacAddress;
        mSensorRecordList = [CfgHTHistoryRecord]()

        //read record from file
        let pathDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let pathFileName = pathDocuments[0].appending("/\(mRecordFileName)")
        if let recordArray = NSArray(contentsOf: URL(fileURLWithPath: pathFileName))
        {
            for obj in recordArray
            {
                if let dicts = obj as? [String:Any]
                {
                    mSensorRecordList.append(CfgHTHistoryRecord(dicts: dicts))
                }
            }
        }

        
        super.init()
    }
    
    func documentsPath(_ fileName: String)->String
    {
        let pathDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let pathDocument = pathDocuments[0]
        return pathDocument.appending("/\(fileName)")
    }

    func bundlePath(fileName:String)->String
    {
        return Bundle.main.bundleURL.appendingPathComponent(fileName).path
    }
    
    func get(index : Int)->CfgHTHistoryRecord?
    {
        let nMaxIndex = self.mSensorRecordList.count - 1
        let nReverseIndex =  nMaxIndex - index
        
        return self.mSensorRecordList[nReverseIndex]
    }

    func appendRecords(_ recordList : [CfgHTHistoryRecord])
    {
        for  record in recordList
        {
            self.mSensorRecordList.append(record)
        }
        mIsFileChange = true
    }
    
    func appendRecord(_ record : CfgHTHistoryRecord)
    {
        self.mSensorRecordList.append(record)
        mIsFileChange = true
    }

    func exportRecordsToString()->String?
    {
        if (self.mSensorRecordList.count <= 0)
        {
            return nil
        }
        
        var strBUilder = String()
        strBUilder.append("mailto:your_email@example.com?")
        
        //title
        let strTitle = "\(getString("EXPORT_SENSOR_HISTORY_DATA_TITLE"))\(mDeviceMac)"
        strBUilder.append(strTitle)

        let strWriteLine = "&body=UTC \t Temperature \t Humidity\n"
        strBUilder.append(strWriteLine)

        for object in self.mSensorRecordList
        {
            let strNearbyUtcTime = localTimeFromUTCSeconds(object.record.utcTime)
            let strWriteLine = String(format:"%@\t%.2f\t%.2f\n",
                                      strNearbyUtcTime, object.record.temperature, object.record.humidity)
            strBUilder.append(strWriteLine)
        }
        
        return strBUilder
    }
    
    func localTimeFromUTCSeconds(_ utcSecond : UInt32)->String
    {
        let date = Date(timeIntervalSince1970: Double(utcSecond))
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        return dateString
    }

    func saveRecordsToFile()
    {
        if (mIsFileChange)
        {
            let strPath = documentsPath(mRecordFileName)
            
            let saveArray = NSMutableArray()
            for record in self.mSensorRecordList
            {
                saveArray.add(record.toDictory())
            }
            
            //write content to file
            let bWriteRslt = saveArray.write(toFile: strPath, atomically: true)
            if (!bWriteRslt)
            {
                NSLog("write data to file failed")
            }
        }
    }

    func clearHistoryRecord()
    {
        self.mSensorRecordList.removeAll()
        self.saveRecordsToFile()
    }

}
