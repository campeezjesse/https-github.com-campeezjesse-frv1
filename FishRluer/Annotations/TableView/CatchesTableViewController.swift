//
//  CatchesTableViewController.swift
//  FishRuler
//
//  Created by user1 on 9/7/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit

struct Details {
    
    var id : Int
    var species : String
    var bait : String
    
    
}
class CatchesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    var details = [
        Details(id: 1, species: "Bass", bait: "DD 22"),
        Details(id: 2, species: "Catfish", bait: "Hotdog"),
        Details(id: 3, species: "Crappie", bait: "minnow"),
        ]

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return details.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Details Cell", for: indexPath)
        
        cell.textLabel?.text = details[indexPath.row].species
        cell.textLabel?.text = details[indexPath.row].bait
        
        return cell
    }
    

   
}
