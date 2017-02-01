//
//  EndUserAgreementViewController.swift
//  Flare
//
//  Created by Halston van der Sluys on 12/9/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit

class EndUserAgreementViewController: UIViewController {
    
    var route: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickBackButton(_ sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        if route == "rootView" {
            let endUserAgreementController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "rootView")
            self.present(endUserAgreementController, animated: true, completion: nil)
        } else {
            let profileViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "profileView")
            self.present(profileViewController, animated: true, completion: nil)
        }
        
    }

    
}

