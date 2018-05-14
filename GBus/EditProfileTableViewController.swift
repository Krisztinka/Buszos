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
    func resetPassword()
    func stopLocation(value: Bool)
}

class EditProfileTableViewController: UITableViewController {
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var showLocationSwitch: UISwitch!
    
    weak var delegate: EditProfileTableViewControllerDelegate?
    var passenger: Passenger?
    var isSwitchOn: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewdidload")
        passenger?.writeData()
        if let isSwitchOn = isSwitchOn {
            print("van erteke a switchnek<<<<<<<<")
            showLocationSwitch.isOn = isSwitchOn
        }
        
        doneButton.title = "Done"
        emailTextField.isEnabled = false
        nameTextField.delegate = self
        surnameTextField.delegate = self
        //tableView.allowsSelection = false
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
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if ( indexPath.section == 0 ) {
            return nil;
        }
        else if (indexPath.section == 1 && indexPath.row == 0) {
            return nil;
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ( indexPath.section == 1 ) {
            if indexPath.row == 1 {
                print("reset hivodik")
                delegate?.resetPassword()
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        if doneButton.title == "Done" {
            print("Done volt megnyomva")
            dismiss(animated: true, completion: nil)
        }
        else if doneButton.title == "Save" {
            print("Save volt megnyomva")
            //itt a fenti adatokat: nev es alnev mentjuk
            if nameTextField.text != passenger?.name || surnameTextField.text != passenger?.surname {
                //ha kulonbozik amit beirt az eddigitol, akkor update kell
                if checkErrorNames(text: nameTextField.text!) == "correct", checkErrorNames(text: surnameTextField.text!) == "correct" {
                    passenger?.name = nameTextField.text!
                    passenger?.surname = surnameTextField.text!
                    delegate?.updateProfile(passenger: passenger!)
                    dismiss(animated: true, completion: nil)
                }
                else {
                    presentAlert()
                }
            }
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        showLocationSwitch.isOn = sender.isOn
        print(sender.isOn)
        delegate?.stopLocation(value: showLocationSwitch.isOn)
    }
    
    func presentAlert() {
        //alert-et adunk mert nem toltotte ki helyesen az adatokat
        let alert = UIAlertController(title: "Error!", message: "The update process was interrupted, because the format is not the accepted one.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func checkErrorNames(text: String) -> String {
        //let nameRegex = "[A-Za-z-]{2,20}"
        let nameRegex = "[A-Za-z]{1}[A-Za-z- ]{1,20}"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if ( nameTest.evaluate(with: text) == true ) {
            return "correct"
        }
        else {
            return "incorrect"
        }
    }
    
    deinit {
        print("Az editProfile bezarodott.")
    }

}

extension EditProfileTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        doneButton.title = "Save"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
