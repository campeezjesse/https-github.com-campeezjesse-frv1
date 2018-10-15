//
//  HomeViewController.swift
//  FishRuler
//
//  Created by user1 on 10/4/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var addToMap: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button for bottom of initial vc
        addToMap.layer.borderWidth = 5
        addToMap.layer.borderColor = UIColor.black.cgColor
        addToMap.layer.cornerRadius = 5
        addToMap.layer.masksToBounds = true
        
        // Hide the nav bar it f-s up the top area
navigationController?.setNavigationBarHidden(true, animated: false)

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageDisplayViewController{
            
           // let vc = segue.destination as? ImageDisplayViewController
            
            
            
           // vc?.length = "Size: "
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
