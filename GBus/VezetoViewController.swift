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

struct busService {
    static let fromCjtoG = "CJtoG"
    static let fromGtoCJ = "GtoCJ"
}

class VezetoViewController: UIViewController {
    let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
    let locationManager = CLLocationManager()   //ez adja a GPS koordinatakat
    var location: CLLocation?
    var driver: Driver!
    var route: String = ""
    let sourceLocation = ["Cluj-Napoca", "Gilau"]

    @IBOutlet weak var sourceLocationPicker: UIPickerView!
    @IBOutlet weak var travelingMessageLabel: UILabel!
    
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var messages: [WaitMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        
        sourceLocationPicker.delegate = self
        sourceLocationPicker.dataSource = self
        
        route = busService.fromCjtoG
        print("1111111111111 \(route)")
        
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
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController( title: "Location Services Disabled",
                                       message: "Please enable location services for this app in Settings.",
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    @IBAction func startButtonPushed(_ sender: UIButton) {
        print("start megnyomva")
        print(route)
        let activeDriverRef = refDatabase.child("activeDrivers").child(route)
        let infos = ["driver": driver.key]
        activeDriverRef.setValue(infos)
        //nem engedjuk hogy kivalasszon mas utat, mert mar elindult
        sourceLocationPicker.isUserInteractionEnabled = false
        travelingMessageLabel.isHidden = false
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func stopButtonPushed(_ sender: UIButton) {
        print("stop megnyomva")
        travelingMessageLabel.isHidden = true
        let activeDriverRef = refDatabase.child("activeDrivers").child(route)
        let infos = ["driver": "none"]
        activeDriverRef.setValue(infos)
        locationManager.stopUpdatingLocation()
        //miutan megnyomta a stop gombot mas utat is valaszthat
        sourceLocationPicker.isUserInteractionEnabled = true
    }
    
    func setActiveDriverNone() {
        print("elert ide")
        print(route)
        
        let activeDriverRef = Database.database().reference().child("activeDrivers").child(route)
        let infos = ["driver": "none"]
        activeDriverRef.setValue(infos)
    }
    
}

extension VezetoViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        location = newLocation
        let coordinatesRef = (route == busService.fromCjtoG) ? refDatabase.child("coordinates").child("locationCJtoG") : refDatabase.child("coordinates").child("locationGtoCJ")
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
            cell.backgroundColor = UIColor.white
            cell.delegate = self
            cell.nameLabel.text = messages[indexPath.row].fullName
            cell.stationLabel.text = messages[indexPath.row].station
            cell.timeLabel.text = dateString
            cell.acceptButton.tag = indexPath.row
            cell.declineButton.tag = indexPath.row
            
            cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(red: 221/255, green: 255/255, blue: 244/255, alpha: 0.8) : UIColor.white
            cell.buttonsView.backgroundColor = cell.backgroundColor
            
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

extension VezetoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sourceLocation.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sourceLocation[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if sourceLocation[row] == "Cluj-Napoca" {
            route = busService.fromCjtoG
        }
        else {
            route = busService.fromGtoCJ
        }
    }
    
}
