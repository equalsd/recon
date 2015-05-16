//
//  menuLocationController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 3/4/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class menuLocationController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var picture: String!
    var elements: [Elemental] = []
    var state: position!
    var notes: String!
    var locations: [String] = []
    var locationStatus: NSString = "Not Started"
    var locationManager: CLLocationManager!
    var selectedLocation: String!
    var done: String!
    var color: Int!
    
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
        if (locationBar.text != "") {
            if (self.done == "elementCategoryController") {
                self.elements.append(Elemental(location: self.locationBar.text, picture: "location", notes: "", category: self.state.current(), uniqueID: -2))
                
                coreRemoveElements()
                coreSaveElements()
                
                var ecc = self.storyboard?.instantiateViewControllerWithIdentifier("elementBoard") as! elementCategoryController
                ecc.state = self.state
                ecc.elements = self.elements
                
                self.navigationController!.pushViewController(ecc, animated: true)
            } else {
                self.performSegueWithIdentifier("locationToDetail", sender: self)
            }
        } else {
            var emptyAlert = UIAlertController(title: "Warning", message: "Location must be filled out before continuing!", preferredStyle: UIAlertControllerStyle.Alert)
            emptyAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {( action: UIAlertAction!) in
            }))
            
            self.presentViewController(emptyAlert, animated: true, completion: nil)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println("cell #\(indexPath.row)!")
        self.locationBar.text = locations[indexPath.row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        if (self.selectedLocation != nil) {
            locationBar.text = self.selectedLocation
        } else {
            var currentLocation = self.state.last()
            if (currentLocation != "empty") {
                locationBar.text = currentLocation
            } else {
                locationBar.text = ""
            }
        }
        
        getLocations()
        self.color = self.locations.count
        addDefaultLocations()
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        //let cell = UITableViewCell()
        //let label = UILabel(CGRect(x:0, y:0, width:200, height:50))
        //label.text = "Hello Man"
        //cell.addSubview(label)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UITableViewCell
        
        let location = self.locations[indexPath.row] as String
        
        if let locationLabel = cell.viewWithTag(150) as? UILabel {
            locationLabel.text = location
            if (indexPath.row >= self.color) {
                locationLabel.textColor = UIColor.grayColor()
            }
        }
        
        return cell
    }
    
    func getLocations() {
        var elements = self.elements
        var locations: [String] = []
        
        for item in elements {
            if (!contains(locations, item.location! as String)) {
                locations.append(item.location! as String)
            }
        }
        
        self.locations = locations
    }
    
    func addDefaultLocations() {
        var location = self.state.last()
        
        if (location == "Parking Lots") {
            self.locations.extend(["Main Parking", "East Parking", "North Parking", "South Parking", "West Parking", "Parking 1", "Parking 2"])
        } else if (location == "Restrooms") {
            self.locations.extend(["Female Restroom", "Male Restroom", "Unisex Restroom", "Restroom 1", "Restroom 2"])
        } else if (location == "Path") {
            self.locations.extend(["Elevator", "Floor", "Hallway", "Lobby", "Ramp", "Room", "Stairs"])
        } else if (location == "Exterior Path of Travel") {
            self.locations.extend(["Curb Ramp", "Elevator", "Ramp", "Sidewalk", "Stairs"])
        }
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
                let pm = placemarks[0] as! CLPlacemark
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
    
    func keyboardShow(n:NSNotification) {
        /*self.keyboardShowing = true
        
        let d = n.userInfo!
        var r = (d[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        r = self.notesField.convertRect(r, fromView:nil)
        self.notesField.contentInset.bottom = r.size.height
        self.notesField.scrollIndicatorInsets.bottom = r.size.height
        println("s")*/
        animateViewMoving(true, moveValue: 220)
    }
    
    func keyboardHide(n:NSNotification) {
        /*self.keyboardShowing = false
        self.notesField.contentInset = UIEdgeInsetsZero
        self.notesField.scrollIndicatorInsets = UIEdgeInsetsZero*/
        animateViewMoving(false, moveValue: 220)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        var movementDuration:NSTimeInterval = 0.3
        var movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = CGRectOffset(self.view.frame, 0,  movement)
        UIView.commitAnimations()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var navigationController =  segue.destinationViewController as! UINavigationController
        var controller = navigationController.topViewController as! detailView
        //controller.delegate = self
            
        //controller.uniqueID = self.uniqueID
        //controller.location = self.locationBar.text
        //controller.picture = self.picture
        //controller.notes = self.notes
        controller.state = self.state
        controller.selectedLocation = self.selectedLocation
        //controller.selectedLocation = self.selectedLocatio
        println(locationBar.text)
    }
    
    func coreSaveElements() {
        println("inserting...Core")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Elements", inManagedObjectContext: managedContext)
        
        
        var index = 0
        for element in elements {
            var item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            item.setValue(element.location, forKey: "location")
            item.setValue(element.picture, forKey: "picture")
            item.setValue(element.notes, forKey: "notes")
            item.setValue(element.category, forKey: "category")
            item.setValue(index, forKey: "uniqueID")
            
            var error: NSError?
            if !managedContext.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            index++
        }
    }
    
    func coreRemoveElements() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext: NSManagedObjectContext = appDelegate.managedObjectContext!
        
        let entity = NSFetchRequest(entityName: "Elements")
        
        //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        var error: NSError? = nil
        let list = managedContext.executeFetchRequest(entity, error: &error)
        
        if let users = list {
            var bas: NSManagedObject!
            
            for bas: AnyObject in users {
                managedContext.deleteObject(bas as! NSManagedObject)
            }
            
            managedContext.save(nil)
            
        }
        //println(user)
    }
}
