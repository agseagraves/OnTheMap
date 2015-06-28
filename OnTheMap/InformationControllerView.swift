//
//  InformationControllerView.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/24/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InformationControllerView: UIViewController, MKMapViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var whereText: UILabel!
    @IBOutlet weak var studyText: UILabel!
    @IBOutlet weak var todayText: UILabel!

    @IBOutlet weak var userLink: UITextView!
    
    @IBOutlet weak var locationField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var mapPreview: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var studentPlacemark:CLPlacemark?
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // set color to #666699
        self.blueView.backgroundColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        
        self.findButton.layer.cornerRadius = 5
        self.findButton.layer.borderWidth = 1
        self.submitButton.layer.cornerRadius = 5
        self.submitButton.layer.borderWidth = 1
        
        self.userLink.delegate = self
        
        locationInputMode()

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        // I get tired of typing in the same link so use the previous link on an update
        if self.appDelegate.userLink != nil {
            self.userLink.text = self.appDelegate.userLink
        } else {
            self.userLink.text = "Enter a Link to Share Here"
        }
        
        self.activityIndicator.hidesWhenStopped = true
//        self.userLink.delegate = self
        

    }
    
    // Set up objects for location input
    func locationInputMode() {
 
        self.findButton.hidden = false
        self.whereText.hidden = false
        self.studyText.hidden = false
        self.todayText.hidden = false
        self.locationField.hidden = false
        
        self.submitButton.hidden = true
        self.mapPreview.hidden = true
        self.userLink.hidden = true
        
        
        self.locationField.text = "Enter your location here"
        
        // set color to #CCCCCC
        self.view.backgroundColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)

    }
    
    // Set up objects for link input
    func linkInputMode() {
        
        self.findButton.hidden = true
        self.whereText.hidden = true
        self.studyText.hidden = true
        self.todayText.hidden = true
        self.blueView.hidden = true
        self.locationField.hidden = true
        
        self.cancelButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        self.submitButton.hidden = false
        self.mapPreview.hidden = false
        self.userLink.hidden = false
        
        // set background color to #666699
        self.view.backgroundColor = UIColor(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Blank out default text
        if self.userLink.text == "Enter a Link to Share Here" {
            textView.text = ""
        }
        
    }

    @IBAction func cancelAction(sender: AnyObject) {

        // close information view
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func submitAction(sender: AnyObject) {
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        // Make sure a link was added
        if self.userLink.text == "" || self.userLink.text == "Enter a Link to Share Here" {
            dispatch_async(dispatch_get_main_queue(), {
                var loginAlert = UIAlertController(title: "Data Error" , message: "A user link is required.".description, preferredStyle: UIAlertControllerStyle.Alert)
                loginAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler:nil))
                self.presentViewController(loginAlert, animated: true, completion: nil)
            })
        } else {
            // build and submit information
            let studentData:[String: AnyObject] = [
                    "firstName": appDelegate.user!.firstName,
                    "lastName": appDelegate.user!.lastName,
                    "latitude": studentPlacemark!.location.coordinate.latitude,
                    "longitude": studentPlacemark!.location.coordinate.longitude,
                    "mapString": self.locationField.text!,
                    "mediaURL": self.userLink.text!,
                    "uniqueKey": appDelegate.user!.uniqueKey
            ]

            if  self.appDelegate.userMapped {
                // the user is already mapped so update information
                var mutableMethod : String = OTMClient.Methods.StudentLocationKey
                mutableMethod = OTMClient.substituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.UserID, value: appDelegate.userObjectId!)!
                
                // update the location
                OTMClient.sharedInstance().taskForParsePUTMethod(mutableMethod, jsonBody: studentData, completionHandler: { (parsedResult, error) in
                    
                    var completionError = ""
                    if let checkError = parsedResult["error"] as? String {
                        completionError = checkError
                    }
                    self.completionForLocation(completionError)
                })
                
            } else {
                // the user has not been mapped so add the location
                OTMClient.sharedInstance().taskForParsePOSTMethod(studentData, completionHandler: { (parsedResult, error) in
                    
                    var completionError = ""
                    if let checkError = parsedResult["error"] as? String {
                        completionError = checkError
                    }
                    self.completionForLocation(completionError)
                    
                })
                
            }

        }
    }
    
    // dismiss the information view controller
    func dismissInfo() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func completionForLocation(error: String) {
        
        /* Send the desired value(s) to completion handler */
        if error != "" {
            dispatch_async(dispatch_get_main_queue(), {
                var loginAlert = UIAlertController(title: "Location Not Added" , message: error, preferredStyle: UIAlertControllerStyle.Alert)
                loginAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler:nil))
                self.presentViewController(loginAlert, animated: true, completion: nil)
            })
        } else {
            // Dismiss the Information view after acknowledging the success and post notification for a reload of data
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                self.dismissInfo()
                
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: self)
            }

            dispatch_async(dispatch_get_main_queue(), {
                var loginAlert = UIAlertController(title: nil , message: "Your Location Information was Successfully Added!", preferredStyle: UIAlertControllerStyle.Alert)
                loginAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler:callActionHandler))
                self.presentViewController(loginAlert, animated: true, completion: nil)
            })
        }
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
    }
    
    @IBAction func findOnTheMap(sender: AnyObject) {
        let mapString = self.locationField.description
        
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        // find the location
        let geocode = CLGeocoder()
        geocode.geocodeAddressString(self.locationField.text){locationData, error in
            if let err = error {
                println("location error")
                dispatch_async(dispatch_get_main_queue(), {
                    var loginAlert = UIAlertController(title: "Location Error" , message: "Location cannot be mapped.".description, preferredStyle: UIAlertControllerStyle.Alert)
                    loginAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler:nil))
                    self.presentViewController(loginAlert, animated: true, completion: nil)
                })
                // Go back to location input mode
                self.locationInputMode()
                
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                
            } else {
                if let location = locationData as? [CLPlacemark] {
                    self.studentPlacemark = location[0]
                    let coordinate = location[0].location.coordinate
                    let region = MKCoordinateRegion(center:coordinate, span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta:2))
                    self.mapPreview.setRegion(region, animated: true)
                    
                    var pin = MKPointAnnotation()
                    pin.coordinate = coordinate
                    pin.title = self.locationField.text
                    
                    self.mapPreview.addAnnotation(pin)
                    println(coordinate)
                }
                
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                
                // Prepare to get link
                self.linkInputMode()
            }
        }
        
    }
}