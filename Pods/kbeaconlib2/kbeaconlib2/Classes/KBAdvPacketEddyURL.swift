//
//  KBAdvPacketEddyURL.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/23.
//

import Foundation

@objc public class KBAdvPacketEddyURL : KBAdvPacketBase
{
    static let MIN_EDDYSTONE_ADV_LEN = 4
    
    private static let EDDYSTONE_URL_ENCODING_MAX = 14
    private static let  EDDYSTONE_URL_PREFIX_MAX = 4
    private static let eddystoneURLPrefix = ["http://www.",
        "https://www.",
        "http://",
        "https://"]

    private static let eddystoneURLEncoding = [
        ".com/",
        ".org/",
        ".edu/",
        ".net/",
        ".info/",
        ".biz/",
        ".gov/",
        ".com/",
        ".org/",
        ".edu/",
        ".net/",
        ".info/",
        ".biz/",
        ".gov/"]
    
    //eddy url address
    @objc public var url : String = ""

    //tx power at 0 cent-meter
    @objc public var refTxPower: Int8 = -24
    
    internal required init() {
        super.init()
    }
    
    @objc public override func getAdvType()->Int
    {
        return KBAdvType.EddyURL;
    }

    internal override func parseAdvPacket(_ data:Data, index:Int)->Bool
    {
        super.parseAdvPacket(data, index:index)
        
        //check length
        if (data.count - index < KBAdvPacketEddyURL.MIN_EDDYSTONE_ADV_LEN)
        {
            return false;
        }
        var nSrvIndex = index
        
        //ref tx power
        refTxPower = Int8(bitPattern:data[nSrvIndex])
        nSrvIndex += 1
        
        //url
        url = KBAdvPacketEddyURL.decodeURL(data, index: nSrvIndex)
        
        return true;
    }

    //decode advertisement content to url address
    @objc public static func decodeURL(_ data: Data, index:Int=0) ->String
    {
        var decodeURL = ""
        
        //first
        var nPrseIndex = index
        let encHead = Int(data[nPrseIndex])
        if (encHead > EDDYSTONE_URL_PREFIX_MAX)
        {
            return decodeURL;
        }
        nPrseIndex += 1
        
        //add url head
        let urlPrefex = KBAdvPacketEddyURL.eddystoneURLPrefix[encHead];
        decodeURL.append(urlPrefex)
        
        //add middle web
        while (nPrseIndex < data.count)
        {
            if (data[nPrseIndex] <= EDDYSTONE_URL_ENCODING_MAX)
            {
                let urlSuffix = eddystoneURLEncoding[Int(data[nPrseIndex])];
                decodeURL.append(urlSuffix)
            }
            else
            {
                let urlChar = Character(UnicodeScalar(data[nPrseIndex]))
                decodeURL.append(urlChar)
            }
            nPrseIndex += 1
        }
        
        return decodeURL;
    }

}
