//
//  MyLoginPageButton.swift
//  GBus
//
//  Created by Krisztina Nagy on 25/04/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import Foundation
import UIKit

class MyLoginPageButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let color = UIColor.white
        let disabledColor = color.withAlphaComponent(0.3)
        
        self.frame.origin = CGPoint(x: (((superview?.frame.width)! / 2) - (self.frame.width / 2)), y: self.frame.origin.y)
        
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
        self.layer.borderWidth = 3.0
        self.layer.borderColor = color.cgColor
        
        self.setTitleColor(color, for: .normal)
        self.setTitleColor(disabledColor, for: .disabled)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.setTitle(self.titleLabel?.text?.capitalized, for: .normal)
    }
    
}
