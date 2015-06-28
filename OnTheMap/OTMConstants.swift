//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/9/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

extension OTMClient {
    
    // Constants
    struct Constants {
        
        // Keys and IDs
        static let ParseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey : String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // URLs
        static let BaseURLSecure : String = "https://www.udacity.com/api/"
        static let BaseParseURL : String = "https://api.parse.com/1/classes/"
        
    }
    
    // MARK: - Methods
    struct Methods {
        
        // Users
        static let Session = "session"
        static let UserID = "users/{id}"
        
        static let StudentLocation = "StudentLocation"
        static let StudentLocationKey = "StudentLocation/{id}"
        
    }
    
    struct URLKeys {
        
        static let UserID = "id"
        
    }
    
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        static let Account = "account"
        static let Key = "key"
        static let StatusMessage = "status_message"
        static let UserID = "id"
        
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        
    }
    

}
