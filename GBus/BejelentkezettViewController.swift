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
    //a megallok listaja
    var stations = [BusStation]()
    var expectedTimeToStation: Double = 0
    //var oldExpectedTimeToStation: Double = 0
    let locationManager = CLLocationManager()   //ez azert kell hogy a sajat helyzetet is lassa a user
    var userLocation: CLLocation?                   // -||- same
    var destinationPlacemark: MKPlacemark?
    var messageLauncherViewController: MessageLauncherViewController?
    var durationTextLabel: UILabel?
    
    //let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //messageLauncherViewController = MessageLauncherViewController()
        
        durationTextLabel = UILabel(frame: CGRect(x: 200, y: 100, width: 100, height: 50))
        durationTextLabel!.text = String("23 Minutes")
        durationTextLabel!.backgroundColor = UIColor.white
        mapView.addSubview(durationTextLabel!)
        
        Database.database().reference().child("coordinates").observe(.childChanged, with: { snapshot in
            print("nem jo be\n")
            print("snapshot: \(snapshot.value)\n")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                
                //kirajzolom a regit, adom az uj coordinate-ot es animalom
                self.mapView.addAnnotation(self.annotation)
                let region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 1000, 1000)
                self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
                self.latitude = dictionary["latitude"] as! Double
                self.longitude = dictionary["longitude"] as! Double
                UIView.animate(withDuration: 2, animations: {
                    self.annotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                })
            }
        })
        
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
            }
        })
        
        //kirajzolom a megallokat
        stations.append(BusStation(title: "Napoca", subtitle: "CJ-Gilau", coordinate: CLLocationCoordinate2D(latitude: 37.344893, longitude: -122.095438)))
        stations.append(BusStation(title: "NapocaEst", subtitle: "Gilau-CJ", coordinate: CLLocationCoordinate2D(latitude: 37.353238, longitude: -122.087930)))
        //let stationNapocaN = BusStation(title: "Napoca", subtitle: "CJ-Gilau", coordinate: CLLocationCoordinate2D(latitude: 37.344893, longitude: -122.095438))
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
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
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
    
    // MARK:- Actions
    @IBAction func showUser() {
        //let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 2000, 2000)
        //mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        //var myLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        var latitude = 46.768321
        var longitude = 23.596480
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 37.3542926, longitude: -122.087257), 10000, 1000)
            //let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10000, 10000)
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
        
        //Measuring my distance to my buddy's (in km)
        //var distance = myLocation.distance(from: location!) / 1000
        
        //Display the result in km
        //print(String(format: "The distance to my buddy is %.01fkm", distance))
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
        print("delegate")
        guard annotation is BusStation else {
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
            //self.oldExpectedTimeToStation = expectedTime
            print("varhato ido: \(expectedTime) perc")
            //self.mapView.removeAnnotation(view.annotation!)
            //self.stations[1].subtitle = "Minutes: \(Int(eta.rounded()))"
            //self.mapView.addAnnotation(self.stations[1])
            
            self.mapView.add(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            //let subtitle = String(format: "Minutes: %d", round(eta))
            //self.stations[1].subtitle = "Minutes: \(Int(eta.rounded()))"
            //view.annotation!.subtitle = "na: \(Int(eta.rounded()))"
            //self.mapView.removeAnnotation(view.annotation!)
            //view.annotation! = self.stations[1]
            //self.mapView.addAnnotation(self.stations[1])
        }
        //mapView.addAnnotation(self.stations[1])
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
            messageLauncherViewController = segue.destination as! MessageLauncherViewController
            messageLauncherViewController?.expectedTime = expectedTimeToStation
        }
    }
}

extension BejelentkezettViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last!
        print("didUpdateLocations \(userLocation!.coordinate.latitude)")
        
        //ekkor ki kene szamitani ujbol az utat es el kene kuldeni a launcheron a label-nak
        //oldExpectedTimeToStation = expectedTimeToStation
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
                        print("error van \(error)")
                    }
                    return
                }
                
                let route = directionResponse.routes[0]
                let expectedTime = route.expectedTravelTime / 60.0
                //self.expectedTimeToStation = expectedTime
                //print("varhato ido usernek: \(expectedTime) perc")
                print("----------expectedTimeRegi: \(Int(self.expectedTimeToStation.rounded()))")
                print("----------expectedTimeUj \(Int(expectedTime.rounded()))")
                //ha percben kulonbozik a ket ido, update-oljuk a messageLauncher-ba
                if(Int(self.expectedTimeToStation.rounded()) != Int(expectedTime.rounded())) {
                    print("********kulonboznek: \(Int(self.expectedTimeToStation.rounded())) es \(Int(expectedTime.rounded()))")
                    self.expectedTimeToStation = expectedTime
                    //self.messageLauncherViewController?.expectedTime = expectedTime
                    self.durationTextLabel!.text = String(format: "%d Minutes", Int(expectedTime.rounded()))
                    //self.performSegue(withIdentifier: "showMessageLauncher", sender: self)
                    //self.messageLauncherViewController.proba(time: expectedTime)
                    print("a fasz kivan ++++++++ \(self.messageLauncherViewController?.durationTextLabel)")
                    self.messageLauncherViewController?.durationTextLabel?.text = String(format: "%d Minutes", Int(expectedTime.rounded()))
                }
                else {
                    print("meg nem kulonboznek")
                }
                
                //            self.mapView.add(route.polyline, level: .aboveRoads)
                //            let rect = route.polyline.boundingMapRect
                //            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            }
        }

//        let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

    }
}
