//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/8/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var annotations = [MKPointAnnotation]()
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Load the map with student location data
        loadMap()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Get the shared URL session */
//        session = NSURLSession.sharedSession()
        
        // listen for refresh action
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadMap", name:"load", object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove listener for refresh
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "load", object: nil)
    }

    
    func loadMap() {
        
        // first remove any existing annotations in case this is a refresh
        self.mapView.removeAnnotations( self.mapView.annotations)
        annotations.removeAll()
        
        var parameters = [String: AnyObject]()
        var mutableMethod : String = OTMClient.Methods.StudentLocation
        OTMClient.sharedInstance().taskForParseGETMethod(mutableMethod, parameters: parameters, completionHandler: { (parsedResult, error) in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                let errorString = error.description
                if errorString.rangeOfString("Error Domain=NSURLErrorDomain") != nil {
                    self.displayNetworkError()
                } else {
                    self.displayError(errorString)
                }
            } else {
                if let results = parsedResult["results"] as? [[String : AnyObject]] {

                    self.appDelegate.students = StudentInformation.studentsFromResults(results)
                    self.loadAnnotations()
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.reloadInputViews()
                        self.mapView.addAnnotations(self.annotations)
                    }
                }
                
            }
        })
    }
    
    func loadAnnotations () {
        // The "locations" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        let locations = appDelegate.students
        
        for dictionary in locations {
            
            let lat = CLLocationDegrees(dictionary.latitude)
            let long = CLLocationDegrees(dictionary.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dictionary.firstName
            let last = dictionary.lastName
            let mediaURL = dictionary.mediaURL
            
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    

    // open browser to URL specified in subtitle
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        }
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                var loginAlert = UIAlertController(title: "Login Error" , message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                loginAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler:nil))
                self.presentViewController(loginAlert, animated: true, completion: nil)
                
            }
        })
    }
    
    func displayNetworkError() {
        dispatch_async(dispatch_get_main_queue(), {
            let alertLogin = UIAlertController(title: "Service Unavailable", message: "Please retry later", preferredStyle: .Alert)
            
            var imageView = UIImageView(frame: CGRectMake(220, 10, 40, 40))
            imageView.image = UIImage(named: "sad2")
            alertLogin.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler:nil))
            
            alertLogin.view.addSubview(imageView)
            
            self.presentViewController(alertLogin, animated: true, completion: nil)
            
        })
    }
    

}

