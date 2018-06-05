//
//  gombViewController.swift
//  GBus
//
//  Created by Krisztina Nagy on 05/06/2018.
//  Copyright © 2018 Krisztina. All rights reserved.
//

import UIKit

class gombViewController: UIViewController {

    @IBAction func megnyomta(_ sender: UIButton) {
        performSegue(withIdentifier: "mutasd", sender: self)
        //let vc = VisualViewController()
        //vc.szam = 10
        //present(vc, animated: true, completion: nil)
        //show(vc, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.cyan

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue")
        if (segue.identifier == "mutasd") {
            let vc = segue.destination as! VisualViewController
            vc.szam = 10
        }
    }
}
