//
//  coreDataHelper.swift
//  Accessibility Inspection Program
//
//  Created by generic on 7/27/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import Foundation
import CoreData

class coreDataHelper {
    
    let appDelegate: AppDelegate? //UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext: NSManagedObjectContext? // = appDelegate.managedObjectContext!
    

    init (inheretAppDelegate: AppDelegate){
        self.appDelegate = inheretAppDelegate
        self.managedContext = appDelegate!.managedObjectContext!
    }
    
    func coreNames(tracking: String, multiple: Bool) -> [String: String] {
        var names = [String: String]()
        let fetchRequest = NSFetchRequest(entityName: "Elements")
        fetchRequest.resultType = NSFetchRequestResultType.ManagedObjectResultType
        fetchRequest.returnsDistinctResults = true
        
        if (!multiple) {
            let pred1 = NSPredicate(format: "site == %@", tracking)
            let pred2 = NSPredicate(format: "picture == %@", "name")
            let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1, pred2])
            fetchRequest.predicate = pred
        } else {
            //fetchRequest.resultType = NSFetchRequestResultType.ManagedObjectResultType
            //fetchRequest.returnsDistinctResults = true
            
            let pred = NSPredicate(format: "picture == %@", "name")
            fetchRequest.predicate = pred
        }
        
        var error: NSError?
        
        let fetchedResults =  managedContext!.executeFetchRequest(fetchRequest, error: &error) as![NSManagedObject]?
    
        if let results = fetchedResults {
            //do something if its empty..
            if (results.count == 0) {
                println("no names found");
            } else {
                var i: Int = 0
                println("found \(results.count) results")
                for result in results {
                    var name = result.valueForKey("notes") as? String
                    var description = result.valueForKey("location") as? String
                    var site = result.valueForKey("site") as? String
                    var type = result.valueForKey("category") as? String
                    //names.extend(["name": name])
                    names.updateValue(name!, forKey: "name\(i)");
                    names.updateValue(description!, forKey: "description\(i)");
                    names.updateValue(site!, forKey: "site\(i)");
                    names.updateValue(type!, forKey: "type\(i)");
                    //println("found name: \(name), \(description), \(site), \(type)")
                    i++
                }
            }
        }
            
        return names
    }
    
    func coreRemoveElements(table: String, tracking: String) {
        println("removing...")
        
        let fetchRequest = NSFetchRequest(entityName: table)
        if (tracking != "") {
            fetchRequest.resultType = NSFetchRequestResultType.ManagedObjectResultType
            fetchRequest.returnsDistinctResults = true
            
            let pred = NSPredicate(format: "(site == %@)", tracking)
            fetchRequest.predicate = pred
        }
        
        //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        var error: NSError? = nil
        let list = self.managedContext!.executeFetchRequest(fetchRequest, error: &error)
        
        if let users = list {
            var bas: NSManagedObject!
            
            for bas: AnyObject in users {
                managedContext!.deleteObject(bas as! NSManagedObject)
            }
            
            managedContext!.save(nil)
            
        }
    }
    
    func coreRemoveElement(table: String, tracking: String, uniqueID: Int) {
        println("removing...")
        
        let fetchRequest = NSFetchRequest(entityName: table)
        if (tracking != "") {
            fetchRequest.resultType = NSFetchRequestResultType.ManagedObjectResultType
            fetchRequest.returnsDistinctResults = true
            
            let pred1 = NSPredicate(format: "site == %@", tracking)
            let pred2 = NSPredicate(format: "uniqueID == %i", uniqueID)
            let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1, pred2])
            fetchRequest.predicate = pred
        }
        
        //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        var error: NSError? = nil
        let list = self.managedContext!.executeFetchRequest(fetchRequest, error: &error)
        
        if let users = list {
            var bas: NSManagedObject!
            
            for bas: AnyObject in users {
                managedContext!.deleteObject(bas as! NSManagedObject)
            }
            
            managedContext!.save(nil)
            
        }
    }

    
    func coreSaveElements(elements: [Elemental], tracking: String) {
        println("inserting...Core")
        
        let entity =  NSEntityDescription.entityForName("Elements", inManagedObjectContext: managedContext!)
        
        //var index = 0
        for element in elements {
            var item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
            item.setValue(element.location, forKey: "location")
            item.setValue(element.picture, forKey: "picture")
            item.setValue(element.notes, forKey: "notes")
            item.setValue(element.category, forKey: "category")
            item.setValue(element.uniqueID, forKey: "uniqueID")
            item.setValue(tracking, forKey: "site")
            
            println("saved, location: \(element.location), picture: \(element.picture), note: \(element.notes), category: \(element.category), uniqueID: \(element.uniqueID), site: \(tracking)")
            
            var error: NSError?
            if !managedContext!.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            //index++
        }
    }
    
    func coreUpdateElement(tracking: String, uniqueID: Int, key: String, value: String) {
    
        println("saving: \(uniqueID) for \(key) = \(value)")
        var fetchRequest = NSFetchRequest(entityName: "Elements")
        let pred1 = NSPredicate(format: "site == %@", tracking)
        let pred2 = NSPredicate(format: "uniqueID == %i", uniqueID)
        let pred = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [pred1, pred2])
        fetchRequest.predicate = pred
        
        if let fetchResults = managedContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                
                var managedObject = fetchResults[0]
                managedObject.setValue(value, forKey: key)
                
                managedContext!.save(nil)
            }
        }
    }
    
    /*func coreSaveUser(state: position, password: String, username: String) {
        println("saving...")
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: self.managedContext!)
        
        let results = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedContext!)
        
        results.setValue(password, forKey: "password")
        results.setValue(username, forKey: "username")
        
        results.setValue(state.site, forKey: "site")
        results.setValue(state.type, forKey: "type")
        results.setValue(state.tracking, forKey: "tracking")
        
        var error: NSError?
        if !managedContext!.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }*/
    
    func coreSaveUser(state: position, password: String, username: String) {
        
        let entity = NSFetchRequest(entityName: "User")
        var password2: String?
        var username2: String?
        
        //let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
        
        var error: NSError? = nil
        let list = managedContext!.executeFetchRequest(entity, error: &error)
        
        if let users = list {
            var bas: NSManagedObject!
            
            for bas: AnyObject in users {
                managedContext!.deleteObject(bas as! NSManagedObject)
            }
            
            managedContext!.save(nil)
        }
        
        let newEntity = NSEntityDescription.entityForName("User", inManagedObjectContext: managedContext!)
        
        let results = NSManagedObject(entity: newEntity!, insertIntoManagedObjectContext: managedContext!)
        
        if (password == "") {
            password2 = state.password
        } else {
            password2 = password
        }
        
        if (username == "") {
            username2 = state.username
        } else {
            username2 = username
        }
        
        results.setValue(password2, forKey: "password")
        results.setValue(username2, forKey: "username")
        results.setValue(state.tracking, forKey: "tracking")
        results.setValue(state.site, forKey: "site")
        results.setValue(state.type, forKey: "type")
        
        if !managedContext!.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    

}