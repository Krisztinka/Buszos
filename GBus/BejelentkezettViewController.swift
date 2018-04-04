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

class BejelentkezettViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var annotation = MKPointAnnotation()
    //a megallok listaja
    var stations = [BusStation]()
    
    //let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    
    // MARK:- Actions
    @IBAction func showUser() {
        //let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 2000, 2000)
        //mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        //var myLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        var latitude = 46.768321
        var longitude = 23.596480
        var i = 10
        while i > 0 {
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.addAnnotation(self.annotation)
            //let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10000, 10000)
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 37.3542926, longitude: -122.087257), 10000, 1000)
            //let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10000, 10000)
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
            UIView.animate(withDuration: 2, animations: {
                
                //self.newPosition = CLLocationCoordinate2D(latitude: 46.749505, longitude: 23.412459)
                latitude = latitude + 0.001
                longitude = longitude + 0.001
                self.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                i = i-1
                print(i)
            })
            
        }
        
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
        //performSegue(withIdentifier: "showMessageLauncher", sender: self)
        let messageViewController = MessageLauncherViewController()
        messageViewController.modalPresentationStyle = .overCurrentContext
        present(messageViewController, animated: true, completion: nil)
        
        //var sta = view.annotation! as! BusStation
        //sta.mapItem().openInMaps(launchOptions: )
        
        //bejarjuk a megallo listat es megkeressuk melyek volt megnyomva
        /*for station in stations {
            if station.title == (view.annotation?.title)! {
                print("egyforma \(station.title)")
                //mapView.removeAnnotation(station)
                //view.isHidden = true
                station.subtitle = "kerleeeek"
                //view.isHidden = false
                //mapView.addAnnotation(station)
                //mapView(mapView, didSelect: view)
            }
        }*/
        
        //let annotation = view.annotation!
        //mapView.removeAnnotation(view.annotation!)
        //annotation.subtitle = "menjel na:("
        
    }
    
    //amikor raklickkelek egy pin-re jelenjen meg a traseu
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("raklikkeltem")
        
        let sourceLocation = CLLocationCoordinate2DMake(37.3542926, -122.087257)
        let destinationLocation = view.annotation?.coordinate
        //CLLocationCoordinate2DMake(46.749505, 23.412459)
        
        let sourcePin = MKPointAnnotation()
        sourcePin.coordinate = sourceLocation
        self.mapView.addAnnotation(sourcePin)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation!, addressDictionary: nil)
        
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
            let eta = route.expectedTravelTime / 60.0
            print("varhato ido: \(eta) perc")
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
}
