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

struct TableViewCellIdentifiers {
    static let waitMessageCell = "WaitMessageCell"
    static let noMessageCell = "NoMessageCell"
}

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
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [WaitMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        
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
        
        let databaseRef = Database.database().reference().child("messages")
        databaseRef.observe(.childAdded, with: { (snapshot) in
            print("eszrevette ami nem update.")
            print(snapshot)
            if (snapshot.value as! NSDictionary)["toId"] as! String == self.driver.key {
                self.messages.append(WaitMessage(snapshot: snapshot))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
//            for m in self.messages {
//                m.writeMessage()
//            }
        }, withCancel: nil)
        
        //amikor update-olja valaki a kereset, ami amr az adatbazisba van, a message listaba is kell update-oljuk, hogy cserelodjenek a feluleten is az adatok
        databaseRef.observe(.childChanged, with: { (snapshot) in
            print("eszrevette hogy update lett.")
            print(snapshot)
            if (snapshot.value as! NSDictionary)["toId"] as! String == self.driver.key {
                var found = false
                var iterator = 0
                while !found && (iterator < self.messages.count) {
                    print("")
                    if self.messages[iterator].key == snapshot.key {
                        self.messages[iterator] = WaitMessage(snapshot: snapshot)
                        found = true
                    }
                    iterator += 1
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
        
        var cellNib = UINib(nibName: "WaitMessageTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.waitMessageCell)
        cellNib = UINib(nibName: "NoMessageTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.noMessageCell)
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
        //print("didUpdateLocations \(newLocation.coordinate.latitude)")
        location = newLocation
        updateLabels()
        let coordinatesRef = refDatabase.child("coordinates").child("location")
        let coordinates = ["longitude": location?.coordinate.longitude,
                           "latitude": location?.coordinate.latitude]
        coordinatesRef.setValue(coordinates)
    }
}

extension VezetoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            return 1
        }
        else {
            return messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messages.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.noMessageCell, for: indexPath)
        }
        else {
            let date = NSDate(timeIntervalSinceReferenceDate: TimeInterval(messages[indexPath.row].timestamp))
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let dateString = formatter.string(from: date as Date)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.waitMessageCell, for: indexPath) as! WaitMessageTableViewCell
            cell.delegate = self
            cell.nameLabel.text = messages[indexPath.row].fullName
            cell.stationLabel.text = messages[indexPath.row].station
            cell.timeLabel.text = dateString
            cell.acceptButton.tag = indexPath.row
            cell.declineButton.tag = indexPath.row
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ez: \(indexPath.row)")
    }
}

extension VezetoViewController: WaitMessageTableViewCellDelegate {
    func acceptDeclineUserWaitMessage(row: Int, accept: Bool) {
        print("elfogadva: \(accept) a \(row) sor, amelyben \(messages[row].fullName) van")
        
        //ki kell toroljuk a "messages" objektumbol a message-t amire valaszolunk
        let messageRef = refDatabase.child("messages")
        messageRef.child(messages[row].key).setValue(nil)
        
        //beirjuk az "oldMessages" objektumba, hogy elfogadta azt a kerest, vagy nem
        let timestamp = Int(NSDate.timeIntervalSinceReferenceDate)
        let oldMessageRef = refDatabase.child("oldMessages")
        let childRef = oldMessageRef.childByAutoId()
        let values = ["fromDriver": self.driver.surname,
                      "toId": messages[row].fromId,
                      "timestamp": timestamp,
                      "answer": String(accept)] as [String : Any]
        childRef.setValue(values)
        
        //kitoroljuk a messages lista-bol
        messages.remove(at: row)
        tableView.reloadData()
        for pers in messages {
            pers.writeMessage()
        }
    }
    
}
