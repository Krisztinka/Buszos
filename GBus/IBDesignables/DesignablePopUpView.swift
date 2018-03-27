//
//  DesignablePopUpView.swift
//  GBus
//
//  Created by macmini on 3/5/18.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit


@IBDesignable class DesignablePopUpView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }


}
