//
//  ImageDisplayViewController.swift
//  FishRuler
//
//  Created by user1 on 6/7/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

class ImageDisplayViewController: UIViewController{
    
var showMyPic = UIImage()
   

    @IBOutlet weak var showPic: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showPic.image = showMyPic
        
       
        // Do any additional setup after loading the view.
    }
}