//
//  CatchesDataSource.swift
//  FishRuler
//
//  Created by user1 on 11/13/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import CoreData

class CatchesDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var catches = [Fish]()
    
   let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private func setupDataSource() {
        
        // pois = []
        
        do{
            let request: NSFetchRequest<Fish> = Fish.fetchRequest()
            
            let locations = try self.context.fetch(request)
            for location in locations{
                
                
                catches.append(location)
                
            }
            
        } catch {
            print("Failed")
        }
        
    }
    
    
 
        
        // MARK: - UITableViewDataSource
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            // let total = catches.count + routes.count
            return 2
            
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell",
                                                         for: indexPath) as? SearchResultCell
                
                
                cell?.configure(title: catches[indexPath.row].species!, subTitle: catches[indexPath.row].time!)
                
                let fishLength = catches[indexPath.row].length!
                let fishBait = catches[indexPath.row].bait
                let water = catches[indexPath.row].water
                let notes = catches[indexPath.row].notes
                let time = catches[indexPath.row].time
                
                let wind = catches[indexPath.row].windSpeed
                
                let temp = catches[indexPath.row].currentTemp
                let summary = catches[indexPath.row].weatherSummary
                
                cell?.lengthDetails.text = fishLength
                cell?.baitDetails.text = fishBait
                cell?.waterDetails.text = water
                cell?.notesDetails.text = notes
                cell?.windConditions.text = wind
                cell?.tempConditions.text = temp
                cell?.summaryConditions.text = summary
                
                cell?.fishID = time!
                
                return cell!
            }
            
    }
            


