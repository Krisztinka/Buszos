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
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
}
