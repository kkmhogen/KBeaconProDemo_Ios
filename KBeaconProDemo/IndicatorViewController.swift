//
//  IndicatorViewController.swift
//  KBeaconProDemo
//
//  Created by hogen on 2021/6/20.
//

import Foundation
import UIKit

class IndicatorViewController
{
    var view: UIView!

    var activityIndicator: UIActivityIndicatorView!

    var title: String!
    
    var animating : Bool = false

    init(title: String, center: CGPoint, width: CGFloat = 200.0, height: CGFloat = 50.0)
    {
        self.title = title

        let x = center.x - width/2.0
        let y = center.y - height/2.0

        self.view = UIView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.view.backgroundColor = UIColor.lightGray//UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 0.5)
        self.view.layer.cornerRadius = 10

        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.activityIndicator.color = UIColor.black
        self.activityIndicator.hidesWhenStopped = false

        let titleLabel = UILabel(frame: CGRect(x: 60, y: 0, width: 200, height: 50))
        titleLabel.text = title
        titleLabel.textColor = UIColor.black

        self.view.addSubview(self.activityIndicator)
        self.view.addSubview(titleLabel)
        animating = false
    }

    func startAnimating(_ parent: UIView)
    {
        if (!animating)
        {
            parent.addSubview(self.view)
            animating = true
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }

    func stopAnimating()
    {
        if (animating)
        {
            animating = false
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()

            self.view.removeFromSuperview()
        }
    }
//end
}
