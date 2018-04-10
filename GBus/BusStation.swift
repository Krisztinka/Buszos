//
//  BusStation.swift
//  GBus
//
//  Created by Krisztina Nagy on 27/03/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import Foundation
import MapKit

class BusStation: NSObject, MKAnnotation {
    let title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    override init() {
        self.title = ""
        self.subtitle = ""
        self.coordinate = CLLocationCoordinate2D(latitude: 44.439663, longitude: 26.096306)
        
        super.init()
    }
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    
    init(busAnnotation: MKAnnotation) {
        self.title = busAnnotation.title!
        self.subtitle = busAnnotation.subtitle!
        self.coordinate = busAnnotation.coordinate
    }
}
