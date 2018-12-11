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
    var paths = [Routes]()
    // temp filer for searcgh
    var searchRes: String = ""
    
    var poi: String = ""
    
   // var points: [AnyObject] = []
    
    
    
    var fishID: String = ""
     //I think this is for search
   // var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    var buttonIsSelected = false
    
    let locationManager = CLLocationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - IBOutlets
    


    @IBOutlet weak var stopFollowButton: UIButton!
    @IBOutlet weak var startFollowButton: UIButton!
    @IBOutlet weak var removeAll: UIButton!
    @IBOutlet weak var showPaths: UIButton!

    @IBOutlet weak var addCatchButton: UIButton!
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
       
        // Used to update when path is deleted
        NotificationCenter.default.addObserver(self, selector: #selector(loadPathList), name: NSNotification.Name(rawValue: "loadPath"), object: nil)
        // Used to update when catch is deleted
        NotificationCenter.default.addObserver(self, selector: #selector(loadCatchList), name: NSNotification.Name(rawValue: "loadCatch"), object: nil)
    
        
        startFollowButton.layer.borderWidth = 2
        startFollowButton.layer.borderColor = UIColor.black.cgColor
        startFollowButton.layer.cornerRadius = 5
        startFollowButton.layer.masksToBounds = true
        
        stopFollowButton.layer.borderWidth = 2
        stopFollowButton.layer.borderColor = UIColor.black.cgColor
        stopFollowButton.layer.cornerRadius = 5
        stopFollowButton.layer.masksToBounds = true
        stopFollowButton.isHidden = true
        
        removeAll.layer.borderWidth = 2
        removeAll.layer.borderColor = UIColor.black.cgColor
        removeAll.layer.cornerRadius = 5
        removeAll.layer.masksToBounds = true
        removeAll.isHidden = true
        
        showPaths.layer.borderWidth = 2
        showPaths.layer.borderColor = UIColor.black.cgColor
        showPaths.layer.cornerRadius = 5
        showPaths.layer.masksToBounds = true
        

        addCatchButton.layer.borderWidth = 2
        addCatchButton.layer.borderColor = UIColor.black.cgColor
        addCatchButton.layer.cornerRadius = 5
        addCatchButton.layer.masksToBounds = true

        
        
     
        tableView.keyboardDismissMode = .onDrag
 
        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: secondPreviewView.frame.maxY)
        landscapeFrame = CGRect(x: 5, y: 50, width: 280, height: 300)
        
        tableView.attach(to: self)
//        // This loads data on view load
//        setupDataSource()
        
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
                poi = "Fish"
            }

        } catch {
            print("Failed")
        }
        
   }
    
    private func setupPathDataSource() {
        
        do{
            let request: NSFetchRequest<Routes> = Routes.fetchRequest()
            
            let locations = try self.context.fetch(request)
            for location in locations{
                
                
                paths.append(location)
                poi = "Path"
            }
            
        } catch {
            print("Failed")
        }
        
    }
    
    // This code is to notify the tableView that a path was deleted
    @objc func loadPathList(notification: NSNotification){
        
        paths.removeAll()
        setupPathDataSource()
        tableView.reloadData()
    }
    
    // This is to notify when catch is deleted
    @objc func loadCatchList(notification: NSNotification){
        
        catches.removeAll()
        setupDataSource()
        tableView.reloadData()
    }
    
    @IBAction func showCatches(_ sender: Any) {
        
      
      //  (self.parent as? MapViewController)?.removePullUpController()
        
       addCatchButton.isSelected = !addCatchButton.isSelected
        addCatchButton.setTitle("Show Catches", for: UIControl.State.selected)

        (self.parent as? MapViewController)?.removeCatchPins()


        catches.removeAll()
        tableView.reloadData()
        
        if addCatchButton.isSelected {

            addCatchButton.setTitle("Hide Catches", for: UIControl.State.selected)
          (self.parent as? MapViewController)?.addCatchPins()

            //  load catch data to table
            setupDataSource()
            tableView.reloadData()
        }


    }
    @IBAction func startToFollow(_ sender: Any) {
        
        (self.parent as? MapViewController)?.addStartPin()
        startFollowButton.isHidden = true
        stopFollowButton.isHidden = false
    }
    
    @IBAction func stopFollowing(_ sender: Any) {
      
        removeAll.isHidden = false
        
        let alertController = UIAlertController(title: "Stop Tracking?",
                                                message: "Are you done with this trip?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
            
            
            
        })
        
        alertController.addAction(UIAlertAction(title: "Stop", style: .default) { _ in
            
            (self.parent as? MapViewController)?.addStopPin()
            
            self.startFollowButton.isHidden = false
            self.stopFollowButton.isHidden = true
            
        })
     
        present(alertController, animated: true)

    }
    
    @IBAction func showPaths(_ sender: Any) {
      //  (self.parent as? MapViewController)?.addPaths()
        
        showPaths.isSelected = !showPaths.isSelected
        showPaths.setTitle("Show Routes", for: UIControl.State.selected)
        
        (self.parent as? MapViewController)?.removePathPins()
        
        paths.removeAll()
        tableView.reloadData()
        
        if showPaths.isSelected {
            
            showPaths.setTitle("Remove Routes", for: UIControl.State.selected)
            (self.parent as? MapViewController)?.addPaths()
            
            setupPathDataSource()
            tableView.reloadData()
            
            print(paths.count)
            
        }
        
        
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

        
        let searchRequest = MKLocalSearch.Request()
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
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        return points.count
//    }

     //   return catches.count
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

  let tableValue = poi

        switch (tableValue) {
        case "Fish":
           // print(catches.count)
            return catches.count
        case "Path":
          //  print("pathData")
            return paths.count

        default:
          //  print("pathData")
            return paths.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableValue = poi
        
        switch (tableValue) {
            
        // The Catch cells
        case "Fish":
          guard  let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell",
                                                     for: indexPath) as? SearchResultCell
            else { return UITableViewCell() }
            
            cell.configure(title: catches[indexPath.row].species!, subTitle: catches[indexPath.row].time!)
            
            let fishLength = catches[indexPath.row].length!
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
            
            // fishID = time!
            
            return cell

            
        // path cell
        case "Path":
            
            guard let pathCell = tableView.dequeueReusableCell(withIdentifier: "pathCell", for: indexPath) as? PathResultsCell else { return UITableViewCell() }
            
            let sub = paths[indexPath.row].date
            
            pathCell.configure(title: "Path", subTitle: sub!)
               // pathCell.textLabel?.text = "Static"
                
                
                return pathCell
            
          default:
            return UITableViewCell()
        }
        
 
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.destination is CatchDetailsViewController{
//
//            let vc = segue.destination as? CatchDetailsViewController
//
//            vc?.catchID = fishID
//
//
//        }
//    }
//
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == selectedRowIndex {
            return 450 //Expanded
        }
        return 61 //Not expanded
    }
    
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
       
            pullUpControllerMoveToVisiblePoint(pullUpControllerMiddleStickyPoints[0], animated: true, completion: nil)
        let tableValue = poi
        
        switch (tableValue) {
            
        // The Catch cells
        case "Fish":
    
        
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
        let showAnno = MyAnnotation(coordinate: catchSpot, title: "", subtitle: "", newLength: "", newTime: "", newBait: "", newNotes: "", newWaterTempDepth: "", newWeatherCond: "")
 
        let time = catches[indexPath.row].time
        let kindaFish = catches[indexPath.row].species
        
        showAnno.title = kindaFish
        showAnno.subtitle = time
        
        (parent as? MapViewController)?.removeCatchPins()
        (parent as? MapViewController)?.zoom(to: catchSpot)
        (parent as? MapViewController)?.map.addAnnotation(showAnno)
        (parent as? MapViewController)?.map.selectAnnotation( showAnno, animated: true)   // To show the annotation view
        (parent as? MapViewController)?.selectedAnnotation?.newTime = time       // This will pass the ID for coreData
        
        
        self.mapView?.selectAnnotation(catches[indexPath.row] as! MKAnnotation, animated: true)
        
        case "Path":
            //print("pathData")
            if selectedRowIndex == indexPath.row {
                selectedRowIndex = -1
            } else {
                selectedRowIndex = indexPath.row
                
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            view.endEditing(true)
            
            // start of route anno
            let startPoint = paths[indexPath.row]
            let startSpot = CLLocationCoordinate2DMake(startPoint.latitude, startPoint.longitude)
//            let showAnno = CatchAnnotation()
            let time = paths[indexPath.row].catchID
            
            // the anno
            let startAnno = PathAnnotation()
            startAnno.coordinate = CLLocationCoordinate2D(latitude: startPoint.latitude, longitude: startPoint.longitude)
           
            startAnno.title = "Path"
            startAnno.subtitle = time
            startAnno.annoID = time
            
            (parent as? MapViewController)?.removeCatchPins()
            (parent as? MapViewController)?.zoom(to: startSpot)
            (parent as? MapViewController)?.map.addAnnotation(startAnno)
            (parent as? MapViewController)?.map.selectAnnotation(startAnno, animated: true)   // To show the annotation view
            (parent as? MapViewController)?.selectedRoute?.annoID = time       // This will pass the ID for coreData
            
            
            self.mapView?.selectAnnotation(catches[indexPath.row] as! MKAnnotation, animated: true)
            
        default:
            print("no anno")
        }
        
    }
 
}

