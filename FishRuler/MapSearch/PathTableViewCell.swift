//
//  PathTableViewCell.swift
//  FishRuler
//
//  Created by user1 on 11/12/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

class PathTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var runTimeLabel: UILabel!
    @IBOutlet weak var runPaceLabel: UILabel!
    @IBOutlet weak var fishCaughtLabel: UILabel!
    
    
    
    func configure(title: String, subTitle: String) {
        titleLabel.text = title
        dateLabel.text = subTitle
    }
    
}
