//
//  User.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/25/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

import Foundation

struct User {
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""

    init(uniqueKey: String, firstName: String, lastName: String) {
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        
    }
    
}
