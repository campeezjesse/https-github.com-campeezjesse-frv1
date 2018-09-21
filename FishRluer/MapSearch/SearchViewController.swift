//
//  SearchViewController.swift
//  FishRluer
//
//  Created by user1 on 5/29/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import MapKit
import PullUpController
import CoreData




class SearchViewController: PullUpController {
    
    //Expand tableView cell
 var selectedRowIndex = -1
    
    var resultSearchController:UISearchController? = nil
    var catches = [Fish]()
    
    var fishID: String = ""
    
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    let locationManager = CLLocationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - IBOutlets
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var searchBoxContainerView: UIView!
    @IBOutlet private weak var searchSeparatorView: UIView! {
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height/2
        }
    }
    @IBOutlet private weak var firstPreviewView: UIView!
    @IBOutlet private weak var secondPreviewView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    
    private var locations = [(title: String, location: CLLocationCoordinate2D)]()
    
    public var portraitSize: CGSize = .zero
    public var landscapeFrame: CGRect = .zero
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        tableView.keyboardDismissMode = .onDrag
 
        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: secondPreviewView.frame.maxY)
        landscapeFrame = CGRect(x: 5, y: 50, width: 280, height: 300)
        
        tableView.attach(to: self)
        setupDataSource()
        
        willMoveToStickyPoint = { point in
          //  print("willMoveToStickyPoint \(point)")
        }
        
        didMoveToStickyPoint = { point in
          //  print("didMoveToStickyPoint \(point)")
        }
        
        onDrag = { point in
          //  print("onDrag: \(point)")
            
            self.view.endEditing(true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layer.cornerRadius = 12

    }
    
    private func setupDataSource() {
        
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
    
    @IBAction func editButtPressed(_ sender: Any) {
        performSegue(withIdentifier: "editButt", sender: self)
    }
    
    // MARK: - PullUpController
    
    override var pullUpControllerPreferredSize: CGSize {
        return portraitSize
    }
    
    override var pullUpControllerPreferredLandscapeFrame: CGRect {
        return landscapeFrame
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return searchBoxContainerView.frame.height
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [firstPreviewView.frame.maxY]
    }
    
    override var pullUpControllerIsBouncingEnabled: Bool {
        return false
    }
    

}


// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let lastStickyPoint = pullUpControllerAllStickyPoints.last {
            pullUpControllerMoveToVisiblePoint(lastStickyPoint, animated: true, completion: nil)
    
            
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)

        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (responce, Error) in
            if responce == nil{
                print("Error")
            }
            else {
                
                //get data
                
                let latitude = responce?.boundingRegion.center.latitude
                let longitude = responce?.boundingRegion.center.longitude
                
                // annotation
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            
                let searchLocation = annotation.coordinate
                
                (self.parent as? MapViewController)?.zoom(to: searchLocation)
                
                self.pullUpControllerMoveToVisiblePoint(self.pullUpControllerPreviewOffset, animated: true, completion: nil)
            }
        }
        
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catches.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell",
                                                     for: indexPath) as? SearchResultCell
            else { return UITableViewCell() }
        
        cell.configure(title: catches[indexPath.row].species!, subTitle: catches[indexPath.row].time!)
        
//        cell.editButt.layer.borderColor = UIColor.black.cgColor
//        cell.editButt.layer.borderWidth = 1.0
//        cell.editButt.layer.cornerRadius = 0.5
//
//        cell.directionsButt.layer.borderColor = UIColor.black.cgColor
//        cell.directionsButt.layer.borderWidth = 2.0
//        cell.directionsButt.layer.cornerRadius = 0.5

        
        let fishLength = "Length: " + catches[indexPath.row].length!
        let fishBait = catches[indexPath.row].bait
        let water = catches[indexPath.row].water
        let notes = catches[indexPath.row].notes
        let time = catches[indexPath.row].time
        
        let wind = catches[indexPath.row].windSpeed
    
        let temp = catches[indexPath.row].currentTemp
        let summary = catches[indexPath.row].weatherSummary
        
        cell.lengthDetails.text = fishLength
        cell.baitDetails.text = fishBait
        cell.waterDetails.text = water
        cell.notesDetails.text = notes
        cell.windConditions.text = wind
        cell.tempConditions.text = temp
        cell.summaryConditions.text = summary
        
        cell.fishID = time!
        
        fishID = time!
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CatchDetailsViewController{
            
            let vc = segue.destination as? CatchDetailsViewController
            
            vc?.catchID = fishID
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex {
            return 450 //Expanded
        }
        return 61 //Not expanded
    }
    
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
       // if let lastStickyPoint = pullUpControllerAllStickyPoints.last {
            pullUpControllerMoveToVisiblePoint(pullUpControllerMiddleStickyPoints[0], animated: true, completion: nil)
            
       // }
        
        if selectedRowIndex == indexPath.row {
            selectedRowIndex = -1
        } else {
            selectedRowIndex = indexPath.row
            
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        view.endEditing(true)
     
        
        let fishPoint = catches[indexPath.row]
        let catchSpot = CLLocationCoordinate2DMake(fishPoint.latitude, fishPoint.longitude)
 
        
        (parent as? MapViewController)?.zoom(to: catchSpot)
        self.mapView?.selectAnnotation(catches[indexPath.row] as! MKAnnotation, animated: true)
        
    }

}


