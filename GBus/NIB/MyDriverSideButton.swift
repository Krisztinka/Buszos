//
//  MyDriverSideButton.swift
//  GBus
//
//  Created by Krisztina Nagy on 24/05/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import Foundation
import UIKit

class MyDriverSideButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let color = UIColor.gray
        let disabledColor = color.withAlphaComponent(0.3)
        
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
        self.layer.borderWidth = 3.0
        self.layer.borderColor = color.cgColor
        
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitle(self.titleLabel?.text?.uppercased(), for: .normal)
    }
    
}
