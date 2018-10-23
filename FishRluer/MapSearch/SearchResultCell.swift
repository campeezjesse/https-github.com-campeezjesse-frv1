//
//  SearchResultCell.swift
//  FishRluer
//
//  Created by user1 on 5/29/18.
//  Copyright © 2018 campeez. All rights reserved.
//
import UIKit


class SearchResultCell: UITableViewCell {
    
    var fishID: String = ""
    
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

