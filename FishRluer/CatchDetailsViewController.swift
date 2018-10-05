//
//  CatchDetailsViewController.swift
//  FishRuler
//
//  Created by user1 on 10/3/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import CoreData


class CatchDetailsViewController: UIViewController {

    @IBOutlet weak var deleteCatchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var dateTimeLabel: UITextField!
    @IBOutlet weak var lengthLabel: UITextField!
    
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherSummaryLabel: UILabel!
    
    @IBOutlet weak var speciesLabel: UITextField!
    @IBOutlet weak var waterConditionsLabel: UITextField!
    @IBOutlet weak var baitUsedLabel: UITextField!
    @IBOutlet weak var notesLabel: UITextView!

    
    var catchID: String = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        // date and time passed from annotation to be used as ID
        
       // dateTimeLabel.text = catchID
        
        //let ID = self.dateTimeLabel.text
        let ID = catchID
        
        do{
            let request: NSFetchRequest<Fish> = Fish.fetchRequest()
            let predicate = NSPredicate(format: "time == %@", ID)
            request.predicate = predicate
            
            let locations = try self.context.fetch(request)
            for location in locations{
                
                
                // Load the information from CoreData

                let fishKind = location.species
                let waterTempDepth = location.water
                let bait = location.bait
                let size = location.length
                let notes = location.notes
                let wind = location.windSpeed
                let temp = location.currentTemp
                let summary = location.weatherSummary
                let dateTime = location.time


                dateTimeLabel.text = dateTime
                speciesLabel.text = fishKind
                lengthLabel.text = size
                windLabel.text = wind
                tempLabel.text = temp
                weatherSummaryLabel.text = summary
                waterConditionsLabel.text = waterTempDepth
                baitUsedLabel.text = bait
                notesLabel.text = notes
    
            }
        } catch {
            print("Failed")
        }
        
        
    
    }
    

    @IBAction func goBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func deleteCatch(_ sender: Any) {
        
                let alert = UIAlertController(title: "Are You Sure?", message: "Any changes are permenate!", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
                let deleteDataAction = UIAlertAction(title: "delete", style: .destructive, handler: { action in
        
                    let pinTitle = self.dateTimeLabel.text
        
                        do{
                            let request: NSFetchRequest<Fish> = Fish.fetchRequest()
                            let predicate = NSPredicate(format: "time == %@", pinTitle!)
                            request.predicate = predicate
        
                            let locations = try self.context.fetch(request)
                            for location in locations{
                                self.context.delete(location)
        
                           
                                
                            }
                        } catch {
                            print("Failed")
                    }
        
                    do {
                        try self.context.save()
                        
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.75, execute: {
                            self.performSegue(withIdentifier:"backToMap",sender: self)
                            
                            
                        })
                        
//                        // the alert view once deleted
//                        let alert = UIAlertController(title: "Catch Is Deleted", message: "You may have to refresh your map.(it was hooked well!)", preferredStyle: .alert)
//                        self.present(alert, animated: true, completion: nil)
//
//                        // change to desired number of seconds (in this case 5 seconds)
//                        let when = DispatchTime.now() + 3
//                        DispatchQueue.main.asyncAfter(deadline: when){
//                            // your code with delay
//                            alert.dismiss(animated: true, completion: nil)
                    //    }
                    } catch {
                        print("Failed saving")
                    }
        
                })
        
        
                alert.addAction(cancelAction)
                alert.addAction(deleteDataAction)
        
                self.present(alert, animated: true, completion: nil)
    }
    @IBAction func saveNewInfo(_ sender: Any) {
        
        // date and time passed from annotation to be used as ID
        
        
        let ID = catchID
        
        do{
            let request: NSFetchRequest<Fish> = Fish.fetchRequest()
            let predicate = NSPredicate(format: "time == %@", ID)
            request.predicate = predicate
            
            let locations = try self.context.fetch(request)
            for location in locations{
                
                //this is where we set the information to be saved into the coreData model named "Fish"
                
                let fishKind = speciesLabel.text
                let waterTempDepth = waterConditionsLabel.text
                let bait = baitUsedLabel.text
//                let theTemp = tempLabel.text
//                let theWind = windLabel.text
//                let theSummary = weatherSummaryLabel.text
                let notes = notesLabel.text
                let size = lengthLabel.text
                let catchTimeandDate = dateTimeLabel.text
                
            
             
                location.species = fishKind
                location.length = size
                location.water = waterTempDepth
                location.bait = bait
                location.time = catchTimeandDate
                
                location.notes = notes
                
//                newPin.currentTemp = theTemp
//                newPin.weatherSummary = theSummary
//                newPin.windSpeed = theWind
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.75, execute: {
                    self.performSegue(withIdentifier:"backToMap",sender: self)
                    
                    
                })
                
//                activityIndicator.isHidden = false
                
                
            }
        } catch {
            print("Failed")
        }
                
    }
}
