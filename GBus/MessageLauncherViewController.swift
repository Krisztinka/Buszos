//
//  MessageLauncherViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 27/03/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit

class MessageLauncherViewController: UIViewController {
    let blackView = UIView()
    let whiteView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
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
        
        
        let durationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 21))
         //durationLabel.font = UIFont(name: <#T##String#>, size: 20)
         durationLabel.font = durationLabel.font.withSize(20)
         durationLabel.text = "Time till station:"
         durationLabel.backgroundColor = UIColor.blue
         whiteView.addSubview(durationLabel)
         
         let durationTextLabel = UILabel(frame: CGRect(x: 100, y: 41, width: 100, height: 21))
         durationTextLabel.text = "3 Minutes"
         durationTextLabel.backgroundColor = UIColor.darkGray
         whiteView.addSubview(durationTextLabel)
         
         let stationLabel = UILabel(frame: CGRect(x: 10, y: 72, width: 100, height: 21))
         stationLabel.text = "To station: "
         stationLabel.backgroundColor = UIColor.red
         whiteView.addSubview(stationLabel)
         
         let stationTextLabel = UILabel(frame: CGRect(x: 110, y: 72, width: 100, height: 21))
         stationTextLabel.text = "Napoca"
         stationTextLabel.backgroundColor = UIColor.cyan
         whiteView.addSubview(stationTextLabel)
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

}
