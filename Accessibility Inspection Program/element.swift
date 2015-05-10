//
//  element.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/19/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import Foundation
import Photos

class Elemental: NSObject {
    var location: NSString?
    var picture: NSString?
    var notes: NSString?
    var category: NSString?
    var uniqueID: Int?
    
    init(location: NSString, picture: NSString, notes: NSString, category: NSString, uniqueID: Int) {
        self.location = location
        self.picture = picture
        self.notes = notes
        self.category = category
        self.uniqueID = uniqueID
        super.init()
    }

}

class position {
    var category: [String] = []
    var username: String!
    var password: String!
    var tracking: String!
    var site: String!
    var type: String!
    var uniqueID: Int!
    var assetCollection: PHAssetCollection!
    
    func parent() -> String {
        if (category.isEmpty || category.count < 2) {
            return "**&^"
        } else {
            var count = category.count - 2
            return category[count]
        }
    }
    
    func add(stringly: String) {
        category.append(stringly)
    }
    
    func current() -> String {
        if (category.isEmpty) {
            return "empty"
        } else {
            return category.last!
        }
    }
    
    func count() -> Int {
        if (category.isEmpty) {
            return 0
        } else {
            return category.count
        }
    }
    
    func pop() -> String {
        var returnable : String!
        if (category.isEmpty) {
            returnable = "empty"
        } else {
            var count = category.count - 1
            category.removeAtIndex(count)
            if (category.isEmpty) {
                returnable = "empty"
            } else {
                returnable = category.last
            }
        }
        
        return returnable
    }
}