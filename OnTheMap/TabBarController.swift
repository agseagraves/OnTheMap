//
//  TabBarController.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/18/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TabBarController: UITabBarController {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var appDelegate: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAdditionalButtons()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
    }
    
    func addAdditionalButtons()
    {
        var rightBarButtonItemRefresh = UIBarButtonItem(
            barButtonSystemItem: .Refresh,
            target: self,
            action: "refresh:")
        
        var rightBarButtonItemPin = UIBarButtonItem(
            image: UIImage(named: "pin"),
            style: .Plain,
            target: self,
            action: "checkPin:")
        
        
        // add multiple right bar button items      
        self.navigationItem.setRightBarButtonItems([rightBarButtonItemRefresh,rightBarButtonItemPin], animated: true)
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: OTMClient.Constants.BaseParseURL + OTMClient.Methods.Session)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies as! [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value!, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            if error != nil { // Handle error…
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */

        }
        task.resume()
        
    }
    
    func checkPin(sender: AnyObject) {
        

        // check if user already mapped
        for (student) in self.appDelegate.students {
            if student.uniqueKey == self.appDelegate.userKey {
                // user mapped
                self.appDelegate.userMapped = true
                self.appDelegate.userLink = student.mediaURL
                self.appDelegate.userObjectId = student.objectId
                println(student)
            }
        }
        
        if self.appDelegate.userMapped {
            // user location is pinned
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                self.pinIt()
            }
            dispatch_async(dispatch_get_main_queue(), {
                var alert = UIAlertController(title: nil , message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?".description, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title:"Overwrite", style: UIAlertActionStyle.Default, handler: callActionHandler))
                alert.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.Default, handler:nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        } else {
            // user location is not pinned
            pinIt()
        }

        
    }
    
    func pinIt() {
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingView") as! UIViewController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func refresh(sender: AnyObject) {
        
        // send out notification for view to reload
        NSNotificationCenter.defaultCenter().postNotificationName("load", object: self)

    }
    
}