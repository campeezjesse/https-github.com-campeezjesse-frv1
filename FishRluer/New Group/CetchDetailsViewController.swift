//
//  CetchDetailsViewController.swift
//  FishRuler
//
//  Created by user1 on 7/5/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

class CetchDetailsViewController: UIViewController {

    @IBOutlet weak var catchImage: UIImageView!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var timeDateLabel: UILabel!
    @IBOutlet weak var waterConditionsLabel: UILabel!
    @IBOutlet weak var baitUsedLabel: UILabel!
    @IBOutlet weak var weatherConditionsLabel: UILabel!
    @IBOutlet weak var extraNotesLabel: UILabel!
    @IBOutlet weak var goBackButton: UIButton!
    
    
        let fishImage = UIImage()
    let fishSpecies: String = ""
    let fishLength: String = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func goBackButton(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
}
