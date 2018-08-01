//
//  PicturePreviewViewController.swift
//  FishRuler
//
//  Created by user1 on 7/31/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

class PicturePreviewViewController: UIViewController {
    
    var showMyPic = UIImage()

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = showMyPic
        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
