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
    var driver: Driver!
    var route: String = ""

    @IBOutlet weak var buttonCJG: UIButton!
    @IBOutlet weak var buttonGCJ: UIButton!
    
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-------------- Bus location-hoz kell -----------------
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
        //-------------------------------------------------------------------
        
        //megkapjuk a jelenlevo soforrol az informaciokat
        let driverRef = refDatabase.child("users/" + "\(Auth.auth().currentUser?.uid ?? "")")
        driverRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("snapshot: \(snapshot)")
            self.driver = Driver(snapshot: snapshot)
            self.navigationItem.title = self.driver.surname
        }, withCancel: nil)
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
        
        
    }
    
    @IBAction func sendCoordinates(_ sender: UIButton) {
        let coordinatesRef = refDatabase.child("coordinates").child("location")
        let coordinates = ["longitude": location?.coordinate.longitude,
                           "latitude": location?.coordinate.latitude]
        coordinatesRef.setValue(coordinates)
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
    
    @IBAction func cjgPushed(_ sender: UIButton) {
        route = "CJtoG"
    }
    
    @IBAction func gcjPushed(_ sender: UIButton) {
        route = "GtoCJ"
    }
    
    @IBAction func startButtonPushed(_ sender: UIButton) {
        print("start megnyomva")
        let activeDriverRef = refDatabase.child("activeDrivers").child(route)
        let infos = ["driver": driver.key]
        activeDriverRef.setValue(infos)
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func stopButtonPushed(_ sender: UIButton) {
        print("stop megnyomva")
        let activeDriverRef = refDatabase.child("activeDrivers").child(route)
        let infos = ["driver": "none"]
        activeDriverRef.setValue(infos)
        locationManager.stopUpdatingLocation()
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
