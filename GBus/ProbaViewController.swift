//
//  ProbaViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 20/03/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ProbaViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()   //ez adja a GPS koordinatakat
    var location: CLLocation?
    var annotation = MKPointAnnotation()
    var annotation2 = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)*/

        // Do any additional setup after loading the view.
        //locationManager.delegate = self
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //locationManager.startUpdatingLocation()
        
        /*var coordinateData = CLLocationCoordinate2D(latitude: 37.3351212, longitude: -122.03256229)
        annotation2.coordinate = coordinateData
        mapView.addAnnotation(annotation2)
        let region = MKCoordinateRegionMakeWithDistance(self.annotation2.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)*/
        
        mapView.delegate = self
        
        /*let latitude: CLLocationDegrees = 39.048825
        let longitude: CLLocationDegrees = -120.981227
        
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Nem tudom"
        mapItem.openInMaps(launchOptions: options)*/
        
        
        //let region = MKCoordinateRegionMakeWithDistance(mapKit.userLocation.coordinate, 2000, 2000)
        //mapKit.setRegion(region, animated: true)
        
        /*let sourceLocation = CLLocationCoordinate2DMake(46.768321, 23.596480)
        let destinationLocation = CLLocationCoordinate2DMake(46.749505, 23.412459)
        
        let sourcePin = MKPointAnnotation()
        sourcePin.coordinate = sourceLocation
        let destinationPin = MKPointAnnotation()
        destinationPin.coordinate = destinationLocation
        self.mapView.addAnnotation(sourcePin)
        self.mapView.addAnnotation(destinationPin)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
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
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }*/
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
        let messageViewController = MessageLauncherViewController()
        messageViewController.modalPresentationStyle = .overCurrentContext
        present(messageViewController, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

/*extension ProbaViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //mapKit.removeAnnotation(annotation)
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation.coordinate.latitude)")
        print("didUpdateLocations \(newLocation.coordinate.longitude)")
        location = newLocation
        var coordinateData = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        annotation.coordinate = coordinateData
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegionMakeWithDistance(self.annotation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
}*/

/*extension ProbaViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView .setCenter(userLocation.coordinate, animated: true)
    }
    
}*/

extension ProbaViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("meghivodott renderer \n")
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 1
        return renderer
    }
    
}
