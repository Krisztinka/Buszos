//
//  EditAnnouncementTableViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 23/05/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase

class EditAnnouncementTableViewController: UITableViewController {

    @IBOutlet weak var importantSwitch: UISwitch!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    var activeAnnouncement: Announcement?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTouched))
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let activeAnnouncement = activeAnnouncement {
            importantSwitch.isOn = activeAnnouncement.important == "true" ? true : false
            titleTextField.text = activeAnnouncement.title
            messageTextView.text = activeAnnouncement.message
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    @objc func saveTouched() {
        let timestamp = Int(NSDate.timeIntervalSinceReferenceDate)
        let fromId = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("announcements").child(activeAnnouncement!.key)
            .updateChildValues(["fromId": fromId!,
                    "important": String(importantSwitch.isOn),
                    "message": messageTextView.text,
                    "title": titleTextField.text!,
                    "timestamp": timestamp])
        
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Saved"
        let delayInSeconds = 0.6
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds,
            execute: {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        print("switch changed to: \(sender.isOn)")
    }
    
    deinit {
        print("az editAnnouncement bezarodott")
    }

}
