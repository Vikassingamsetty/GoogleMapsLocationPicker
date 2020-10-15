//
//  ViewController.swift
//  MapsPlacesLocation
//
//  Created by vikas on 15/10/20.
//  Copyright © 2020 vikas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func currentLocationAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "AddressVC") as! AddressVC
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    

}

