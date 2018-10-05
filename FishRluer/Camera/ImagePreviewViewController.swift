//
//  ImagePreviewViewController.swift
//  FishRuler
//
//  Created by user1 on 10/5/18.
//  Copyright © 2018 campeez. All rights reserved.
//


import UIKit
import CameraManager

class ImagePreviewViewController: UIViewController {


        var image: UIImage?
        var cameraManager: CameraManager?
        @IBOutlet weak var imageView: UIImageView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.navigationController?.navigationBar.isHidden = true
            
            guard let validImage = image else {
                return
            }
            
            self.imageView.image = validImage
            
            if cameraManager?.cameraDevice == .front {
                switch validImage.imageOrientation {
                case .up, .down:
                    self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                default:
                    break
                }
            }
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        @IBAction func closeButtonTapped(_ sender: Any) {
            navigationController?.popViewController(animated: true)
        }
        
        override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
            return .portrait
        }
        
        override var shouldAutorotate: Bool {
            return false
        }
}
