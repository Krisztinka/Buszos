//
//  Passenger.swift
//  GBus
//
//  Created by Krisztina Nagy on 29/04/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import Foundation
import Firebase

class Passenger: NSObject {
    let key: String
    let name: String
    let surname: String
    let email: String
    let password: String
    let fullName: String
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        name = (snapshot.value as! NSDictionary)["name"] as! String
        surname = (snapshot.value as! NSDictionary)["surname"] as! String
        email = (snapshot.value as! NSDictionary)["email"] as! String
        password = (snapshot.value as! NSDictionary)["password"] as! String
        fullName = name + " " + surname
    }
    
    func writeData(){
        print("Ez egy passenger: \(name) surname: \(surname) email: \(email)")
    }
}
