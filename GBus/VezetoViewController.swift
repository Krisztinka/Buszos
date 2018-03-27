//
//  VezetoViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 19/03/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class VezetoViewController: UIViewController {
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
    let locationManager = CLLocationManager()   //ez adja a GPS koordinatakat
    var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func logOutClicked(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            
            //go back to root view controller
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        catch let loginError {
            print("sikertelen logout: \(loginError)\n")
        }
    }
    
    @IBAction func getLocation(_ sender: UIButton) {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        //megnezzuk ha megengedte hogy hasznaljuk a GPS-t vagy nem
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func sendCoordinates(_ sender: UIButton) {
        let coordinatesRef = refDatabase.child("coordinates").child("location")
        let coordinates = ["longitude": location?.coordinate.longitude,
                           "latitude": location?.coordinate.latitude]
        coordinatesRef.setValue(coordinates)
        
        /*let groceryItemRef = self.ref.child(text.lowercased())
        groceryItemRef.setValue(groceryItem.toAnyObject())
        
        let usersRef = refDatabase.child("users").child(uid)
        let values = ["name": name,
                      "surname": surname,
                      "email": email,
                      "password": password]/*,
         "driver": "true"]*/
        //usersRef.setValue(values, withCompletionBlock: { (err, refDatabase) in
        usersRef.updateChildValues(values, withCompletionBlock: { (err, refDatabase) in
            if err != nil {
                print(error ?? "error a registerviewcontrollerben a register handle-nal")
                return
            }*/
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController( title: "Location Services Disabled",
                                       message: "Please enable location services for this app in Settings.",
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func updateLabels() {
        if let location = location {
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
        }
    }
}

extension VezetoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation.coordinate.latitude)")
        location = newLocation
        updateLabels()
        let coordinatesRef = refDatabase.child("coordinates").child("location")
        let coordinates = ["longitude": location?.coordinate.longitude,
                           "latitude": location?.coordinate.latitude]
        coordinatesRef.setValue(coordinates)
    }
}
