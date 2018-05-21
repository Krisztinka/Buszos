//
//  Announcement.swift
//  GBus
//
//  Created by Krisztina Nagy on 15/05/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import Foundation
import Firebase

class Announcement: NSObject {
    let key: String
    let fromId: String
    let title: String
    let message: String
    let timestamp: Int
    let important: String
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        fromId = (snapshot.value as! NSDictionary)["fromId"] as! String
        title = (snapshot.value as! NSDictionary)["title"] as! String
        message = (snapshot.value as! NSDictionary)["message"] as! String
        timestamp = (snapshot.value as! NSDictionary)["timestamp"] as! Int
        important = (snapshot.value as! NSDictionary)["important"] as! String
    }
    
    func writeMessage(){
        print("Ez egy uzenet: \(title) szoveg: \(message) ido: \(timestamp) important \(important)")
    }
    
}
