//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/17/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

import UIKit

struct StudentInformation {
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    var mapString = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var objectId = ""
    
    init(dictionary: [String : AnyObject]) {
        objectId = (dictionary[OTMClient.JSONResponseKeys.ObjectID] as? String)!
        uniqueKey = (dictionary[OTMClient.JSONResponseKeys.UniqueKey] as? String)!
        firstName = (dictionary[OTMClient.JSONResponseKeys.FirstName] as? String)!
        lastName = (dictionary[OTMClient.JSONResponseKeys.LastName] as? String)!
        mediaURL = (dictionary[OTMClient.JSONResponseKeys.MediaURL] as? String)!
        mapString = (dictionary[OTMClient.JSONResponseKeys.MapString] as? String)!
        latitude = (dictionary[OTMClient.JSONResponseKeys.Latitude] as? Double)!
        longitude = (dictionary[OTMClient.JSONResponseKeys.Longitude] as? Double)!
    }
    
    static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
        
        var students = [StudentInformation]()
        
        for result in results {
            students.append(StudentInformation(dictionary: result))
        }
        
        return students
    }
    
}
