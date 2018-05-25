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
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        print("active driver: \(activeDriver), busStation \(busStation), time \(expectedTime)")
        
        showMessageLauncher()
        
        // Do any additional setup after loading the view.
    }
    
    func showMessageLauncher() {
        //window.isUserInteractionEnabled = true
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        whiteView.backgroundColor = UIColor.white
        view.addSubview(blackView)
        view.addSubview(whiteView)
        //view.addSubview(collectionView)
        
        let height: CGFloat = 200
        let y = view.frame.height - height
        whiteView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        blackView.frame = view.frame
        blackView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
         self.blackView.alpha = 1
         self.whiteView.frame = CGRect(x: 0, y: y,
                                       width: self.view.frame.width,
                                       height: self.whiteView.frame.height)
         }, completion: nil)
        
        presentLabelsButtons()
    }
    
    func presentLabelsButtons() {
        let durationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 21))
        //durationLabel.font = UIFont(name: <#T##String#>, size: 20)
        durationLabel.font = durationLabel.font.withSize(20)
        durationLabel.text = "Time till station:"
        durationLabel.backgroundColor = UIColor.white
        whiteView.addSubview(durationLabel)
        
        print("MEGHIVODOOOOOTTTTTTTTTTT")
        durationTextLabel = UILabel(frame: CGRect(x: 100, y: 41, width: 100, height: 21))
        //durationTextLabel.text = "3 Minutes"
        print("az expected time a messageba: \(expectedTime)")
        //durationTextLabel?.font = UIFont(name: "HelveticaNeue-UltraLight", size: 20.0)
        durationTextLabel?.font = durationTextLabel?.font.withSize(20)
        durationTextLabel?.textColor = UIColor.red
        durationTextLabel!.text = String(format: "%d Minutes", Int(expectedTime.rounded()))
        durationTextLabel!.backgroundColor = UIColor.white
        whiteView.addSubview(durationTextLabel!)
        
        let stationLabel = UILabel(frame: CGRect(x: 10, y: 72, width: 100, height: 21))
        stationLabel.text = "To station: "
        stationLabel.backgroundColor = UIColor.white
        whiteView.addSubview(stationLabel)
        
        let stationTextLabel = UILabel(frame: CGRect(x: 110, y: 72, width: 100, height: 21))
        stationTextLabel.text = busStation.title
        stationTextLabel.backgroundColor = UIColor.white
        whiteView.addSubview(stationTextLabel)
        
        //let messageButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 21))
        messageButton = UIButton(type: .system)
        messageButton.frame = CGRect(x: 140, y: 100, width: 200, height: 45)
        messageButton.setTitle("Wait For Me!", for: .normal)
        messageButton.setTitleColor(UIColor.red, for: .normal)
        messageButton.setTitleColor(UIColor.gray, for: .disabled)
        messageButton.backgroundColor = .white
        messageButton.layer.borderWidth = 1
        messageButton.layer.borderColor = UIColor.black.cgColor
        messageButton.isEnabled = {
            return ((self.expectedTime < 100) && (self.activeDriver != "none"))
        }()
        messageButton.addTarget(self, action: #selector(sendMessageButtonPushed), for: .touchUpInside)
        whiteView.addSubview(messageButton)
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
        //print("//////////////////////ideert a probahooooooooooz")
        self.activeDriver = activeDriver
        if let durationTextLabel = durationTextLabel {
            durationTextLabel.text = String(format: "%d Minutes", Int(time.rounded()))
        }
        messageButton.isEnabled = {
            let miez = (self.activeDriver != "none")
            //print("a masodikba az activedriver: \(self.activeDriver)")
            //print("selftime: \(self.expectedTime) es active: \(miez)")
            return ((self.expectedTime < 100) && (self.activeDriver != "none"))
        }()
        //print("a======= busz station \(busStation.title)")
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

