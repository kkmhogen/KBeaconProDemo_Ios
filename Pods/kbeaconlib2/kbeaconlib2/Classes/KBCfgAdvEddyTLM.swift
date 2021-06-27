//
//  KBCfgAdvEddyTLM.swift
//  KBeacon2
//
//  Created by hogen on 2021/5/24.
//

import Foundation

@objc public class KBCfgAdvEddyTLM : KBCfgAdvBase
{
    public required init()
    {
        super.init(advType: KBAdvType.EddyTLM);
    }
}
