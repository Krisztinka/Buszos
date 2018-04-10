//
//  RegisterViewController.swift
//  GBus
//
//  Created by macmini on 3/5/18.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var nameImage: UIImageView!
    @IBOutlet weak var textFieldSurname: UITextField!
    @IBOutlet weak var surnameImage: UIImageView!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var textFieldPassword2: UITextField!
    @IBOutlet weak var password2Image: UIImageView!
    @IBOutlet weak var registerButton: UIButton!
    var okForm = false
    var okUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFieldName.delegate = self
        self.textFieldSurname.delegate = self
        self.textFieldEmail.delegate = self
        self.textFieldPassword.delegate = self
        self.textFieldPassword2.delegate = self
        
        //amikor bejelentkezunk, ez az observer eszreveszi hogy valami valtozott es vegrehajtja a closure-t
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("bejott\n")
            if user != nil {
                let uid = Auth.auth().currentUser?.uid
                //uid segitsegevel emgkapjuk a snapshotot, hogy megnezhessuk hogy driver vagy nem
                Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
                    print("bejott masodikba\n")
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        print(dictionary["driver"] as? String)
                        if (dictionary["driver"] as? String) == nil {
                            self.performSegue(withIdentifier: "RegisteredPassanger", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "RegisteredDriver", sender: self)
                        }
                    }
                })
            }
        }

    }
    
    //tunjon el a popUp
    @IBAction func dismissPopUp(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //megnyomtam a register gombot
    @IBAction func registerPushed(_ sender: UIButton) {
        //let returnValue = handleRegister()
        handleRegister()
        print("\nez komplikalt: \(okForm) es \(okUser)\n")
        if okForm == false {
            formIncompleteAlert()
        }
        //performSegue(withIdentifier: "registeredSuccessfully", sender: sender)
    }
    
    //reference to Firebase database
    //var ref: DatabaseReference!
    func handleRegister(){
        guard let name = textFieldName.text, name != "", let surname = textFieldSurname.text, surname != "", let email = textFieldEmail.text, email != "", let password = textFieldPassword.text, password != "", textFieldPassword2.text != "" else {
            print("Form is not valid")
            okForm = false
            return
            //return 1    //the form is not completed
        }
        okForm = true
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user: User?, error) in
            if error != nil {
                print("\nERRORRRRRRRR\n")
                print(error ?? "--- Error in HandleRegister")
                self.userAlreadyExistAlert()
                //self.okUser = false
                //self.okForm = false
                return    //there already exist a user with those credentials
            }
            print("\n---megvolt create user\n")
            
            guard let uid = user?.uid else {
                print("\n--- Nincs uid\n")
                //self.okUser = false
                return
            }
            
            //successfully autenticated user
            //get the Firebase database refenrence
            //let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
            let refDatabase = Database.database().reference()
            let usersRef = refDatabase.child("users").child(uid)
            let values = ["name": name,
                          "surname": surname,
                          "email": email,
                          "password": password]/*,
                          "driver": "true",
                          "from": "Gilau"]*/
            //usersRef.setValue(values, withCompletionBlock: { (err, refDatabase) in
            usersRef.updateChildValues(values, withCompletionBlock: { (err, refDatabase) in
                if err != nil {
                    print(error ?? "error a registerviewcontrollerben a register handle-nal")
                    return
                }
                
                print("\n--- saved user successfully into firebase database\n")
                //self.okUser = true
                
                //regisztracio utan be is jelentkezunk, ne kuldjuk a login page-re a user-t
                Auth.auth().signIn(withEmail: email, password: password, completion: nil)
            })
        })
    }
    
    func userAlreadyExistAlert() {
        let alert = UIAlertController(title: "Error", message: "There already exist a user with this email.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        emailImage.image = UIImage(named: "Cancel")
        textFieldPassword.text = ""
        passwordImage.image = UIImage(named: "Cancel")
        textFieldPassword2.text = ""
        password2Image.image = UIImage(named: "Cancel")
    }
    
    func formIncompleteAlert() {
        let alert = UIAlertController(title: "Error", message: "The form is not completed right.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Complete it!", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        if textFieldName.text == "" {
            nameImage.image = UIImage(named: "Cancel")
        }
        if textFieldSurname.text == "" {
            surnameImage.image = UIImage(named: "Cancel")
        }
        if textFieldEmail.text == "" {
            emailImage.image = UIImage(named: "Cancel")
        }
        if textFieldPassword.text == "" {
            passwordImage.image = UIImage(named: "Cancel")
        }
        if textFieldPassword2.text == "" {
            password2Image.image = UIImage(named: "Cancel")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registeredSuccessfully" {
            if Auth.auth().currentUser?.uid == nil {
                print("\n Nincs bejelentkezve senki\n")
                return
            }
        }
    }
    
    //mozgatja a view-t hogy latszodjanak a text-ek
    func moveText(textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance: -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    deinit {
        print("\n---RegisterViewController destroyed---\n")
    }

}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case textFieldName:
            textFieldName.resignFirstResponder()
            let answer = checkErrorNames(text: textFieldName.text!)
            nameImage.image = UIImage(named: answer)
            if (answer == "Appointments") {
                textFieldSurname.becomeFirstResponder()
            }
        case textFieldSurname:
            textFieldSurname.resignFirstResponder()
            let answer = checkErrorNames(text: textFieldSurname.text!)
            surnameImage.image = UIImage(named: answer)
            if (answer == "Appointments") {
                textFieldEmail.becomeFirstResponder()
            }
        case textFieldEmail:
            textFieldEmail.resignFirstResponder()
            let answer = checkErrorEmail(text: textFieldEmail.text!)
            emailImage.image = UIImage(named: answer)
            if (answer == "Appointments") {
                textFieldPassword.becomeFirstResponder()
            }
        case textFieldPassword:
            textFieldPassword.resignFirstResponder()
            let answer = checkErrorPassword(text: textFieldPassword.text!)
            passwordImage.image = UIImage(named: answer)
            if (answer == "Appointments") {
                textFieldPassword2.becomeFirstResponder()
            }
        case textFieldPassword2:
            textFieldPassword2.resignFirstResponder()
            password2Image.image = UIImage(named: checkErrorPasswordMatch(text1: textFieldPassword.text!, text2: textFieldPassword2.text!))
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    //when keyboard appears
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        moveText(textField: textField, moveDistance: -100, up: true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case textFieldName:
            nameImage.image = UIImage(named: checkErrorNames(text: textFieldName.text!))
        case textFieldSurname:
            surnameImage.image = UIImage(named: checkErrorNames(text: textFieldSurname.text!))
        case textFieldEmail:
            emailImage.image = UIImage(named: checkErrorEmail(text: textFieldEmail.text!))
        case textFieldPassword:
            passwordImage.image = UIImage(named: checkErrorPassword(text: textFieldPassword.text!))
        case textFieldPassword2:
            password2Image.image = UIImage(named: checkErrorPasswordMatch(text1: textFieldPassword.text!, text2: textFieldPassword2.text!))
        default:
            print("default")
        }
        
        moveText(textField: textField, moveDistance: -100, up: false)
    }
    
    func checkErrorNames(text: String) -> String {
        let nameRegex = "[A-Za-z-]{2,20}"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        if ( nameTest.evaluate(with: text) == true ) {
            return "Appointments"
        }
        else {
            return "Cancel"
        }
    }
    
    func checkErrorEmail(text: String) -> String {
        let emailRegex = "[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if ( emailTest.evaluate(with: text) == true ) {
            return "Appointments"
        }
        else {
            return "Cancel"
        }
    }
    
    func checkErrorPassword(text: String) -> String {
        let passwordRegex = "[A-Za-z0-9*._-]{6,20}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if ( passwordTest.evaluate(with: text) == true ) {
            return "Appointments"
        }
        else {
            return "Cancel"
        }
    }
    
    func checkErrorPasswordMatch(text1: String, text2: String) -> String {
        if (text2 != "" && text1 == text2) {
            return "Appointments"
        }
        else {
            return "Cancel"
        }
    }
    
}
