//
//  SearchViewController.swift
//  PullUpControllerDemo
//
//  Created by Mario on 03/11/2017.
//  Copyright © 2017 Mario. All rights reserved.
//

import UIKit
import MapKit
import PullUpController
import CoreData


class SearchViewController: PullUpController {
    
    var resultSearchController:UISearchController? = nil
    var catches = [Fish]()
    
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
        
       // dismissKeyboard()
        
      // self.hideKeyboard()
        tableView.keyboardDismissMode = .onDrag
 
        portraitSize = CGSize(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height),
                              height: secondPreviewView.frame.maxY)
        landscapeFrame = CGRect(x: 5, y: 50, width: 280, height: 300)
        
        tableView.attach(to: self)
        setupDataSource()
        
        willMoveToStickyPoint = { point in
            print("willMoveToStickyPoint \(point)")
        }
        
        didMoveToStickyPoint = { point in
            print("didMoveToStickyPoint \(point)")
        }
        
        onDrag = { point in
            print("onDrag: \(point)")
            
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
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        pullUpControllerMoveToVisiblePoint(pullUpControllerMiddleStickyPoints[0], animated: true, completion: nil)
        
        let fishPoint = catches[indexPath.row]
        let catchSpot = CLLocationCoordinate2DMake(fishPoint.latitude, fishPoint.longitude)
 
        
        (parent as? MapViewController)?.zoom(to: catchSpot)
        
    }
}

