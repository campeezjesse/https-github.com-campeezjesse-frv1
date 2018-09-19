//
//  SearchResultCell.swift
//  PullUpControllerDemo
//
//  Created by Mario on 04/11/2017.
//  Copyright © 2017 Mario. All rights reserved.
//

import UIKit


class SearchResultCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var lengthDetails: UILabel!
    @IBOutlet weak var baitDetails: UILabel!
    @IBOutlet weak var waterDetails: UILabel!
    @IBOutlet weak var notesDetails: UILabel!
    
    @IBOutlet weak var windConditions: UILabel!
    @IBOutlet weak var tempConditions: UILabel!
    @IBOutlet weak var summaryConditions: UILabel!
    
    
    func configure(title: String, subTitle: String) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
}

