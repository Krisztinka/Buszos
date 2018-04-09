//
//  Driver.swift
//  GBus
//
//  Created by Krisztina Nagy on 09/04/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import Foundation
import Firebase

class Driver: NSObject {
    let name: String
    let surname: String
    let email: String
    let drivesFrom: String
    let key: String
    let ref: DatabaseReference?
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        ref = snapshot.ref
        print("key: \(key)")
        name = (snapshot.value as! NSDictionary)["name"] as! String
        surname = (snapshot.value as! NSDictionary)["surname"] as! String
        email = (snapshot.value as! NSDictionary)["email"] as! String
        drivesFrom = (snapshot.value as! NSDictionary)["from"] as! String
    }
}
