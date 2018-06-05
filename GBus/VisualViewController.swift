//
//  VisualViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 05/06/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit

class VisualViewController: UIViewController {
    var szam = 333
    let whiteView = UIView()
    let blackView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("A szam \(szam)")

        //self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
        
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        blackView.translatesAutoresizingMaskIntoConstraints = false
        
        whiteView.backgroundColor = UIColor.white
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        self.view.addSubview(whiteView)
        self.view.addSubview(blackView)
        
        createControls()
        
        /*UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 1
            self.whiteView.frame = CGRect(x: 0, y: y,
                                          width: self.view.frame.width,
                                          height: self.whiteView.frame.height)
        }, completion: nil)*/
    }
    
    func createControls() {
        let clockImage = UIImage(named: "Appointments")
        let clockImageView = UIImageView(image: clockImage!)
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(clockImageView)
        
        let durationTextLabel = UILabel()
        durationTextLabel.font = durationTextLabel.font.withSize(20)
        durationTextLabel.textColor = UIColor.red
        durationTextLabel.text = String(format: "5 Minutes")
        durationTextLabel.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(durationTextLabel)

        let stationLabel = UILabel()
        stationLabel.text = "To station: "
        stationLabel.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(stationLabel)

        let stationTextLabel = UILabel()
        stationTextLabel.text = "Napoca-Est-Sud"
        stationTextLabel.translatesAutoresizingMaskIntoConstraints = false
        stationLabel.backgroundColor = UIColor.cyan
        stationTextLabel.backgroundColor = UIColor.green
        whiteView.addSubview(stationTextLabel)

        let messageButton = UIButton(type: .system)
        messageButton.setTitle("Wait For Me!", for: .normal)
        messageButton.titleLabel?.font = durationTextLabel.font.withSize(20)
        messageButton.setTitleColor(UIColor.red, for: .normal)
        messageButton.setTitleColor(UIColor.gray, for: .disabled)
        messageButton.backgroundColor = .white
        messageButton.layer.cornerRadius = 5
        messageButton.layer.borderWidth = 1
        messageButton.layer.borderColor = UIColor.black.cgColor
        messageButton.translatesAutoresizingMaskIntoConstraints = false
//        messageButton.isEnabled = {
//            return ((self.expectedTime < 100) && (self.activeDriver != "none"))
//        }()
//        messageButton.addTarget(self, action: #selector(sendMessageButtonPushed), for: .touchUpInside)
        whiteView.addSubview(messageButton)
        
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.layer.borderWidth = 1.0
        lineView.layer.borderColor = UIColor.darkGray.cgColor
        //lineView.backgroundColor = UIColor.black
        whiteView.addSubview(lineView)
        
        let vlineView = UIView()
        vlineView.translatesAutoresizingMaskIntoConstraints = false
        vlineView.layer.borderWidth = 1.0
        vlineView.layer.borderColor = UIColor.darkGray.cgColor
        //vlineView.backgroundColor = UIColor.black
        whiteView.addSubview(vlineView)
        
        let vline2View = UIView()
        vline2View.translatesAutoresizingMaskIntoConstraints = false
        vline2View.layer.borderWidth = 1.0
        vline2View.layer.borderColor = UIColor.darkGray.cgColor
        //vlineView.backgroundColor = UIColor.black
        whiteView.addSubview(vline2View)
        
        let views: [String: Any] = [
            "whiteView": whiteView,
            "blackView": blackView,
            "clockImageView": clockImageView,
            "durationTextLabel": durationTextLabel,
            "stationLabel": stationLabel,
            "stationTextLabel": stationTextLabel,
            "messageButton": messageButton,
            "lineView": lineView,
            "vlineView": vlineView,
            "vline2View": vline2View]
        
        var allConstraints: [NSLayoutConstraint] = []
        
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[whiteView]|",
            metrics: nil,
            views: views)
        allConstraints += horizontalConstraints
        let horizontal2Constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[blackView]|",
            metrics: nil,
            views: views)
        allConstraints += horizontal2Constraints
        let horizontal3Constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-25-[lineView]-25-|",
            metrics: nil,
            views: views)
        allConstraints += horizontal3Constraints
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[blackView][whiteView(170)]|",
            metrics: nil,
            views: views)
        allConstraints += verticalConstraints
        let vertical2Constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-25-[vlineView(30)]",
            metrics: nil,
            views: views)
        allConstraints += vertical2Constraints
        let vertical3Constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-68-[vline2View(30)]",
            metrics: nil,
            views: views)
        allConstraints += vertical3Constraints
        
        let iconVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-18-[clockImageView(35)]-10-[lineView(1)]-10-[stationLabel(20)]",
            metrics: nil,
            views: views)
        allConstraints += iconVerticalConstraints
        let iconVertical2Constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-25-[durationTextLabel(25)]-21-[stationTextLabel(25)]-20-[messageButton(40)]",
            metrics: nil,
            views: views)
        allConstraints += iconVertical2Constraints
        let iconHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-40-[clockImageView(35)]-43-[vlineView(1)]-[durationTextLabel]-|",
            metrics: nil,
            views: views)
        allConstraints += iconHorizontalConstraints
        let iconHorizontal2Constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-25-[stationLabel(80)]-13-[vline2View(1)]-10-[stationTextLabel]-|",
            metrics: nil,
            views: views)
        allConstraints += iconHorizontal2Constraints
        let iconHorizontal3Constraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[messageButton(200)]-10-|",
            metrics: nil,
            views: views)
        allConstraints += iconHorizontal3Constraints
        
        self.view.addConstraints(allConstraints)
        NSLayoutConstraint.activate(allConstraints)
    }

}
