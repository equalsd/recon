//
//  pictureViewController.swift
//  Accessibility Inspection Program
//
//  Created by generic on 4/15/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import UIKit

class pictureViewController: UICollectionViewController {
    
    var username: String!
    var password: String!
    var category: String!
    var site: String!
    var tracking: String!
    var elements: [Elemental] = []
    var locations: [String] = []
    var pictures: [String] = []
    let reuseIdentifier = "Cell"
    var selectedLocation: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedLocation
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
    
        // Configure the cell
    
        return cell
    }
    
    func getItemsByLocation () {
        var elements = self.elements
        
        var locations: [String] = []
        var pictures: [String] = []
        
        for item in elements {
            if (item.location == self.category) {
                if (!contains(locations, item.location! as String)) {
                    locations.append(item.location! as String)
                    pictures.append(item.picture! as String)
                }
            }
        }
        
        self.locations = locations
        self.pictures = pictures
        //self.tableView.reloadData()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPicture" {
            var navigationController =  segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! pictureViewController
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            controller.category = self.category
            controller.elements = self.elements
            
        } else if (segue.identifier == "toSiteList") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteListController
            
            controller.username = self.username
            controller.password = self.password
            controller.tracking = self.tracking
            controller.site = self.site
            //controller.category = self.category
            /*controller.continuance = self.continuance*/
            
            /*let myIndexPath = self.tableView.indexPathForSelectedRow()
            if (myIndexPath != nil) {
            
            let row = myIndexPath?.row
            controller.site = nameData[row!]
            controller.tracking = trackingData[row!]
            controller.continuance = ""
            }*/
        } else if (segue.identifier == "toNew") {
            var navigationController =  segue.destinationViewController as! UINavigationController
            var controller = navigationController.topViewController as! siteNewController
            //println("sobeit")
            //println(segue.identifier)
        }
    }

}
