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
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var annotation = MKPointAnnotation()
    
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
    
    //let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        
        //ez meghivodik minden egyes adatbazis rekord update-kor
        Database.database().reference().child("coordinates").observe(.childChanged, with: { snapshot in
            print("nem jo be\n")
            print("snapshot: \(snapshot.value)\n")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                
                //kirajzolom a regit, adom az uj coordinate-ot es animalom
                self.mapView.addAnnotation(self.annotation)
                //let region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 1000, 1000)
                //self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
                self.latitude = dictionary["latitude"] as! Double
                self.longitude = dictionary["longitude"] as! Double
                UIView.animate(withDuration: 2, animations: {
                    self.annotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                })
            }
        })
        
        //ez meghivodik az elejen
        Database.database().reference().child("coordinates").child("location").observeSingleEvent(of: .value, with: { snapshot in
            print("bejott masodikba\n")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                var longitudee = dictionary["longitude"] as! Double
                var latitudee = dictionary["latitude"] as! Double
                //print(longitudee)
                //print(latitudee)
                //self.location = CLLocation(latitude: latitudee, longitude: longitudee)
                
                var coordinateData = CLLocationCoordinate2D(latitude: latitudee, longitude: longitudee)
                //var coordinateData = CLLocationCoordinate2D(latitude: 44.439663, longitude: 26.096306)
                //let annotation = MKPointAnnotation()
                self.annotation.coordinate = coordinateData
                //self.mapView.addAnnotation(self.annotation)
                //let region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 1000, 1000)
                //self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
                
                let region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 1000, 1000)
                self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
            }
        })
        
        //nezzuk ha van active sofor vagy nincs, es ha active, akkor az amelyek kell nekunk, vagy nem
        Database.database().reference().child("activeDrivers").child("CJtoG").observe(.childChanged) { (snapshot) in
            if let driverId = snapshot.value as? String {
                self.driverCJG = driverId
                if self.driverCJG == "none" {
                    self.isActiveDriverCJG = false
                }
                else {
                    self.isActiveDriverCJG = true
                }
                self.checkSendMessageButtonState()
            }
        }
        
        Database.database().reference().child("activeDrivers").child("GtoCJ").observe(.childChanged) { (snapshot) in
            if let driverId = snapshot.value as? String {
                self.driverGCJ = driverId
                if self.driverGCJ == "none" {
                    self.isActiveDriverGCJ = false
                }
                else {
                    self.isActiveDriverGCJ = true
                }
                self.checkSendMessageButtonState()
            }
        }
        
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
            mapView.addAnnotations(stations)
        mapView.delegate = self
        
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
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    func fetchUserData() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                self.passenger = Passenger(snapshot: snapshot)
                /*if let passenger = self.passenger {
                    passenger.writeData()
                }*/
            }) { (error) in
                print(error)
            }
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
        //var latitude = 46.768321
        //var longitude = 23.596480
        var region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 37.3542926, longitude: -122.087257), 10000, 10000)
        if let userLocation = userLocation {
            //ha van user location azt mutatja meg
            region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000)
        }
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
//        var i = 10
//        while i > 0 {
//            self.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//            self.mapView.addAnnotation(self.annotation)
//            //let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10000, 10000)
//            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 37.3542926, longitude: -122.087257), 10000, 1000)
//            //let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10000, 10000)
//            mapView.setRegion(mapView.regionThatFits(region), animated: true)
//            UIView.animate(withDuration: 2, animations: {
//                
//                //self.newPosition = CLLocationCoordinate2D(latitude: 46.749505, longitude: 23.412459)
//                latitude = latitude + 0.001
//                longitude = longitude + 0.001
//                self.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//                i = i-1
//                print(i)
//            })
//            
//        }
        

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
        //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}

//useful for creating your own annotation views
extension BejelentkezettViewController: MKMapViewDelegate {
    
    //mapView(_:viewFor:) gets called for every annotation you add to the map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is BusStation else {
            //csak akkor customizaljuk az annotaciot ha ez egy megallo
            return nil
        }
        
        //csak akkor akarom customizalni, ha ez BusStation
        //annotationView a kis bubble amibe megjelenik az iras
        let identifier = "Station"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.3, green: 0.4, blue: 0.1, alpha: 1)
            let rightButton = UIButton(type: .detailDisclosure)
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            //let button = annotationView.rightCalloutAccessoryView as! UIButton
            /*if let index = locations.index(of: annotation as! BusStation) {
                button.tag = index
            }*/
            //button.tag = 1
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("rugja meg a cica")
        performSegue(withIdentifier: "showMessageLauncher", sender: self)
        
    }
    
    //amikor raklickkelek egy pin-re jelenjen meg a traseu
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("raklikkeltem")
        destinationBusStation = BusStation(busAnnotation: view.annotation!) //ezzel tudom atadni a messageLauncher-nek hogy melyek megallo fele megy
        
        //let sourceLocation = CLLocationCoordinate2DMake(37.3542926, -122.087257)
        let sourceLocation = userLocation!.coordinate
        let destinationLocation = view.annotation?.coordinate
        //CLLocationCoordinate2DMake(46.749505, 23.412459)
        
        let sourcePin = MKPointAnnotation()
        sourcePin.coordinate = sourceLocation
        self.mapView.addAnnotation(sourcePin)
        
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
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
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
            print("prepareba: \(expectedTimeToStation) es \(destinationBusStation)")
            messageLauncherViewController = (segue.destination as! MessageLauncherViewController)
            messageLauncherViewController?.delegate = self
            messageLauncherViewController?.expectedTime = expectedTimeToStation
            if let destinationBusStation = destinationBusStation {
                messageLauncherViewController?.busStation = destinationBusStation
            }
        }
    }
}

extension BejelentkezettViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
        //print("didUpdateLocations \(userLocation!.coordinate.latitude) \(userLocation!.coordinate.longitude)")
        
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
                databaseRef.child(self.waitMessageReference).setValue(values)
            }
            else {
                let childRef = databaseRef.childByAutoId()
                childRef.updateChildValues(values)
                self.waitMessageReference = childRef.key
            }
        }, withCancel: nil)
        
        
        //let childRef = databaseRef.childByAutoId()
        //waitMessageReference = childRef.key
        //print("ez a childref: \(childRef.key)")
        
        //childRef.updateChildValues(values)
    }
    
    
}
