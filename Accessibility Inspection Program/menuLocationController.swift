//
//  menuLocationController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 3/4/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import CoreLocation

class menuLocationController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var picture: String!
    var uniqueID: Int!
    var username: String!
    var password: String!
    var site: String!
    var tracking: String!
    var elements: [Elemental] = []
    var location: String!
    var notes: String!
    var roll: [String] = []
    var locations: [String] = []
    var locationStatus: NSString = "Not Started"
    var locationManager: CLLocationManager!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationBar: UITextField!
    
    @IBAction func getButton(sender: AnyObject) {
        //if (getButton.titleLabel == "GPS") {
           //getGPSLocation()
        //} else {
            //getLocations()
        //}
        println("button pressed")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.performSegueWithIdentifier("returnDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println("cell #\(indexPath.row)!")
        self.locationBar.text = locations[indexPath.row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        if (location != nil) {
            locationBar.text = location
        }
        
        getLocations()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        //let cell = UITableViewCell()
        //let label = UILabel(CGRect(x:0, y:0, width:200, height:50))
        //label.text = "Hello Man"
        //cell.addSubview(label)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let location = self.locations[indexPath.row] as String
        //let descriptionData = self.descriptionData[indexPath.row] as String
        
        //cell.textLabel.text = rowData["tracking"] as? String
        //cell.textLabel.text = location
        
        if let locationLabel = cell.viewWithTag(150) as? UILabel {
            locationLabel.text = location
        }
        
        //if let descriptionLabel = cell.viewWithTag(101) as? UILabel{
        //    descriptionLabel.text = descriptionData
        //}
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        //let urlString: NSString = rowData["artworkUrl60"] as NSString
        //let imgURL: NSURL? = NSURL(string: urlString)
        
        // Download an NSData representation of the image at the URL
        //let imgData = NSData(contentsOfURL: imgURL!)
        //cell.imageView.image = UIImage(data: imgData!)
        
        // Get the formatted price string for display in the subtitle
        //let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        //cell.detailTextLabel?.text = formattedPrice
        return cell
    }
    
    
    // UITableViewDelegate Functions
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func getLocations() {
        var elements = self.elements
        var locations: [String] = []
        
        for item in elements {
            if (!contains(locations, item.location!)) {
                locations.append(item.location!)
            }
        }
        
        self.locations = locations
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]) {
        println("okay...")
        //gpsCoordinates.text = manager.location.description
        locationBar.text = manager.location.description
        println(manager.location.description)
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error) -> Void in
            
            println("getting location...")
            if (error != nil) {
                println("Reverse Geocode failed with error:" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                println("Problem with the data recieved from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark!) {
        if placemark != nil {
            println("getting address")
            locationManager.stopUpdatingLocation()
            /*println(placemark.locality)
            println(placemark.postalCode)
            println(placemark.administrativeArea)
            println(placemark.country)*/
            println(placemark)
            let name = placemark.name
            let address = placemark.addressDictionary
            let city = placemark.locality
            //println(address)
            
            //self.gpsLabel.text = "\(name) \(city)"
            self.locationBar.text = "\(name) \(city)"
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location" + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocation!, didChangeAuthorizeStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        if (shouldIAllow == true) {
            println("Location to Allowed")
            locationManager.startUpdatingLocation()
        } else {
            println("Denied access: \(locationStatus)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var navigationController =  segue.destinationViewController as UINavigationController
        var controller = navigationController.topViewController as detailView
        //controller.delegate = self
            
        controller.uniqueID = self.uniqueID
        controller.location = self.locationBar.text
        controller.picture = self.picture
        controller.notes = self.notes
        controller.username = self.username
        controller.password = self.password
        controller.site = self.site
        controller.tracking = self.tracking
        controller.elements = self.elements
        controller.roll = self.roll
    }
}
