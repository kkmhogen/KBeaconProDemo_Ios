//
//  KBFirmwareDownload.swift
//  KBeaconPro
//
//  Created by hogen on 2021/6/18.
//

import Foundation
import UIKit

public typealias onHttpFirmwareDataDownComplete = (_ result:Bool, _ path: String?, _ error:Error?)->Void

public typealias onHttpFirmwareInfoDownCallback = (_ result:Bool, _ info: [String:Any]?, _ error:Error?)->Void

public class KBFirmwareDownload : NSObject
{
    var firmwareWebAddress : String
    static let HEX_PATH_NAME  = "KBeaconFirmware"
    static let DEFAULT_DOWNLOAD_WEB_ADDRESS = "https://api.ieasygroup.com:8092/KBeaconFirmware/"
    
    override public init() {
        firmwareWebAddress = KBFirmwareDownload.DEFAULT_DOWNLOAD_WEB_ADDRESS
    }

    func makeSureFileDirectory(_ name : String)->String?
    {
        let fileManager = FileManager()
        let pathDocuments = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let pathDocument = pathDocuments[0]
        let createPath = "\(pathDocument)/\(name)/"
        if (!FileManager.default.fileExists(atPath: createPath))
        {
            guard let _ = try? fileManager.createDirectory(atPath: createPath, withIntermediateDirectories: true, attributes: nil) else
            {
                return nil
            }
        }
        
        return createPath
    }
    
    public func downloadFirmwareInfo(_ model: String, callback:  @escaping onHttpFirmwareInfoDownCallback)
    {
        let urlStr = "\(model).json"
        self.downLoadFirmwreData(urlStr, callback: { (result, destPath, error) in
            if (!result)
            {
                callback(false, nil, error);
                return
            }
            else
            {
                do{
                    let resultData = try String(contentsOfFile: destPath!, encoding: .utf8)
                    if let jsonData = resultData.data(using: .utf8),
                       let dics = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String:Any]
                    {
                        callback(true, dics, nil)
                        return
                    }
                } catch {
                    print(error)
                }

                callback(false, nil, nil);
            }
        })
    }

    public func downLoadFirmwreData(_ filename: String, callback: @escaping onHttpFirmwareDataDownComplete)
    {
        let urlPath = "\(self.firmwareWebAddress)\(filename)"
        let webUrl = URL(string: urlPath)
        let filePath = makeSureFileDirectory(KBFirmwareDownload.HEX_PATH_NAME)
        if (filePath == nil)
        {
            return;
        }
        
        let writeFilePath = filePath?.appending(webUrl!.lastPathComponent)
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: writeFilePath!))
        {
            try? fileManager.removeItem(atPath: writeFilePath!)
        }
        
       
        let destURL = URL(fileURLWithPath: writeFilePath!)
        FileDownloader.loadFileAsync(webUrl!, destinationUrl: destURL, completion: { (savedPath, result, error) in
            if (!result)
            {
                callback(false, nil, error);
            }
            else
            {
                callback(true, savedPath, nil);
            }
        })
    }
}
