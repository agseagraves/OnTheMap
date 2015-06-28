//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Anita Seagraves on 6/8/15.
//  Copyright (c) 2015 Anita Seagraves. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signupButton: UIButton!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var apiClient : OTMClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
        
        apiClient = OTMClient()
        self.activityIndicator.hidesWhenStopped = true

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func signupAction(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    @IBAction func loginToUdacity(sender: AnyObject) {
        
        if self.passwordTextField.text == "" || self.emailTextField.text == "" {
            self.displayError("A username and password must be supplied")
        } else {
            
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
            
            var parameters = [String: AnyObject]()
            let jsonBody =  "{\"udacity\": {\"username\": \"\(self.emailTextField.text)\", \"password\": \"\(self.passwordTextField.text)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
            var mutableMethod : String = OTMClient.Methods.Session

            OTMClient.sharedInstance().taskForLogin(mutableMethod, parameters: parameters, jsonBody: jsonBody!, completionHandler: { (result, error) in
                
                /* Send the desired value(s) to completion handler */
                if let error = error {
                    if error.rangeOfString("Error Domain=NSURLErrorDomain") != nil {
                        self.displayNetworkError()
                    } else {
                        self.displayError(error)
                    }

                } else {
                    if result != nil {
                        println(result)
                        if let userKey = result[OTMClient.JSONResponseKeys.Account]?!.valueForKey(OTMClient.JSONResponseKeys.Key) as? String {
                            self.appDelegate.userKey = userKey
                            
                            self.completeLogin()
                        }
                    } else {
                        println("unexpected error")
                    }

                }
            })
        
        }
    }
    
    
    func completeLogin() {
        // get user profile info
        var parameters = [String: AnyObject]()
        var mutableMethod : String = OTMClient.Methods.UserID
        mutableMethod = OTMClient.substituteKeyInMethod(mutableMethod, key: OTMClient.JSONResponseKeys.UserID, value: self.appDelegate.userKey!)!

        OTMClient.sharedInstance().taskForLoginProfile(mutableMethod,parameters: parameters, completionHandler: { (result, error) in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                self.displayError(error)
            } else {
                if result != nil {
                    println(result)
                    if let user = result["user"] as? [String: AnyObject] {
                        
                        var studentProfile = User(uniqueKey: self.appDelegate.userKey as String!, firstName: user["first_name"] as! String, lastName:user["last_name"] as! String)
                        
                        self.appDelegate.user = studentProfile
                        
                        println(user)
                        
                    }
                } else {
                    println("unexpected error")
                }
                
            }
        })
        self.activityIndicator.stopAnimating()

        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
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