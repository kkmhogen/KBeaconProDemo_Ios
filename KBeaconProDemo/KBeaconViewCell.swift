//
//  KBeaconViewCell.swift
//  KBeaconProDemo
//
//  Created by hogen on 2021/6/9.
//

import Foundation
import UIKit
import kbeaconlib2

public class KBeaconViewCell : UITableViewCell
{
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    @IBOutlet weak var majorLabel: UILabel!
    
    @IBOutlet weak var minorLabel: UILabel!
    
    @IBOutlet weak var macLabel: UILabel!
    
    @IBOutlet weak var connectableLabel: UILabel!
    
    @IBOutlet weak var voltageLabel: UILabel!
    
    @IBOutlet weak var uuidLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var accAxisLabel: UILabel!
    
    @IBOutlet weak var sensorView: UIStackView!
    
    public weak var beacon:KBeacon?
    
}
