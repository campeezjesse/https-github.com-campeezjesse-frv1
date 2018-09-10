//
//  CatchTableViewController.swift
//  FishRuler
//
//  Created by user1 on 9/7/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

struct Headline {
    
    var id : Int
    var species : String
    var bait : String
   
    
}

class CatchTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    var headlines = [
        Headline(id: 1, species: "Bass", bait: "DD 22"),
        Headline(id: 2, species: "Catfish", bait: "Hotdog"),
        Headline(id: 3, species: "Crappie", bait: "minnow"),
        ]
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return headlines.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        cell.textLabel?.text = headlines[indexPath.row].species
        
        return cell
    }
    
}
