//
//  ViewController.swift
//  GBus
//
//  Created by macmini on 3/5/18.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonLogIn: UIButton!
    @IBOutlet weak var buttonRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldUsername.delegate = self
        textFieldPassword.delegate = self
        
        //tunjon el a keyboard amikor mashova clickkelunk
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
        
        //amikor bejelentkezunk, ez az observer eszreveszi hogy valami valtozott es vegrehajtja a closure-t
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let uid = Auth.auth().currentUser?.uid
                //uid segitsegevel emgkapjuk a snapshotot, hogy megnezhessuk hogy driver vagy nem
                Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        if (dictionary["driver"] as? String) != nil {
                            self.performSegue(withIdentifier: "ShowDriver", sender: self)
                        } else {
                            self.performSegue(withIdentifier: "ShowPassanger", sender: self)
                        }
                    }
                })
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        login()
        //dismiss(animated: true, completion: nil)
    }
    
    func login() {
        //bejelentkezunk a user-el, email es password segitsegevel
        Auth.auth().signIn(withEmail: textFieldUsername.text!, password: textFieldPassword.text!, completion: { (user, error) in
            if error != nil {
                print(error ?? "error a login()-nal")
                self.inexistentUserAlert()
                return
            }
            print("sikeres login")
        })
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func inexistentUserAlert() {
        let alert = UIAlertController(title: "Error", message: "Incorrect email os password!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Try again!", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }


}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldUsername {
            textFieldUsername.resignFirstResponder()
            textFieldPassword.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        
        return true
    }
}

