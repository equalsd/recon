//
//  element.swift
//  Accessibility Inspection Program
//
//  Created by generic on 2/19/15.
//  Copyright (c) 2015 generic. All rights reserved.
//

import Foundation

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