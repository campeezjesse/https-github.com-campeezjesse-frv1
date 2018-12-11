//
//  PathResultsCell.swift
//  FishRuler
//
//  Created by user1 on 12/7/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

class PathResultsCell: UITableViewCell {
    @IBOutlet weak var pathImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        func configure(title: String, subTitle: String) {
            titleLabel.text = title
            subtitleLabel.text = subTitle
        }
        
    }
    
// }
