//
//  EditProfileTableViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 08/05/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit

protocol EditProfileTableViewControllerDelegate: class {
    func updateProfile(passenger: Passenger)
}

class EditProfileTableViewController: UITableViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var showLocationSwitch: UISwitch!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    weak var delegate: EditProfileTableViewControllerDelegate?
    var passenger: Passenger?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload")
        passenger?.writeData()
        
        doneButton.title = "Done"
        emailTextField.isEnabled = false
        nameTextField.delegate = self
        surnameTextField.delegate = self
        oldPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if let passenger = passenger {
            nameTextField.text = passenger.name
            surnameTextField.text = passenger.surname
            emailTextField.text = passenger.email
        }
        
    }

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 2
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 3
//    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        if doneButton.title == "Done" {
            print("Done volt megnyomva")
        }
        else if doneButton.title == "Save" {
            print("Save volt megnyomva")
            if nameTextField.text != "", surnameTextField.text != "" {
                passenger?.name = nameTextField.text!
                passenger?.surname = surnameTextField.text!
            }
            delegate?.updateProfile(passenger: passenger!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("Az editProfile bezarodott.")
    }

}

extension EditProfileTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        doneButton.title = "Save"
    }
}
