//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/8/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        // Listen for refresh
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList",name:"load", object: nil)
        
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        loadList()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove listener for refresh
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "load", object: nil)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentTableViewCell"
        let student = appDelegate.students[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        
        /* Set cell defaults */
        cell.textLabel!.text = student.firstName + " " + student.lastName
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.students.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let student = appDelegate.students[indexPath.row]
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: student.mediaURL)!)

    }
    
    func loadList() {
        var parameters = [String: AnyObject]()
        var mutableMethod : String = OTMClient.Methods.StudentLocation
        OTMClient.sharedInstance().taskForParseGETMethod(mutableMethod, parameters: parameters, completionHandler: { (parsedResult, error) in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                println(error)
            } else {
                if let results = parsedResult["results"] as? [[String : AnyObject]] {
                    self.appDelegate.students  = StudentInformation.studentsFromResults(results)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
                
            }
        })
    }

}

