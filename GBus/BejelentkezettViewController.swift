//
//  BejelentkezettViewController.swift
//  GBus
//
//  Created by macmini on 3/6/18.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreData
import CoreLocation

protocol MessageTimeProtocol {
    func timeChanged(time: Double)
}

class BejelentkezettViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    var annotationCJG = MKPointAnnotation()
    var annotationGCJ = MKPointAnnotation()
    
    var stations = [BusStation]()       //a megallok listaja
    var expectedTimeToStation: Double = 0
    
    let locationManager = CLLocationManager()   //ez azert kell hogy a sajat helyzetet is lassa a user
    var userLocation: CLLocation?                   // -||- same
    var destinationPlacemark: MKPlacemark?
    weak var messageLauncherViewController: MessageLauncherViewController?
    
    var isActiveDriverCJG: Bool = false
    var driverCJG: String = "none"
    var isActiveDriverGCJ: Bool = false
    var driverGCJ: String = "none"
    
    var destinationBusStation: BusStation?
    var passenger: Passenger?
    var waitMessageReference: String = "noChild"
    var titleButton: UIButton?
    
    var isSwitchOn = true
    
    //let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        //checkInternetConnection()
        
        //ez meghivodik minden egyes adatbazis rekord update-kor
        //figyeljuk a ket jaratot
        Database.database().reference().child("coordinates").observe(.childChanged, with: { snapshot in
            //csak akkor lesz eloszor kirajzolva a busz, mikor nekifogott mozogni
            print("valami valtozott, es a snapshot.key: \(snapshot.key)")
            print("snapshot: \(snapshot.value ?? "semmi")\n")
            let busId: String = snapshot.key
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                if busId == "locationCJtoG" {
                    //ekor a Kolzsvarrol indulo jaratrol van szo
                    self.mapView.addAnnotation(self.annotationCJG)
                    UIView.animate(withDuration: 2, animations: {
                        self.annotationCJG.coordinate = CLLocationCoordinate2D(latitude: dictionary["latitude"] as! Double, longitude: dictionary["longitude"] as! Double)
                    })
                }
                else if busId == "locationGtoCJ" {
                    //ekkor a Gyalubol indulo jaratrol van szo
                    self.mapView.addAnnotation(self.annotationGCJ)
                    UIView.animate(withDuration: 2, animations: {
                        self.annotationGCJ.coordinate = CLLocationCoordinate2D(latitude: dictionary["latitude"] as! Double, longitude: dictionary["longitude"] as! Double)
                    })
                }
            }
        })
       
        //letrehozzuk az elso poziciojukat a ket busznak
    Database.database().reference().child("coordinates").child("locationCJtoG").observeSingleEvent(of: .value, with: { snapshot in
            print("bejott masodikba1\n")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                self.annotationCJG.coordinate = CLLocationCoordinate2D(latitude: (dictionary["latitude"] as! Double), longitude: (dictionary["longitude"] as! Double))
            }
        })
        
    Database.database().reference().child("coordinates").child("locationGtoCJ").observeSingleEvent(of: .value, with: { snapshot in
            print("bejott masodikba2\n")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                self.annotationGCJ.coordinate = CLLocationCoordinate2D(latitude: (dictionary["latitude"] as! Double), longitude: (dictionary["longitude"] as! Double))
            }
        })
        
        //nezzuk ha van active sofor vagy nincs, es ha active, akkor az amelyek kell nekunk, vagy nem
        Database.database().reference().child("activeDrivers").child("CJtoG").observe(.childChanged) { (snapshot) in
            if let driverId = snapshot.value as? String {
                self.driverCJG = driverId
                if self.driverCJG == "none" {
                    self.isActiveDriverCJG = false
                    //amikor nincs sofor, a buszt se rajzoljuk ki a terkepre
                    self.mapView.removeAnnotation(self.annotationCJG)
                }
                else {
                    self.isActiveDriverCJG = true
                    //amikor activva valt a sofor, akkor odairanyitom a terkepet, hogy latszodjon hogy elindult a busz
                    print(self.annotationCJG)
                    print(self.annotationCJG.coordinate)
                    let region = MKCoordinateRegionMakeWithDistance(self.annotationCJG.coordinate, 1000, 1000)
                    self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
                }
                self.checkSendMessageButtonState()
            }
        }
        
        Database.database().reference().child("activeDrivers").child("GtoCJ").observe(.childChanged) { (snapshot) in
            if let driverId = snapshot.value as? String {
                self.driverGCJ = driverId
                if self.driverGCJ == "none" {
                    self.isActiveDriverGCJ = false
                    //amikor nincs sofor, a buszt se rajzoljuk ki a terkepre
                    self.mapView.removeAnnotation(self.annotationGCJ)
                }
                else {
                    self.isActiveDriverGCJ = true
                    //amikor activva valt a sofor, akkor odairanyitom a terkepet, hogy latszodjon hogy elindult a busz
                    let region = MKCoordinateRegionMakeWithDistance(self.annotationGCJ.coordinate, 1000, 1000)
                    self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
                }
                self.checkSendMessageButtonState()
            }
        }
        
        //hozzaadunk egy button-t a nav bar title-jahoz
        titleButton = UIButton(type: .custom)
        titleButton!.titleLabel?.adjustsFontSizeToFitWidth = true
        titleButton!.setTitleColor(UIColor.black, for: .normal)
        titleButton!.setTitle("Passenger", for: .normal)
        titleButton!.addTarget(self, action: #selector(clickOnTitleButton), for: .touchUpInside)
        self.navigationItem.titleView = titleButton
        
        checkOldMessages()
        
        //kirajzolom a megallokat
        stations.append(BusStation(title: "Napoca", subtitle: "CJ-Gilau", coordinate: CLLocationCoordinate2D(latitude: 37.330284, longitude: -122.032114)))
        stations.append(BusStation(title: "NapocaHotel", subtitle: "CJ-Gilau", coordinate: CLLocationCoordinate2D(latitude: 46.771751, longitude: 23.575963)))
        stations.append(BusStation(title: "NapocaHotelEst", subtitle: "Gilau-CJ", coordinate: CLLocationCoordinate2D(latitude: 46.771712, longitude: 23.575944)))
        // stationNapocaN = BusStation(title: "Napoca", subtitle: "CJ-Gilau", coordinate: CLLocationCoordinate2D(latitude: 37.344893, longitude: -122.095438))
        //stations.append(stationNapocaN)
        stations.append(BusStation(title: "Gilau Centru", subtitle: "CJ-Gilau", coordinate: CLLocationCoordinate2D(latitude: 46.755979, longitude: 23.386438)))
        stations.append(BusStation(title: "Gilau Scoala Veche", subtitle: "Gilau-CJ", coordinate: CLLocationCoordinate2D(latitude: 46.755357, longitude: 23.387869)))
        stations.append(BusStation(title: "Floresti Centru", subtitle: "CJ-Gilau", coordinate: CLLocationCoordinate2D(latitude: 46.744, longitude: 23.485079)))
        stations.append(BusStation(title: "Floresti Farmacie", subtitle: "Gilau-CJ", coordinate: CLLocationCoordinate2D(latitude: 46.744659, longitude: 23.48634)))
        stations.append(BusStation(title: "Floresti Farmacie", subtitle: "Gilau-CJ", coordinate: CLLocationCoordinate2D(latitude: 37.331284, longitude: -122.042214)))
            mapView.addAnnotations(stations)
        mapView.delegate = self
        
        checkLocationService()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        print("meghivodooooooooooooooooooooooooot")
        print(userLocation)
        print("ez elott a user location99999999999999999999999999")
    }
    
    @IBAction func showAnnouncementsView(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showAnnouncements", sender: self)
    }
    
    func checkLocationService() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            userLocation = nil
            locationManager.requestWhenInUseAuthorization()
        }
        
        //megnezzuk ha megengedte hogy hasznaljuk a GPS-t vagy nem
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            userLocation = nil
            return
        }
    }
    
    func checkInternetConnection() {
        //check for internet connection
        var isConnectedToInternet = false
        while( !isConnectedToInternet ){
            if !CheckInternet.isConnected(){
                isConnectedToInternet = false
                let alert = UIAlertController( title: "Error",
                                               message: "You need to connect to the internet!",
                                               preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                self.present(alert, animated: true, completion: nil)
                alert.addAction(okAction)
            }
            else {
                isConnectedToInternet = true
            }
        }
    }
    
    @objc func clickOnTitleButton(button: UIButton) {
        locationManager.stopUpdatingLocation()
        performSegue(withIdentifier: "presentEditScreen", sender: button)
    }
    
    func checkOldMessages() {
        //ezzel figyeljuk, ha a sofor elfogadta vagy nem a keresunket
        let refDatabase = Database.database().reference()
        refDatabase.child("oldMessages").observe(.childAdded, with: { snapshot in
            print("snapshot: \(snapshot.value ?? "semmi")\n")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                
                if (dictionary["toId"] as! String) == self.passenger?.key {
                    //ekkor neki szolt az uj bejegyzes, es alert-el kiirjuk
                    let message = { (dictionary["answer"] as! String) == "true" ? "The driver ACCEPTED your request!" : "The driver DECLINED your request!"}()
                    /*var message = ""
                    if (dictionary["answer"] as! String) == "true" {
                        message = "The driver ACCEPTED your request!"
                    }
                    else {
                        message = "The driver DECLINED your request!"
                    }*/
                    
                    let alert = UIAlertController( title: "Answer",
                                                   message: message,
                                                   preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default,
                                                 handler: {(alert: UIAlertAction!) in
                                                    //miutan megmutattuk a message-t, kitoroljuk az adatbazisbol
                                                    let oldMessageRef = refDatabase.child("oldMessages")
                                                    oldMessageRef.child(snapshot.key).setValue(nil)
                    })
                    self.present(alert, animated: true, completion: nil)
                    alert.addAction(okAction)
                }
            }
        })
    }
    
    func fetchUserData() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                self.passenger = Passenger(snapshot: snapshot)
                if let surname = self.passenger?.surname {
                    self.titleButton?.setTitle(surname, for: .normal)
                    print(surname)
                }
                else {
                    self.titleButton?.setTitle("Passenger", for: .normal)
                }
//                if let passenger = self.passenger {
//                    passenger.writeData()
//                }
            }) { (error) in
                print(error)
            }
        }
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController( title: "Location Services Disabled",
                                       message: "Please enable location services for this app in Settings.",
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            //ha nincs megengedve a location, atiranyitjuk hogy engedje meg
            if !CLLocationManager.locationServicesEnabled() {
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.openURL(url)
                }
            } else {
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    // If general location settings are enabled then open location settings for the app
                    UIApplication.shared.openURL(url)
                }
            }
        }
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func checkSendMessageButtonState() {
        if destinationBusStation?.subtitle == "CJ-Gilau" {
            self.messageLauncherViewController?.driverStateChanged(driver: driverCJG)
        }
        else if destinationBusStation?.subtitle == "Gilau-CJ" {
            self.messageLauncherViewController?.driverStateChanged(driver: driverGCJ)
        }
        
    }
    
    // MARK:- Actions
    @IBAction func showUserPin() {
        //lehet lezarta a location-t ido kozbe, ezert meg kell nezzuk ha emg van engedve
        checkLocationService()
        //var latitude = 46.768321
        //var longitude = 23.596480
        var region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 37.3542926, longitude: -122.087257), 10000, 10000)
        if let userLocation = userLocation {
            //ha van user location azt mutatja meg
            print("Van user Location.888888888888888888888888888888888888888")
            region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000)
        }
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }

    @IBAction func logOutClicked(_ sender: UIBarButtonItem) {
        logout()
    }
    
    func logout() {
        print("meghivodott logout")
        do {
            try Auth.auth().signOut()
            
            //go back to root view controller
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        catch let loginError {
            print("sikertelen logout: \(loginError)\n")
        }
        //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

//useful for creating your own annotation views
extension BejelentkezettViewController: MKMapViewDelegate {
    
    //mapView(_:viewFor:) gets called for every annotation you add to the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("--- viewFor annotation")
        //letrehozzuk az MKAnnotationView-t amit vissza kell adjunk
        var annotationView: MKAnnotationView?
        
        //ha az annotatio amire szukseg van, az BusMegallo, akkor a megfelelo kepet rajzoljuk ki
        if annotation is BusStation {
            /*if userLocation == nil {
                print("niiiiiiiiiiiiiiiiiiiiiiiiiiiiiil")
                //meg nem jo
                annotationView?.canShowCallout = false
            }*/
            //csak akkor akarom customizalni, ha ez BusStation
            //annotationView a kis bubble amibe megjelenik az iras
            let identifier = "Station"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView.image = UIImage(named: "busStation")
                print("itt van\n")
                pinView.isEnabled = true
                pinView.canShowCallout = true
                //pinView.animatesDrop = false
                //pinView.pinTintColor = UIColor(red: 0.3, green: 0.4, blue: 0.1, alpha: 1)
                let rightButton = UIButton(type: .detailDisclosure)
                pinView.rightCalloutAccessoryView = rightButton
                annotationView = pinView
            }
            else if let annotationView = annotationView {
                //ha mar letre van hozva eleg, nem hozunk letre ujat, hanem felhsznaljuk a meglevoket
                annotationView.annotation = annotation
            }
        }
        else if annotation is MKPointAnnotation {
            print("bejotttttttttt")
            //ha az illeto annotatio csak egy MKPointAnnotation, ami a buszt abrazolja, akkor a megfelelo kepet rajzoljuk ki
            let identifier = "BusCoordinate"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "nemtudom")
                pinView.image = UIImage(named: "busCoord")
                pinView.isEnabled = true
                annotationView = pinView
            }
            else if let annotationView = annotationView {
                annotationView.annotation = annotation
            }
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("--- annotationView view")
        performSegue(withIdentifier: "showMessageLauncher", sender: self)
        //present(MessageLauncherViewController(), animated: true, completion: nil)
        
    }
    
    //amikor raklickkelek egy pin-re jelenjen meg a traseu
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("--- didSelect view")
        /*guard let userLocation = userLocation else {
            self.mapView.removeOverlays(self.mapView.overlays)
            showLocationAlert()
            return
        }*/
        //megmutatjuk a megallorol az adatokat, de nem kell kirajzolni utvonalat
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .denied || authStatus == .restricted {
            userLocation = nil
        }
        if let userLocation = userLocation {
            //ha van user location, kirajzol utat, ha nincs leszed a tobbi ut, es megmutatja csak a stationNevet
            print("raklikkeltem")
            if (view.annotation as? BusStation) != nil {
                //ez azert van ha sajat helyzetere klikkel a user, ne mutasson egy kicsi kek pontot
                self.mapView.removeOverlays(self.mapView.overlays)
                destinationBusStation = BusStation(busAnnotation: view.annotation!) //ezzel tudom atadni a messageLauncher-nek hogy melyek megallo fele megy
                
                let sourceLocation = userLocation.coordinate
                let destinationLocation = view.annotation?.coordinate
                
                let sourcePin = MKPointAnnotation()
                sourcePin.coordinate = sourceLocation
                
                let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
                destinationPlacemark = MKPlacemark(coordinate: destinationLocation!, addressDictionary: nil)
                
                let directionRequest = MKDirectionsRequest()
                directionRequest.source = MKMapItem(placemark: sourcePlacemark)
                directionRequest.destination = MKMapItem(placemark: destinationPlacemark!)
                directionRequest.transportType = .walking
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate { (response, error) in
                    guard let directionResponse = response else {
                        if let error = error {
                            print("error van \(error)")
                        }
                        return
                    }
                    
                    let route = directionResponse.routes[0]
                    let expectedTime = route.expectedTravelTime / 60.0
                    self.expectedTimeToStation = expectedTime
                    print("varhato ido: \(expectedTime) perc")
                    
                    self.mapView.add(route.polyline, level: .aboveRoads)
                    let rect = route.polyline.boundingMapRect
                    mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0), animated: true)
                }
            }
            else {
                self.mapView.removeOverlays(self.mapView.overlays)
            }
        }
        else {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        
    }
    
    func showLocationAlert() {
        let alert = UIAlertController( title: "Error",
                                       message: "You have to enable the Location Service in Settings and inside the App, to get the route to a station.",
                                       preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.performSegue(withIdentifier: "presentEditScreen", sender: self.titleButton)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("meghivodott renderer \n")
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        //renderer.lineWidth = 1
        return renderer
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("meghivodik prepare")
        if (segue.identifier == "showMessageLauncher") {
            guard let userLocation = userLocation else { return }
            print("a showmessagelauncher elott \(userLocation)")
            if userLocation != nil {
                print("prepareba: \(expectedTimeToStation) es \(destinationBusStation)")
                messageLauncherViewController = (segue.destination as! MessageLauncherViewController)
                messageLauncherViewController?.delegate = self
                messageLauncherViewController?.expectedTime = expectedTimeToStation
                if let destinationBusStation = destinationBusStation {
                    messageLauncherViewController?.busStation = destinationBusStation
                }
            }
            else {
                print("hulye vagyok;;;;;;;;")
                
            }
        }
        else if segue.identifier == "presentEditScreen" {
            print("a presentEdit hivodik meg")
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! EditProfileTableViewController
            controller.isSwitchOn = self.isSwitchOn
            controller.delegate = self
            controller.passenger = passenger
        }
        else if segue.identifier == "showAnnouncements" {
            print("rendesSegue")
            let announcementTableViewController = segue.destination as! AnnouncementTableViewController
            announcementTableViewController.isPassenger = true
        }
    }
}

extension BejelentkezettViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
        print("bejott a didupdatelocation-ba!!!!!!!!!!!!!!!!!!!!!!!!!")
        
        //ekkor ki kene szamitani ujbol az utat es el kene kuldeni a launcheron a label-nak, mert itt mozog a user, es o is kell lassa a valtozast
        if let destinationPlacemark = destinationPlacemark {
            let sourceLocation = userLocation!.coordinate
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let directionRequest = MKDirectionsRequest()
            directionRequest.source = MKMapItem(placemark: sourcePlacemark)
            directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
            directionRequest.transportType = .walking
            
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) in
                guard let directionResponse = response else {
                    if let error = error {
                        print("Error in didUpdateLocatio: \(error)")
                    }
                    return
                }
                
                let route = directionResponse.routes[0]
                let expectedTime = route.expectedTravelTime / 60.0  //atszamoljuk percre az idot
                //print("----------expectedTimeRegi: \(Int(self.expectedTimeToStation.rounded()))")
                //print("----------expectedTimeUj \(Int(expectedTime.rounded()))")
                
                //ha percben kulonbozik a ket ido, update-oljuk a messageLauncher-ba
                //if(Int(self.expectedTimeToStation.rounded()) != Int(expectedTime.rounded())) {
                    self.expectedTimeToStation = expectedTime
                    print("az elsobe az activeDriver: \(self.driverCJG)")
                    //annak fuggvenyebe hogy milyen megallot vaalsztott, megnezzuk, hogy van-e aktiv sofor vagy nincs azon az uton
                    if self.destinationBusStation?.subtitle == "CJ-Gilau" {
                        print("kuldeskor: \(expectedTime) es sofor: \(self.driverCJG)")
                        self.messageLauncherViewController?.timeChanged(time: expectedTime, activeDriver: self.driverCJG)
                    }
                    else if self.destinationBusStation?.subtitle == "Gilau-CJ" {
                        self.messageLauncherViewController?.timeChanged(time: expectedTime, activeDriver: self.driverGCJ)
                    }
                //}
            }
        }
    }
}

extension BejelentkezettViewController: MessageLauncherDelegate {
    func sendMessageToDriver(driver: String) {
        print("<<<<<<<<ezt az active driver-t kaptam \(driver)")
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = Int(NSDate.timeIntervalSinceReferenceDate)
        print(timestamp)
        let databaseRef = Database.database().reference().child("messages")
        let values = ["fromId": fromId!,
                      "toId": driver,
                      "fullName": passenger?.fullName,
                      "timestamp": timestamp,
                      "station": destinationBusStation!.title] as [String : Any]
        
        //eddig mindig megcsinaljuk, mert ha ujitani kell ha uj adatot kell bevinni, akkor is szukseges
        //most emgnezzuk ha van olyan gyerek a "messages" faba, aminek ugyan az a key erteke, mert ha igen, csak update-oljuk az adatokat benne
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.waitMessageReference) {
                //ekkor meg nem volt elfogadva es update-olunk
                databaseRef.child(self.waitMessageReference).updateChildValues(values)
            }
            else {
                let childRef = databaseRef.childByAutoId()
                childRef.updateChildValues(values)
                self.waitMessageReference = childRef.key
            }
        }, withCancel: nil)
    }
}

extension BejelentkezettViewController: EditProfileTableViewControllerDelegate {
    func updateProfile(passenger: Passenger) {
        print("meghivta delegatet")
        self.passenger = passenger
        titleButton?.setTitle(passenger.surname, for: .normal)
        passenger.writeData()
        Database.database().reference().child("users").child(passenger.key).updateChildValues(["name": passenger.name, "surname": passenger.surname])
    }
    
    func resetPassword() {
        print("meghivodott a reset.")
        Auth.auth().sendPasswordReset(withEmail: (passenger?.email)!){ (error) in
            if (error != nil) {
                print("Error a resetpasswordnal.!!!!!!!!!!!!!!!!!!!!!!!!")
            }
            else {
                self.logout()
            }
        }
    }
    
    func stopLocation(value: Bool) {
        if value == false {
            print("Location megallt.")
            mapView.removeOverlays(self.mapView.overlays)
            isSwitchOn = false
            self.mapView.showsUserLocation = false
            self.userLocation = nil
            locationManager.stopUpdatingLocation()
        }
        else {
            print("Location elindult.")
            isSwitchOn = true
            self.mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }
    }
}
