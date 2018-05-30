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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var banned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if CheckInternet.isConnected(){
//            print("================conected!")
//        }
//        else {
//            print("========not connected")
//            //var isConnectedToInternet = false
//            //while( !isConnectedToInternet ){
//                if !CheckInternet.isConnected(){
//                    //isConnectedToInternet = false
//                    let alert = UIAlertController( title: "Error",
//                                                   message: "You need to connect to the internet!",
//                                                   preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    present(alert, animated: true, completion: nil)
//                    alert.addAction(okAction)
//                }
//                //else {
//                //    isConnectedToInternet = true
//                //}
//            //}
//        }
        
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
    
    @IBAction func loginClicked(_ sender: UIButton) {
        login()
    }
    
    func login() {
        showActivityIndicator()
        //bejelentkezunk a user-el, email es password segitsegevel
        Auth.auth().signIn(withEmail: textFieldUsername.text!, password: textFieldPassword.text!, completion: { (user, error) in
            if error != nil {
                print(error ?? "error a login()-nal")
                self.inexistentUserAlert()
                self.myActivityIndicator.stopAnimating()
                return
            }
            if let user = user {
                //megnezzuk ha banned vagy nem a user
                Database.database().reference().child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    if snapshot.hasChild("banned") {
                        self.myActivityIndicator.stopAnimating()
                        self.banned = true
                        print("we are sorry, you are banned")
                        do {
                            try Auth.auth().signOut()
                            print("kijelentkezes")
                            self.performSegue(withIdentifier: "ShowPassanger", sender: self)
                        }
                        catch let loginError {
                            print("sikertelen logout: \(loginError)\n")
                        }
                        return
                    }
                    else {
                        print("sikeres login")
                    }
                })
            }
        })
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func inexistentUserAlert() {
        let alert = UIAlertController(title: "Error", message: "Incorrect email or password!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Try again!", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func bannedUserAlert() {
        let alert = UIAlertController(title: "Banned", message: "We are sorry, but you are banned!", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK!", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActivityIndicator() {
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        myActivityIndicator.startAnimating()
        view.addSubview(myActivityIndicator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPassanger" {
            myActivityIndicator.stopAnimating()
            if banned {
                dismiss(animated: true) {
                    self.bannedUserAlert()
                }
                return
            }
        }
        else if segue.identifier == "ShowDriver" {
            myActivityIndicator.stopAnimating()
        }
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

