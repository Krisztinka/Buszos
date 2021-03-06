//
//  MessageLauncherViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 27/03/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit

protocol MessageLauncherDelegate: class {
    func sendMessageToDriver(driver: String)
}

class MessageLauncherViewController: UIViewController {
    let blackView = UIView()
    let whiteView = UIView()
    
    var durationTextLabel: UILabel?
    var messageButton: UIButton!
    
    var activeDriver: String = "none"
    var busStation = BusStation()
    weak var delegate: MessageLauncherDelegate?
    
    var expectedTime: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("active driver: \(activeDriver), busStation \(busStation), time \(expectedTime)")
        
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
        
        whiteView.translatesAutoresizingMaskIntoConstraints = false
        blackView.translatesAutoresizingMaskIntoConstraints = false
        
        whiteView.backgroundColor = UIColor.white
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        self.view.addSubview(whiteView)
        self.view.addSubview(blackView)
        
        createControls()
    }
    
    func createControls() {
        let clockImage = UIImage(named: "Appointments")
        let clockImageView = UIImageView(image: clockImage!)
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(clockImageView)
        
        durationTextLabel = UILabel()
        durationTextLabel!.font = durationTextLabel?.font.withSize(20)
        durationTextLabel!.textColor = UIColor.red
        durationTextLabel!.text = String(format: "%d Minutes", Int(expectedTime.rounded()))
        durationTextLabel!.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(durationTextLabel!)
        
        let stationLabel = UILabel()
        stationLabel.text = "To station: "
        stationLabel.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(stationLabel)
        
        let stationTextLabel = UILabel()
        stationTextLabel.text = busStation.title
        stationTextLabel.font = stationTextLabel.font.withSize(18)
        stationTextLabel.translatesAutoresizingMaskIntoConstraints = false
        whiteView.addSubview(stationTextLabel)
        
        messageButton = UIButton(type: .system)
        messageButton.setTitle("Wait For Me!", for: .normal)
        messageButton.titleLabel?.font = durationTextLabel?.font.withSize(20)
        messageButton.setTitleColor(UIColor.red, for: .normal)
        messageButton.setTitleColor(UIColor.gray, for: .disabled)
        messageButton.backgroundColor = .white
        messageButton.layer.cornerRadius = 10
        messageButton.layer.borderWidth = 1
        messageButton.layer.borderColor = UIColor.black.cgColor
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.isEnabled = {
            return ((self.expectedTime < 100) && (self.activeDriver != "none"))
        }()
        messageButton.addTarget(self, action: #selector(sendMessageButtonPushed), for: .touchUpInside)
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
            "durationTextLabel": durationTextLabel!,
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
            withVisualFormat: "V:|-70-[vline2View(30)]",
            metrics: nil,
            views: views)
        allConstraints += vertical3Constraints
        
        let iconVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-18-[clockImageView(35)]-10-[lineView(1)]-10-[stationLabel(20)]", metrics: nil,views: views)
        let labelVerticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[durationTextLabel(25)]-21-[stationTextLabel(25)]-20-[messageButton(40)]", metrics: nil, views: views)
        let iconHorizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[clockImageView(35)]-43-[vlineView(1)]-[durationTextLabel]-|", metrics: nil, views: views)
        allConstraints += iconVerticalConstraints
        allConstraints += labelVerticalConstraints
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
    
    @objc func handleDismiss() {
        print("meg kene hivodjon\n\n")
        UIView.animate(withDuration: 0.5) {
            self.blackView.alpha = 0
            self.whiteView.frame = CGRect(x: 0, y: self.view.frame.height,
                                          width: self.whiteView.frame.width,
                                          height: self.whiteView.frame.height)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sendMessageButtonPushed() {
        print("megnyomtam a send gombot!!!!!!!!!!!!!")
        //durationTextLabel!.text = String(format: "%d Minutes", Int(expectedTime.rounded()) + 1)
        delegate?.sendMessageToDriver(driver: activeDriver)
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("---MessageLauncher destructor called.---")
    }
    
    func timeChanged(time: Double, activeDriver: String) {
        self.activeDriver = activeDriver
        if let durationTextLabel = durationTextLabel {
            durationTextLabel.text = String(format: "%d Minutes", Int(time.rounded()))
        }
        messageButton.isEnabled = {
            return ((self.expectedTime < 100) && (self.activeDriver != "none"))
        }()
    }
    
    func driverStateChanged(driver: String) {
        self.activeDriver = driver
        if driver == "none" {
            messageButton.isEnabled = false
        }
        /*else {    !!!!!!!!!!!!!!!!!!!ha visszalep a sofor akkor is emg kell nezzuk az idot es enable-juk a gombot ha ez megfelelo idoben odaerne a megalloba
            messageButton.isEnabled = true
        }*/
    }

}

