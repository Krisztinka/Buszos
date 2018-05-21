//
//  CreateAnnouncementViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 20/05/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase

class CreateAnnouncementViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        //messageTextView.delegate = self

        //hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        titleTextField.resignFirstResponder()
        messageTextView.resignFirstResponder()
    }
    
    @IBAction func publishButtonPushed(_ sender: UIButton) {
        print("megnyomtam")
        if titleTextField.text != "", messageTextView.text != "" {
            print("if")
            let timestamp = Int(NSDate.timeIntervalSinceReferenceDate)
            let databaseRef = Database.database().reference().child("announcements")
            let fromId = Auth.auth().currentUser?.uid
            let values = ["fromId": fromId!,
                          "title": titleTextField.text,
                          "timestamp": timestamp,
                          "message": messageTextView.text] as [String : Any]
            let childRef = databaseRef.childByAutoId()
            childRef.updateChildValues(values)
        }
        else {
            print("else")
            messageTextView.text = "nem voltak helyesen kitoltve!"
            //view.reloadInputViews()
        }
        titleTextField.text = ""
        messageTextView.text = "Write your message here!"
        
    }
}

extension CreateAnnouncementViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        return true
    }
}
