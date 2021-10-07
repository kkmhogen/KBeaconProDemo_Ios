//
//  FileDownloader.swift
//  KBeaconPro
//
//  Created by hogen on 2021/6/18.
//

import Foundation

//
//  FileDownloader.swift
//  KBeaconProDemo
//
//  Created by hogen on 2021/6/18.
//

import Foundation

class FileDownloader
{
    static func loadFileSync(_ webURL: URL, destinationUrl: URL, completion: @escaping (String?, Bool, Error?) -> Void)
    {
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, true, nil)
        }
        else if let dataFromURL = NSData(contentsOf: webURL)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                completion(destinationUrl.path, true, nil)
            }
            else
            {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, false, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, false, error)
        }
    }

    static func loadFileAsync(_ webURL: URL, destinationUrl: URL, completion: @escaping (String?, Bool, Error?) -> Void)
    {
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, true, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: webURL)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                
                var bResult = false
                if error == nil,
                   let response = response as? HTTPURLResponse,
                   response.statusCode == 200,
                   let writeData = data
                {
                    if let _ = try? writeData.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                    {
                        bResult = true
                    }
                }
                
                DispatchQueue.main.async {
                    completion(destinationUrl.path, bResult, error)
                }
            })
            task.resume()
        }
    }
}
