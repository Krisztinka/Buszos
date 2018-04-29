//
//  WaitMessages.swift
//  GBus
//
//  Created by Krisztina Nagy on 29/04/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import Foundation
import Firebase

class WaitMessage: NSObject {
    let fromId: String
    let toId: String
    let timestamp: Int
    let station: String
    let fullName: String
    
    init(snapshot: DataSnapshot) {
        fromId = (snapshot.value as! NSDictionary)["fromId"] as! String
        toId = (snapshot.value as! NSDictionary)["toId"] as! String
        timestamp = (snapshot.value as! NSDictionary)["timestamp"] as! Int
        station = (snapshot.value as! NSDictionary)["station"] as! String
        fullName = (snapshot.value as! NSDictionary)["fullName"] as! String
    }
    
    func writeMessage(){
        print("Ez egy uzenet: \(fromId) sofor szamara: \(toId) ido: \(timestamp)")
    }
}
