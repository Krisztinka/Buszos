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
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var location: CLLocation?
    var annotation = MKPointAnnotation()
    var newPosition = CLLocationCoordinate2D()
    var coordinateData = CLLocationCoordinate2D()
    //let refDatabase = Database.database().reference(fromURL: "https://gbus-8b03b.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("coordinates").observe(.childChanged, with: { snapshot in
            print("nem jo be\n")
            print(snapshot.value)
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                var longitudee = dictionary["longitude"] as! Double
                var latitudee = dictionary["latitude"] as! Double
                print(longitudee)
                print(latitudee)
                self.location = CLLocation(latitude: latitudee, longitude: longitudee)
                
                self.coordinateData = CLLocationCoordinate2D(latitude: latitudee, longitude: longitudee)
                //var coordinateData = CLLocationCoordinate2D(latitude: 44.439663, longitude: 26.096306)
                //let annotation = MKPointAnnotation()
                //self.mapView.removeAnnotation(self.annotation)
                self.annotation.coordinate = self.coordinateData
                self.mapView.addAnnotation(self.annotation)
                let region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 1000, 1000)
                self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
            }
        })
        
        
        
        Database.database().reference().child("coordinates").child("location").observeSingleEvent(of: .value, with: { snapshot in
            print("bejott masodikba\n")
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                var longitudee = dictionary["longitude"] as! Double
                var latitudee = dictionary["latitude"] as! Double
                print(longitudee)
                print(latitudee)
                self.location = CLLocation(latitude: latitudee, longitude: longitudee)
                
                var coordinateData = CLLocationCoordinate2D(latitude: latitudee, longitude: longitudee)
                //var coordinateData = CLLocationCoordinate2D(latitude: 44.439663, longitude: 26.096306)
                //let annotation = MKPointAnnotation()
                self.annotation.coordinate = coordinateData
                self.mapView.addAnnotation(self.annotation)
                let region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 1000, 1000)
                self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
            }
        })
        
        /*let busRef = refDatabase.child("coordinates").child("location")
        busRef.observe(.value, with: { snapshot in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary["latitude"] as? String)
                print(dictionary["longitude"] as? String)
            }
        })*/
    }
    
    
    // MARK:- Actions
    @IBAction func showUser() {
        //let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 2000, 2000)
        //mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        //var myLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        
        self.annotation.coordinate = CLLocationCoordinate2D(latitude: 46.768321, longitude: 23.596480)
        self.mapView.addAnnotation(self.annotation)
        let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10000, 10000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        UIView.animate(withDuration: 2, animations: {
            
            //self.newPosition = CLLocationCoordinate2D(latitude: 46.749505, longitude: 23.412459)
            self.annotation.coordinate = CLLocationCoordinate2D(latitude: 46.749505, longitude: 23.412459)
        })
        
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

extension BejelentkezettViewController: MKMapViewDelegate {
    
}
